import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return BaseLayout(
      appBar: CommonAppBar(
        title: l10n.transferTitle,
        showReturnIcon: true,
        onBack: () => Navigator.pop(context),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.l),
          child: Text(
            l10n.comingSoon,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.neutralTextPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
