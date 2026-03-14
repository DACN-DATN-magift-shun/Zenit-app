import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && context.mounted) {
      AppFlash.error(context, 'Unable to open this app right now.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: CommonAppBar(
        title: 'Support center',
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
            title: 'Contact us via Email',
            onTap: () => _openEmailApp(context),
          ),
          _ContactActionTile(
            title: 'Contact us via Phone',
            onTap: () => _openPhoneApp(context),
          ),
          const SizedBox(height: AppSizes.sectionSpacing),
          Text(
            'Email: $_supportEmail\nPhone: $_supportPhoneDisplay',
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
