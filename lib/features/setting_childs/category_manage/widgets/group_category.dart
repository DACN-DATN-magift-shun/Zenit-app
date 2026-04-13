import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';

class DashedBorderCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderCirclePainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addOval(rect);
    final dashPath = Path();

    for (var metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

class GroupCategory extends StatelessWidget {
  const GroupCategory({
    super.key,
    required this.title,
    required this.titleChipColor,
    required this.chipIcon,
    required this.items,
    this.onAdd,
    this.showAddButton = true,
  });

  final String title;
  final Color titleChipColor;
  final IconData chipIcon;
  final List<Widget> items;
  final VoidCallback? onAdd;
  final bool showAddButton;

  @override
  Widget build(BuildContext context) {
    final gridItems = <Widget>[...items];
    if (showAddButton) {
      gridItems.add(_buildAddButton(context));
    }

    return Card(
      elevation: 0, // M3 filled cards have 0 elevation
      margin: const EdgeInsets.only(top: AppSizes.s),
      color: const Color(0xFFD2E4FF),
      // color: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // Chuẩn M3 cho các box
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MATERIAL 3 TITLE ROW
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: titleChipColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(chipIcon, size: 24, color: titleChipColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4 columns fixed grid to match desired category layout.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gridItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 16,
                childAspectRatio: 0.74,
              ),
              itemBuilder: (context, index) => Center(child: gridItems[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              painter: DashedBorderCirclePainter(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.4),
                strokeWidth: 1.5,
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Center(
                  child: Icon(
                    Symbols.add_rounded,
                    fill: 1.0,
                    weight: 400,
                    grade: 0.25,
                    size: AppSizes.textXXXL,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.2,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
