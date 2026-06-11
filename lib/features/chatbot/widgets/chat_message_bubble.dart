import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.shouldAnimate = false,
    this.onAnimationComplete,
  });

  final ChatMessage message;
  /// When true, assistant text reveals with the typewriter effect.
  /// Should only be true for freshly received (live SSE) messages.
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;

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
                        key: ValueKey(message.id),
                        message: message,
                        isUser: isUser,
                        shouldAnimate: shouldAnimate,
                        onAnimationComplete: onAnimationComplete,
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

// ---------------------------------------------------------------------------
// Message content — typewriter for assistant, plain text for user
// ---------------------------------------------------------------------------

class _MessageContent extends StatelessWidget {
  const _MessageContent({
    super.key,
    required this.message,
    required this.isUser,
    required this.shouldAnimate,
    this.onAnimationComplete,
  });

  final ChatMessage message;
  final bool isUser;
  final bool shouldAnimate;
  final VoidCallback? onAnimationComplete;

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Text(
        message.content,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
      );
    }

    // Assistant message: typewriter only when the message is freshly received.
    if (message.isMarkdown) {
      return _TypewriterMarkdown(
        fullText: message.content,
        animate: shouldAnimate,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.light.neutralTextPrimary,
        ),
        onComplete: onAnimationComplete,
      );
    }

    return _TypewriterText(
      fullText: message.content,
      animate: shouldAnimate,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.light.neutralTextPrimary,
      ),
      onComplete: onAnimationComplete,
    );
  }
}

// ---------------------------------------------------------------------------
// Typewriter for plain text
// ---------------------------------------------------------------------------

class _TypewriterText extends StatefulWidget {
  const _TypewriterText({
    required this.fullText,
    required this.animate,
    this.style,
    this.onComplete,
  });

  final String fullText;
  final bool animate;
  final TextStyle? style;
  final VoidCallback? onComplete;

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  static const Duration _wordDelay = Duration(milliseconds: 30);

