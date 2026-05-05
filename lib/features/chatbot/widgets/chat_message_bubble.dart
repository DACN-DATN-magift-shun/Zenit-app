import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';

const String _chatbotLoaderAsset = 'assets/images/ai_loader.gif';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isPendingAssistant = !isUser && message.content.trim().isEmpty;
    final timeText = DateFormat('HH:mm').format(message.createdAt.toLocal());

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSizes.s),
          padding: const EdgeInsets.all(AppSizes.l),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.light.primaryMain
                : AppColors.light.secondaryMain,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: isPendingAssistant
                    ? const _AssistantTypingLoader(key: ValueKey('loading'))
                    : _MessageContent(
                        key: ValueKey(message.content),
                        message: message,
                        isUser: isUser,
                      ),
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                timeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.82)
                      : AppColors.light.neutralTextSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({
    super.key,
    required this.message,
    required this.isUser,
  });

  final ChatMessage message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    if (message.isMarkdown && !isUser) {
      return MarkdownBody(
        data: message.content,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.light.neutralTextPrimary,
          ),
          listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.light.neutralTextPrimary,
          ),
        ),
      );
    }

    return Text(
      message.content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isUser ? Colors.white : AppColors.light.neutralTextPrimary,
      ),
    );
  }
}

class _AssistantTypingLoader extends StatelessWidget {
  const _AssistantTypingLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 28, minWidth: 44),
      child: Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: Image.asset(
            _chatbotLoaderAsset,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              // Fallback: show animated dots if GIF fails to load
              return _TypingDotsLoader();
            },
          ),
        ),
      ),
    );
  }
}

class _TypingDotsLoader extends StatefulWidget {
  @override
  State<_TypingDotsLoader> createState() => _TypingDotsLoaderState();
}

class _TypingDotsLoaderState extends State<_TypingDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TypingDot(progress: _controller.value, delay: 0.0),
            const SizedBox(width: 4),
            _TypingDot(progress: _controller.value, delay: 0.2),
            const SizedBox(width: 4),
            _TypingDot(progress: _controller.value, delay: 0.4),
          ],
        );
      },
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({required this.progress, required this.delay});

  final double progress;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final shifted = ((progress - delay) % 1.0 + 1.0) % 1.0;
    final opacity = 0.28 + (0.72 * (1 - (shifted - 0.5).abs() * 2));

    return Opacity(
      opacity: opacity.clamp(0.2, 1.0),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.light.neutralTextSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
