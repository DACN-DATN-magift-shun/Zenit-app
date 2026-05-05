import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/core/theme/app_theme.dart';

class AuthLanguageToggle extends StatelessWidget {
  const AuthLanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final appColors = Theme.of(context).extension<AppColorExtension>()!;
        final isVi = localeProvider.locale.languageCode == 'vi';

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            final nextLocale = isVi ? const Locale('en') : const Locale('vi');
            localeProvider.setLocale(nextLocale);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'vi',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isVi
                        ? appColors.primaryActive
                        : appColors.neutralTextDisable,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 22,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: appColors.primaryText.withValues(alpha: 0.12),
                    border: Border.all(
                      color: appColors.neutralBorder.withValues(alpha: 0.45),
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: isVi
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appColors.primaryActive,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'en',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: !isVi
                        ? appColors.primaryActive
                        : appColors.neutralTextDisable,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
