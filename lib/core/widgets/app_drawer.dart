import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

/// A reusable drawer widget with customizable header and body.
/// 
/// Use [AppDrawer.show] to display the drawer as a modal bottom sheet
/// or side sheet depending on your needs.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.title,
    required this.body,
    this.titleStyle,
    this.headerActions,
    this.showCloseButton = true,
    this.onClose,
    this.width,
    this.height,
    this.padding,
    this.headerPadding,
    this.bodyPadding,
    this.backgroundColor,
    this.borderRadius,
    this.showDragHandle = false,
  });

  /// The title displayed in the header (left side)
  final String title;

  /// Custom style for the title text
  final TextStyle? titleStyle;

  /// The main content of the drawer
  final Widget body;

  /// Optional action buttons displayed in the header (right side)
  /// These are displayed before the close button
  final List<Widget>? headerActions;

  /// Whether to show the default close button
  final bool showCloseButton;

  /// Callback when the drawer is closed
  final VoidCallback? onClose;

  /// Custom width for the drawer (useful for side drawers)
  final double? width;

  /// Custom height for the drawer (useful for bottom sheets)
  final double? height;

  /// Padding for the entire drawer content
  final EdgeInsetsGeometry? padding;

  /// Padding for the header section
  final EdgeInsetsGeometry? headerPadding;

  /// Padding for the body section
  final EdgeInsetsGeometry? bodyPadding;

  /// Background color of the drawer
  final Color? backgroundColor;

  /// Border radius of the drawer
  final BorderRadiusGeometry? borderRadius;

  /// Whether to show a drag handle (useful for bottom sheets)
  final bool showDragHandle;

  /// Shows the drawer as a modal bottom sheet
  static Future<T?> showAsBottomSheet<T>({
    required BuildContext context,
    required String title,
    required Widget body,
    TextStyle? titleStyle,
    List<Widget>? headerActions,
    bool showCloseButton = true,
    VoidCallback? onClose,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? bodyPadding,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    bool showDragHandle = true,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.white,
      builder: (context) => AppDrawer(
        title: title,
        body: body,
        titleStyle: titleStyle,
        headerActions: headerActions,
        showCloseButton: showCloseButton,
        onClose: onClose ?? () => Navigator.of(context).pop(),
        height: height,
        padding: padding,
        headerPadding: headerPadding,
        bodyPadding: bodyPadding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius ?? const BorderRadius.vertical(
          top: Radius.circular(AppSizes.borderRadiusXLarge),
        ),
        showDragHandle: showDragHandle,
      ),
    );
  }

  /// Shows the drawer as a side sheet (from right)
  static Future<T?> showAsSideSheet<T>({
    required BuildContext context,
    required String title,
    required Widget body,
    TextStyle? titleStyle,
    List<Widget>? headerActions,
    bool showCloseButton = true,
    VoidCallback? onClose,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? bodyPadding,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: AppDrawer(
            title: title,
            body: body,
            titleStyle: titleStyle,
            headerActions: headerActions,
            showCloseButton: showCloseButton,
            onClose: onClose ?? () => Navigator.of(context).pop(),
            width: width ?? MediaQuery.of(context).size.width * 0.85,
            padding: padding,
            headerPadding: headerPadding,
            bodyPadding: bodyPadding,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius ?? const BorderRadius.horizontal(
              left: Radius.circular(AppSizes.borderRadiusXLarge),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final effectiveBackgroundColor = backgroundColor ?? Colors.white;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppSizes.borderRadiusLarge);
    final effectivePadding = padding ?? const EdgeInsets.all(AppSizes.l);
    final effectiveHeaderPadding = headerPadding ?? const EdgeInsets.only(bottom: AppSizes.l);
    final effectiveBodyPadding = bodyPadding ?? EdgeInsets.zero;

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
      ),
      child: SafeArea(
        child: Padding(
          padding: effectivePadding,
          child: Column(
            mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle (for bottom sheets)
              if (showDragHandle) _buildDragHandle(context),
              
              // Header
              Padding(
                padding: effectiveHeaderPadding,
                child: _buildHeader(context, colors),
              ),
              
              // Body
              height != null
                  ? Expanded(
                      child: Padding(
                        padding: effectiveBodyPadding,
                        child: body,
                      ),
                    )
                  : Padding(
                      padding: effectiveBodyPadding,
                      child: body,
                    ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Material for side sheet to handle touch events properly
    if (width != null) {
      content = Material(
        color: Colors.transparent,
        child: content,
      );
    }

    return content;
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.l),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).extension<AppColorExtension>()!.neutralBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppColorExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title (left side)
        Expanded(
          child: Text(
            title,
            style: titleStyle ?? TextStyle(
              fontSize: AppSizes.textL,
              fontWeight: FontWeight.w600,
              color: colors.neutralTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Actions (right side)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (headerActions != null) ...headerActions!,
            if (showCloseButton) ...[
              if (headerActions != null && headerActions!.isNotEmpty)
                const SizedBox(width: AppSizes.m),
              _buildCloseButton(context, colors),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context, AppColorExtension colors) {
    return GestureDetector(
      onTap: onClose ?? () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: colors.neutralBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        ),
        child: Icon(
          Symbols.cancel_rounded,
          size: AppSizes.iconL,
          weight: 900,
          color: colors.primaryActive,
        ),
      ),
    );
  }
}
