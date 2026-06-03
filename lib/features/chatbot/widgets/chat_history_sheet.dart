import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';

class ChatHistorySheet extends StatelessWidget {
  const ChatHistorySheet({
    super.key,
    required this.conversations,
    required this.activeConversationId,
    required this.onCreateNew,
    required this.onSelect,
    required this.onRename,
    required this.onDelete,
    this.messages = const [],
  });

  final List<ConversationSummary> conversations;
  final String? activeConversationId;
  final VoidCallback onCreateNew;
  final ValueChanged<ConversationSummary> onSelect;
  final ValueChanged<ConversationSummary> onRename;
  final ValueChanged<ConversationSummary> onDelete;
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isCurrentSessionEmpty = activeConversationId != null && messages.isEmpty;

    return Column(
      children: [
        Expanded(
          child: conversations.isEmpty
              ? Center(
                  child: Text(
                    l10n.chatNoConversations,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.neutralTextSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: conversations.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.l,
                    vertical: AppSizes.m,
                  ),
                  itemBuilder: (context, index) {
                    final item = conversations[index];
                    final selected = item.id == activeConversationId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.m),
                      child: _ConversationHistoryItem(
                        item: item,
                        selected: selected,
                        onSelect: () => onSelect(item),
                        onRename: () => onRename(item),
                        onDelete: () => onDelete(item),
                      ),
                    );
                  },
                ),
        ),
        Divider(height: 1, color: colors.neutralBorder),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.l,
            AppSizes.m,
            AppSizes.l,
            AppSizes.m,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isCurrentSessionEmpty ? null : onCreateNew,
              icon: const Icon(Icons.add_comment_outlined),
              label: Text(l10n.chatNewConversation),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConversationHistoryItem extends StatelessWidget {
  const _ConversationHistoryItem({
    required this.item,
    required this.selected,
    required this.onSelect,
    required this.onRename,
    required this.onDelete,
  });

  final ConversationSummary item;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.28,
        children: [
          CustomSlidableAction(
            onPressed: (actionContext) {
              Slidable.of(actionContext)?.close();
              onDelete();
            },
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.only(
              left: AppSizes.s,
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.errorBackground,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: colors.errorIcon.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.delete,
                    color: colors.errorIcon,
                    size: AppSizes.iconM,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.delete,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.errorIcon,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.l,
            vertical: AppSizes.m,
          ),
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: selected ? colors.primaryMain : colors.neutralSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? colors.primaryMain
                  : colors.neutralBorder.withValues(alpha: 0.5),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Material(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : colors.neutralSurface,
                shape: CircleBorder(
                  side: BorderSide(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.3)
                        : colors.neutralBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.chat_bubble_rounded,
                    size: 20.0,
                    color: selected
                        ? Colors.white
                        : colors.neutralTextSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: selected ? Colors.white : colors.neutralTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
