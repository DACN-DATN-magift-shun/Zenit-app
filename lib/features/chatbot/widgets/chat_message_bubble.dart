import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
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
              if (message.isMarkdown && !isUser)
                MarkdownBody(
                  data: message.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                        p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.light.neutralTextPrimary,
                        ),
                        listBullet: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: AppColors.light.neutralTextPrimary,
                            ),
                      ),
                )
              else
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isUser
                        ? Colors.white
                        : AppColors.light.neutralTextPrimary,
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
