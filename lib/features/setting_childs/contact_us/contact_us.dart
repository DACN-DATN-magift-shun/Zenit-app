import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_flash.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const String _supportPhoneDisplay = '+84 123 456 789';
  static const String _supportPhoneDial = '+84123456789';
  static const String _supportEmail = 'support@zenit.app';

  Future<void> _openPhoneApp(BuildContext context) {
    return _launchUri(context, Uri(scheme: 'tel', path: _supportPhoneDial));
  }

  Future<void> _openEmailApp(BuildContext context) {
    return _launchUri(
      context,
      Uri(
        scheme: 'mailto',
        path: _supportEmail,
        queryParameters: const {'subject': 'Zenit Support'},
      ),
    );
  }

  Future<void> _launchUri(BuildContext context, Uri uri) async {
    final l10n = context.l10n;
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && context.mounted) {
      AppFlash.error(context, l10n.unableOpenApp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BaseLayout(
      appBar: CommonAppBar(
        title: l10n.supportCenterTitle,
        showReturnIcon: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          const SizedBox(height: AppSizes.s),
          _ContactActionTile(
            title: l10n.contactViaEmail,
            onTap: () => _openEmailApp(context),
          ),
          _ContactActionTile(
            title: l10n.contactViaPhone,
            onTap: () => _openPhoneApp(context),
          ),
          const SizedBox(height: AppSizes.sectionSpacing),
          Text(
            l10n.contactInfo(_supportEmail, _supportPhoneDisplay),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).extension<AppColorExtension>()!.neutralTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactActionTile extends StatelessWidget {
  const _ContactActionTile({required this.title, required this.onTap});

  final String title;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXSmall),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.elementSpacing,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.neutralTextPrimary,
                  ),
                ),
              ),
              Icon(
                Symbols.chevron_right_rounded,
                size: AppSizes.iconL,
                color: colors.neutralTextPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