  late List<String> _words;
  int _visibleWordCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _words = _splitWords(widget.fullText);
    if (!widget.animate) {
      // History message — show everything instantly, skip timer entirely.
      _visibleWordCount = _words.length;
    } else {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(_TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fullText != widget.fullText) {
      _timer?.cancel();
      _words = _splitWords(widget.fullText);
      if (!widget.animate) {
        _visibleWordCount = _words.length;
        setState(() {});
        return;
      }
      // If text was extended (streaming), keep existing visible count and
      // continue from where we left off.
      if (_visibleWordCount > _words.length) {
        _visibleWordCount = _words.length;
      }
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<String> _splitWords(String text) {
    // Split preserving whitespace tokens so reconstruction is lossless.
    return text.split(RegExp(r'(?<=\s)|(?=\s)')).where((s) => s.isNotEmpty).toList();
  }

  void _startAnimation() {
    if (_visibleWordCount >= _words.length) {
      if (mounted) {
        widget.onComplete?.call();
        setState(() {});
      }
      return;
    }
    _timer = Timer.periodic(_wordDelay, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _visibleWordCount++;
      });
      if (_visibleWordCount >= _words.length) {
        t.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _words.take(_visibleWordCount).join();
    return Text(visible, style: widget.style);
  }
}

// ---------------------------------------------------------------------------
// Typewriter for Markdown — word-by-word with safe chunk boundaries
// ---------------------------------------------------------------------------

class _TypewriterMarkdown extends StatefulWidget {
  const _TypewriterMarkdown({
    required this.fullText,
    required this.animate,
    this.textStyle,
    this.onComplete,
  });

  final String fullText;
  final bool animate;
  final TextStyle? textStyle;
  final VoidCallback? onComplete;

  @override
  State<_TypewriterMarkdown> createState() => _TypewriterMarkdownState();
}

class _TypewriterMarkdownState extends State<_TypewriterMarkdown> {
  static const Duration _wordDelay = Duration(milliseconds: 30);

  /// Safe word-level chunks. Each chunk ends at a point where markdown is
  /// syntactically "safe" to cut (after a complete word, never mid-token).
  late List<String> _chunks;
  int _visibleCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _chunks = _buildChunks(widget.fullText);
    if (!widget.animate) {
      // History message — show everything instantly.
      _visibleCount = _chunks.length;
    } else {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(_TypewriterMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fullText != widget.fullText) {
      _timer?.cancel();
      final newChunks = _buildChunks(widget.fullText);
      _chunks = newChunks;
      if (!widget.animate) {
        _visibleCount = _chunks.length;
        setState(() {});
        return;
      }
      if (_visibleCount > _chunks.length) {
        _visibleCount = _chunks.length;
      }
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Split text into safe chunks.
  ///
  /// Strategy: split on whitespace boundaries. This ensures we never cut
  /// *inside* a Markdown inline token (e.g. `**bold**`). A bold/italic token
  /// that uses spaces around it will always appear as a complete word.
  List<String> _buildChunks(String text) {
    if (text.isEmpty) return [];

    // We split on word boundaries, keeping the delimiter (spaces / newlines)
    // attached to the preceding chunk so reconstruction is lossless.
    final rawWords = text.split(RegExp(r'(?<=\S)(?=\s)|(?<=\s)(?=\S)'));
    final chunks = <String>[];
    for (final word in rawWords) {
      if (word.isEmpty) continue;
      chunks.add(word);
    }
    return chunks;
  }

  void _startAnimation() {
    if (_visibleCount >= _chunks.length) {
      if (mounted) {
        widget.onComplete?.call();
        setState(() {});
      }
      return;
    }
    _timer = Timer.periodic(_wordDelay, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _visibleCount++;
      });
      if (_visibleCount >= _chunks.length) {
        t.cancel();
        widget.onComplete?.call();
      }
    });
  }

  String get _visibleText => _chunks.take(_visibleCount).join();

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _visibleText,
      selectable: false,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: widget.textStyle,
        listBullet: widget.textStyle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Assistant typing indicator — 3-dot bouncing loader (M3 style)
// ---------------------------------------------------------------------------

class _AssistantTypingLoader extends StatelessWidget {
  const _AssistantTypingLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 28, minWidth: 56),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: _BouncingDotsLoader(),
      ),
    );
  }
}

class _BouncingDotsLoader extends StatefulWidget {
  const _BouncingDotsLoader();

  @override
  State<_BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<_BouncingDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BounceDot(progress: _controller.value, phaseOffset: 0.0),
            const SizedBox(width: 5),
            _BounceDot(progress: _controller.value, phaseOffset: 0.18),
            const SizedBox(width: 5),
            _BounceDot(progress: _controller.value, phaseOffset: 0.36),
          ],
        );
      },
    );
  }
}

class _BounceDot extends StatelessWidget {
  const _BounceDot({required this.progress, required this.phaseOffset});

  final double progress;
  final double phaseOffset;

  static const double _dotSize = 7.0;

  @override
  Widget build(BuildContext context) {
    // Shifted progress for this dot
    final shifted = ((progress - phaseOffset) % 1.0 + 1.0) % 1.0;

    // Bounce: use a sine-like curve — up then down in first half, rest at bottom
    final bounce = shifted < 0.5
        ? (shifted * 2 * 3.14159265).let((rad) => _bounceValue(rad))
        : 0.0;

    // Opacity pulses with the bounce
    final opacity = 0.45 + 0.55 * bounce;

    return Transform.translate(
      offset: Offset(0, -bounce * 6),
      child: Opacity(
        opacity: opacity.clamp(0.3, 1.0),
        child: Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(
            color: AppColors.light.neutralTextSecondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// Maps a radian value [0, π] to a smooth bounce [0..1..0]
  double _bounceValue(double rad) {
    // Simple sine for smooth arc
    return (rad / 3.14159265).clamp(0.0, 1.0) < 0.5
        ? (rad / 1.5707963).clamp(0.0, 1.0)  // rise
        : ((3.14159265 - rad) / 1.5707963).clamp(0.0, 1.0);  // fall
  }
}

extension _DoubleExt on double {
  T let<T>(T Function(double) fn) => fn(this);
}
