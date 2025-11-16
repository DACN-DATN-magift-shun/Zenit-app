import 'package:flutter/material.dart';
import 'package:zenit/common/constants/theme/app_sizes.dart';
import 'package:zenit/common/utils/services/navigation_service.dart';
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
  Size get preferredSize =>
      Size.fromHeight(showSecondaryText && (secondaryText?.isNotEmpty ?? false) ? 110.0 : 72.0);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showReturnIcon)
              GestureDetector(
                onTap: onBack ?? () => NavigationService.instance.goBack(),
                child: const Padding(
                  padding: EdgeInsets.only(right: 12.0, top: 4.0),
                  child: Icon(Symbols.arrow_back_ios_new_rounded, size: AppSizes.iconM),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleLarge,
                  ),
                  if (showSecondaryText && (secondaryText?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        secondaryText!,
                        style: textTheme.titleMedium,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {NavigationService.instance.navigateTo('/');},
              icon: Icon(
                Symbols.notifications_rounded,
                size: AppSizes.iconM,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
