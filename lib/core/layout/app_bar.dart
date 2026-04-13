import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/services/navigation_service.dart';
import 'package:material_symbols_icons/symbols.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // mainText (bắt buộc)
  final String? secondaryText; // secondary text (tùy chọn)
  final bool showReturnIcon; // có hiển thị nút quay về không
  final bool showSecondaryText; // có hiển thị secondaryText không
  final VoidCallback? onBack; // callback khi nhấn quay về
  final List<Widget>? actions; // các action ở bên phải
  final VoidCallback? onNotificationTap; // callback khi nhấn icon thông báo

  const CommonAppBar({
    super.key,
    required this.title,
    this.secondaryText,
    this.showReturnIcon = false,
    this.showSecondaryText = false,
    this.onBack,
    this.actions,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    showSecondaryText && (secondaryText?.isNotEmpty ?? false) ? 110.0 : 72.0,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasSecondary =
        showSecondaryText && (secondaryText?.isNotEmpty ?? false);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          crossAxisAlignment: hasSecondary
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (showReturnIcon)
              GestureDetector(
                onTap: onBack ?? () => NavigationService.instance.goBack(),
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 12.0,
                    top: hasSecondary ? 2.0 : 0,
                  ),
                  child: Icon(
                    Symbols.arrow_back_ios_new_rounded,
                    size: AppSizes.iconM,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: hasSecondary
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge,
                  ),
                  if (hasSecondary)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        secondaryText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed:
                  onNotificationTap ??
                  () {
                    NavigationService.instance.navigateTo('/notifications');
                  },
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              padding: EdgeInsets.zero,
              icon: Icon(
                Symbols.notifications_rounded,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
