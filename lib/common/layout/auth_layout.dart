import 'package:flutter/material.dart';
import 'package:zenit/common/constants/theme/app_theme.dart';

/// A reusable layout for authentication screens.
///
/// Provides a decorative header area (title + optional subtitle), a white
/// rounded card body where the `child` is placed, and an optional footer slot
/// (for actions like primary button, links, etc.). Designed to be flexible
/// and easy to drop into signup / login / reset-password screens.
class AuthLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final double maxWidth;

  const AuthLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
    this.maxWidth = 420,
    this.headerPortion = 0.35,
    this.drawerPeekPortion = 0.25,
    this.leading,
  });

  /// Fraction of the screen height the header occupies (0..1).
  final double headerPortion;

  /// Fraction of the screen height where the drawer begins (0..1).
  final double drawerPeekPortion;

  /// Optional widget placed in the header (e.g. back button).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorExtension>()!;
    final size = MediaQuery.of(context).size;
    final statusBar = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // make scaffold background the primary color so the header visually
      // covers the full screen (including system UI areas)
      backgroundColor: appColors.primaryMain,
      body: Stack(
        children: [
          // Header area (full-bleed)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * headerPortion + statusBar,
            child: Container(
              padding: EdgeInsets.only(top: statusBar + 20),
              color: appColors.primaryMain,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null)
                    Align(alignment: Alignment.topLeft, child: Padding(padding: const EdgeInsets.only(left: 12.0), child: leading)),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(color: appColors.primaryText, fontWeight: FontWeight.w700),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(subtitle!, textAlign: TextAlign.center, style: theme.textTheme.headlineLarge?.copyWith(color: appColors.primaryText)),
                  ],
                ],
              ),
            ),
          ),

          // Drawer / card that sits above the bottom and overlaps the header
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: size.height * drawerPeekPortion + statusBar,
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -3)),
                ],
              ),
              child: SafeArea(
                top: false,
                bottom: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          child,
                          if (footer != null) ...[
                            const SizedBox(height: 18),
                            footer!,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
