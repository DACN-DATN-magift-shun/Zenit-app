import 'package:flutter/material.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
	const NotificationScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final colors = Theme.of(context).extension<AppColorExtension>()!;

		return BaseLayout(
			appBar: CommonAppBar(
				title: 'Thông báo',
				showReturnIcon: true,
				onBack: () {
					Navigator.pop(context);
				},
			),
			child: Center(
				child: Padding(
					padding: const EdgeInsets.all(AppSizes.l),
					child: Text(
						'Coming soon',
						style: Theme.of(context).textTheme.bodyLarge?.copyWith(
							color: colors.neutralTextPrimary,
						),
						textAlign: TextAlign.center,
					),
				),
			),
		);
	}
}
