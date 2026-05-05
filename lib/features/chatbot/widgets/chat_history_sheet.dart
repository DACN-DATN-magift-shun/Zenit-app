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
  });

  final List<ConversationSummary> conversations;
  final String? activeConversationId;
  final VoidCallback onCreateNew;
  final ValueChanged<ConversationSummary> onSelect;
  final ValueChanged<ConversationSummary> onRename;
  final ValueChanged<ConversationSummary> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

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
                  itemBuilder: (context, index) {
                    final item = conversations[index];
                    final selected = item.id == activeConversationId;

                    return _ConversationHistoryItem(
                      item: item,
                      selected: selected,
                      onSelect: () => onSelect(item),
                      onRename: () => onRename(item),
                      onDelete: () => onDelete(item),
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
              onPressed: onCreateNew,
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
    final formattedDate = _formatDate(item.updatedAt);

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          CustomSlidableAction(
            onPressed: (actionContext) {
              Slidable.of(actionContext)?.close();
              onDelete();
            },
            backgroundColor: colors.neutralBackground,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: AppSizes.s,
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.errorBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
              ),
              child: Text(
                l10n.delete,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.errorIcon,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          CustomSlidableAction(
            onPressed: (actionContext) {
              Slidable.of(actionContext)?.close();
              onRename();
            },
            backgroundColor: colors.neutralBackground,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: AppSizes.s,
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.neutralSurface,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
              ),
              child: Text(
                l10n.edit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.neutralTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
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
            color: selected ? colors.secondaryShade : colors.neutralBackground,
            border: Border(
              bottom: BorderSide(color: colors.neutralBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Material(
                color: selected ? colors.secondaryMain : colors.neutralSurface,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Symbols.chat_bubble_rounded,
                    size: AppSizes.iconL,
                    color: selected
                        ? colors.secondaryText
                        : colors.neutralTextSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: colors.neutralTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate == null
                          ? l10n.unknown
                          : l10n.chatUpdatedAt(formattedDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.neutralTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}
