import 'package:flutter/material.dart';
import 'package:zenit/core/theme/app_sizes.dart';

// Dùng Generic <T> để có thể trả về String, Enum hay Object tùy thích
class CustomLongPressMenu<T> extends StatelessWidget {
  final Widget child;
  final List<PopupMenuEntry<T>> items;
  final Function(T) onSelected;
  final ShapeBorder? shape; // Để mày custom border, bo góc
  final Color? color;
  final double? elevation;

  const CustomLongPressMenu({
    super.key,
    required this.child,
    required this.items,
    required this.onSelected,
    this.shape,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    // Biến để lưu vị trí ngón tay khi nhấn xuống
    Offset tapPosition = Offset.zero;

    return GestureDetector(
      onLongPressStart: (details) {
        tapPosition = details.globalPosition;
      },
      onLongPress: () async {
        final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

        final selected = await showMenu<T>(
          context: context,
          position: RelativeRect.fromRect(
            Rect.fromCenter(
              center: tapPosition,
              width: 1,
              height: 1,
            ),
            Offset.zero & overlay.size,
          ),
          items: items,
          elevation: elevation ?? 8.0,
          // Đây là chỗ mày custom hình dạng, border này
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
              ),
          color: color ?? Theme.of(context).cardColor,
        );

        if (selected != null) {
          onSelected(selected);
        }
      },
      child: child,
    );
  }
}