import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_confirm_dialog.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';
import 'package:zenit/features/chatbot/providers/chatbot_provider.dart';
import 'package:zenit/features/chatbot/widgets/chat_action_chips_row.dart';
import 'package:zenit/features/chatbot/widgets/chat_history_sheet.dart';
import 'package:zenit/features/chatbot/widgets/chat_message_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();

  String? _lastAutoScrollAnchor;
  String? _lastSpeechError;
  bool _isListening = false;
  bool _speechReady = false;

  // Gradient border animation
  late final AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _initializeSpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatbotProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _speechToText.stop();
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Speech to text
  // -------------------------------------------------------------------------

  Future<bool> _initializeSpeechToText() async {
    try {
      final available = await _speechToText.initialize(
        debugLogging: true,
        onStatus: _onSpeechStatus,
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _lastSpeechError = error.errorMsg;
          });
        },
      );

      if (!mounted) return available;
      setState(() {
        _speechReady = available;
        if (available) {
          _lastSpeechError = null;
        }
      });
      return available;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _speechReady = false;
        _isListening = false;
        _lastSpeechError = 'initialize_failed';
      });
      return false;
    }
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;

    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _toggleVoiceInput() async {
    try {
      if (_isListening) {
        await _speechToText.stop();
        if (!mounted) return;
        setState(() {
          _isListening = false;
        });
        return;
      }

      if (!_speechReady) {
        final available = await _initializeSpeechToText();
        if (!available) {
          _showErrorMessage(_buildSpeechServiceErrorMessage(_lastSpeechError));
          return;
        }
      }

      final hasPermission = await _speechToText.hasPermission;
      if (!hasPermission) {
        _showErrorMessage(
          'Microphone permission is denied. Please allow microphone access in app settings.',
        );
        return;
      }

      if (!_speechToText.isAvailable) {
        _showErrorMessage(
          'Speech recognition service is not available on this device.',
        );
        return;
      }

      final localeId = await _resolveSpeechLocaleId();

      await _speechToText.cancel();

      final listenResult = await _speechToText.listen(
        localeId: localeId,
        partialResults: true,
        cancelOnError: true,
        onResult: (result) {
          if (!mounted) return;

          final words = result.recognizedWords.trim();
          if (words.isEmpty) {
            return;
          }

          _composerController.text = words;
          _composerController.selection = TextSelection.fromPosition(
            TextPosition(offset: _composerController.text.length),
          );
        },
      );

      final hasStarted = listenResult is bool
          ? listenResult
          : _speechToText.isListening;

      if (!mounted) return;
      setState(() {
        _isListening = hasStarted;
      });

      if (!hasStarted) {
        _showErrorMessage('Could not start microphone input.');
      }
    } on MissingPluginException {
      _showErrorMessage(
        'Speech plugin is not ready. Please fully restart the app.',
      );
    } on PlatformException catch (e) {
      _showErrorMessage(
        _buildSpeechServiceErrorMessage('${e.code} ${e.message ?? ''}'),
      );
    } catch (e) {
      _showErrorMessage('Failed to use microphone input: ${e.runtimeType}');
    }
  }

  String _buildSpeechServiceErrorMessage(String? rawError) {
    final normalized = (rawError ?? '').toLowerCase();
    final isBindError10 =
        normalized.contains('error 10') ||
        normalized.contains('recognition service') ||
        normalized.contains('bind to system recognition service failed');

    if (isBindError10) {
      return 'Thiết bị hiện không có dịch vụ nhận diện giọng nói khả dụng (Speech Recognizer). Nếu đang dùng emulator, hãy dùng image có Google Play/Google APIs và bật Google app.';
    }

    if (rawError == null || rawError.trim().isEmpty) {
      return 'Microphone speech recognition is unavailable.';
    }

    return 'Microphone speech recognition is unavailable. ($rawError)';
  }

  Future<String?> _resolveSpeechLocaleId() async {
    try {
      final locales = await _speechToText.locales();
      if (locales.isEmpty) {
        return null;
      }

      const preferredLocales = <String>['vi_VN', 'vi-VN', 'en_US', 'en-US'];
      for (final preferred in preferredLocales) {
        for (final locale in locales) {
          if (locale.localeId.toLowerCase() == preferred.toLowerCase()) {
            return locale.localeId;
          }
        }
      }

      return locales.first.localeId;
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Messaging
  // -------------------------------------------------------------------------

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }

    _composerController.clear();

    try {
      final sendFuture = context.read<ChatbotProvider>().sendMessage(text);
      _scrollToLatest();
      await sendFuture;
      _scrollToLatest();
    } catch (e) {
      if (!mounted) return;
      AppFlash.error(context, e.toString());
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _autoScrollWhenMessagesChanged({
    required String? conversationId,
    required List<ChatMessage> messages,
    required bool isSending,
  }) {
    final latestMessageId = messages.isNotEmpty ? messages.last.id : '';
    final anchor =
        '$conversationId|${messages.length}|$latestMessageId|$isSending';

    if (_lastAutoScrollAnchor == anchor) {
      return;
    }

    _lastAutoScrollAnchor = anchor;
    _scrollToLatest();
  }

  bool _shouldShowConfirmChip(ChatMessage? latestMessage) {
    if (latestMessage == null) {
      return false;
    }

    return context.read<ChatbotProvider>().shouldShowAcceptButton(
      latestMessage.id,
    );
  }

  Future<void> _sendConfirmYes() async {
    try {
      await context.read<ChatbotProvider>().sendMessage('yes');
      _scrollToLatest();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  Future<void> _sendSuggestedMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    try {
      await context.read<ChatbotProvider>().sendMessage(trimmed);
      _scrollToLatest();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  List<ChatActionChipItem> _buildSuggestionChipItems({
    required ChatMessage message,
    required bool enabled,
  }) {
    return message.suggestions
        .map((suggestion) {
          final label = suggestion.displayText.trim();
          final value = suggestion.value.trim();
          final payload = value.isNotEmpty ? value : label;

          if (payload.isEmpty) {
            return null;
          }

          return ChatActionChipItem(
            label: label.isNotEmpty ? label : payload,
            enabled: enabled,
            onPressed: () => _sendSuggestedMessage(payload),
          );
        })
        .whereType<ChatActionChipItem>()
        .toList(growable: false);
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    AppFlash.error(context, message);
  }

  Future<void> _openHistorySheet() async {
    final l10n = context.l10n;
    final provider = context.read<ChatbotProvider>();
    await provider.refreshConversations();

    if (!mounted) return;

    await AppDrawer.showAsBottomSheet<void>(
      context: context,
      title: l10n.chatHistoryTitle,
      showCloseButton: true,
      showDragHandle: true,
      height: MediaQuery.of(context).size.height * 0.7,
      body: Consumer<ChatbotProvider>(
        builder: (sheetContext, state, child) {
          return ChatHistorySheet(
            conversations: state.conversations,
            activeConversationId: state.activeConversationId,
            messages: state.activeMessages,
            onCreateNew: () async {
              await state.createNewConversation();
              if (!sheetContext.mounted) return;
              Navigator.of(sheetContext).pop();
              _scrollToLatest();
            },
            onSelect: (item) async {
              await state.selectConversation(item.id);
              if (!sheetContext.mounted) return;
              Navigator.of(sheetContext).pop();
              _scrollToLatest();
            },
            onRename: (item) async {
              final newTitle = await _showRenameDialog(item);
              if (newTitle == null || newTitle.trim().isEmpty) {
                return;
              }

              await state.updateConversationTitle(
                conversationId: item.id,
                title: newTitle.trim(),
              );
            },
            onDelete: (item) async {
              final shouldDelete = await AppConfirmDialog.show(
                context: sheetContext,
                title: l10n.confirmDelete,
                message: l10n.chatConfirmDeleteConversation(item.title),
                confirmText: l10n.delete,
                cancelText: l10n.cancel,
                isDestructive: true,
              );

              if (!shouldDelete) return;
              await state.deleteConversation(item.id);
            },
          );
        },
      ),
    );
  }

  Future<void> _createNewConversation() async {
    final provider = context.read<ChatbotProvider>();
    try {
      await provider.createNewConversation();
      if (!mounted) return;
      _scrollToLatest();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  Future<String?> _showRenameDialog(ConversationSummary conversation) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: conversation.title);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.chatRenameConversation),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.chatConversationTitleHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(l10n.chatSave),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.chatbotTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // ── MOCK TEST BUTTON (remove before release) ──────────────────────
          // Consumer<ChatbotProvider>(
          //   builder: (context, provider, child) {
          //     return IconButton(
          //       onPressed:
          //           provider.isSending ? null : provider.mockSimulateAiResponse,
          //       icon: const Icon(Icons.science_outlined),
          //       tooltip: 'Mock AI Test',
          //       color: Colors.white70,
          //     );
          //   },
          // ),
          // // ─────────────────────────────────────────────────────────────────
          IconButton(
            onPressed: _openHistorySheet,
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.chatHistoryTooltip,
          ),
          Consumer<ChatbotProvider>(
            builder: (context, provider, child) {
              final isCurrentSessionEmpty =
                  provider.activeConversationId != null &&
                  provider.activeMessages.isEmpty;
              return IconButton(
                onPressed: isCurrentSessionEmpty ? null : _createNewConversation,
                icon: const Icon(Icons.add_comment_outlined),
                tooltip: l10n.chatNewConversationTooltip,
              );
            },
          ),
          const SizedBox(width: AppSizes.xs),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatbotProvider>(
              builder: (context, provider, child) {
                if (provider.isInitializing) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = provider.activeMessages;
                _autoScrollWhenMessagesChanged(
                  conversationId: provider.activeConversationId,
                  messages: messages,
                  isSending: provider.isSending,
                );

                // Drive the gradient animation based on sending state
                if (provider.isSending) {
                  if (!_gradientController.isAnimating) {
                    _gradientController.repeat();
                  }
                } else {
                  if (_gradientController.isAnimating) {
                    _gradientController.stop();
                    _gradientController.reset();
                  }
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Text(
                        l10n.chatStartConversationHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.neutralTextSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.l,
                    vertical: AppSizes.m,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final latestMessage = messages.isNotEmpty
                        ? messages.last
                        : null;
                    final isLatestMessage = latestMessage?.id == message.id;
                    final showConfirmChip =
                        isLatestMessage &&
                        _shouldShowConfirmChip(latestMessage);
                    final showSuggestionChips =
                        isLatestMessage &&
                        message.role == ChatMessageRole.assistant &&
                        message.content.trim().isNotEmpty;

                    final chipItems = <ChatActionChipItem>[
                      if (showSuggestionChips)
                        ..._buildSuggestionChipItems(
                          message: message,
                          enabled: !provider.isSending,
                        ),
                      if (showConfirmChip)
                        ChatActionChipItem(
                          label: 'Xác nhận',
                          enabled: !provider.isSending,
                          onPressed: _sendConfirmYes,
                        ),
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChatMessageBubble(
                          message: message,
                          shouldAnimate: provider.shouldAnimateMessage(message.id),
                        ),
                        if (chipItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppSizes.s,
                              bottom: AppSizes.s,
                            ),
                            child: ChatActionChipsRow(items: chipItems),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildComposer(context, colors),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Composer with animated gradient border
  // -------------------------------------------------------------------------

  Widget _buildComposer(BuildContext context, AppColorExtension colors) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.l,
          AppSizes.s,
          AppSizes.l,
          AppSizes.l,
        ),
        child: Consumer<ChatbotProvider>(
          builder: (context, provider, child) {
            final isSending = provider.isSending;

            // Gradient border colors: primaryMain → neon purple → cyan → secondaryHover
            final gradientColors = [
              colors.primaryMain,
              const Color(0xFF9B59F5), // neon purple
              const Color(0xFF00E5FF), // neon cyan
              colors.secondaryHover,
              colors.primaryMain,
            ];

            return AnimatedBuilder(
              animation: _gradientController,
              child: _buildComposerInner(colors),
              builder: (context, composerChild) {
                // Wrap the inner box in padding so the foreground ring paints
                // in the gap between the CustomPaint bounds and the inner Container.
                // When not sending, padding is zero — no layout shift.
                return CustomPaint(
                  // foregroundPainter renders OVER the child so the ring is
                  // always visible regardless of the Container’s background.
                  foregroundPainter: isSending
                      ? _GradientBorderPainter(
                          progress: _gradientController.value,
                          gradientColors: gradientColors,
                          borderRadius: 36.0,
                          borderWidth: 3.0,
                        )
                      : null,
                  child: composerChild,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildComposerInner(AppColorExtension colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.m,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: colors.neutralBorder.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSizes.l),
          Expanded(
            child: TextField(
              controller: _composerController,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: context.l10n.chatInputHint,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Consumer<ChatbotProvider>(
            builder: (context, provider, child) {
              final disableActions = provider.isSending;

              Widget micButton = IconButton(
                onPressed: disableActions ? null : _toggleVoiceInput,
                icon: Icon(
                  _isListening
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  color: _isListening
                      ? Colors.white
                      : colors.neutralTextSecondary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _isListening
                      ? colors.primaryMain
                      : Colors.transparent,
                  padding: const EdgeInsets.all(AppSizes.s),
                ),
                tooltip: _isListening
                    ? 'Stop voice input'
                    : 'Start voice input',
              );

              if (_isListening) {
                micButton = micButton
                    .animate(
                      onPlay: (controller) =>
                          controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.15, 1.15),
                      duration: 600.ms,
                      curve: Curves.easeInOut,
                    );
              }

              return Row(
                children: [
                  micButton,
                  const SizedBox(width: AppSizes.xs),
                  IconButton(
                    onPressed: disableActions ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: colors.primaryMain,
                      padding: const EdgeInsets.all(AppSizes.s),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter — spinning sweep gradient border
// ---------------------------------------------------------------------------

class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({
    required this.progress,
    required this.gradientColors,
    required this.borderRadius,
    required this.borderWidth,
  });

  final double progress;
  final List<Color> gradientColors;
  final double borderRadius;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // Outer clip path = rounded rect border ring
    final outerPath = Path()..addRRect(rrect);
    final innerRRect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth),
      Radius.circular(borderRadius - borderWidth),
    );
    final innerPath = Path()..addRRect(innerRRect);
    final borderPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    // Sweep gradient rotated by progress (full 2π rotation per cycle)
    final center = rect.center;
    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: gradientColors,
      transform: GradientRotation(progress * math.pi * 2),
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipPath(borderPath);
    canvas.drawCircle(center, math.max(size.width, size.height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
