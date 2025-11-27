// define very base layout for app, secondary screens
import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_theme.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final PreferredSizeWidget? appBar;
  final bool safeArea;

  const BaseLayout({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.appBar,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      color: backgroundColor ?? Theme.of(context).extension<AppColorExtension>()!.neutralBackground,
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}