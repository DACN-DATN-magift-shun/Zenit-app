import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/features/statistics/models/statistics_model.dart';

/// Widget hiển thị pie chart cho thống kê
class StatisticsPieChart extends StatefulWidget {
  final List<StatisticsGroupModel> groups;

  const StatisticsPieChart({
    super.key,
    required this.groups,
  });

  @override
  State<StatisticsPieChart> createState() => _StatisticsPieChartState();
}

class _StatisticsPieChartState extends State<StatisticsPieChart> {
  // Palette tươi sáng hơn để nổi bật trên nền sáng
  List<Color> get _groupColors => [
    const Color(0xFF4D96FF),
    const Color(0xFF6BCB77),
    const Color(0xFFFF6B6B),
    const Color(0xFFFFD93D),
    const Color(0xFFB983FF),
  ];

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups.where((group) => group.percentage > 0).toList();

    if (groups.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const horizontalPadding = 8.0;
        final calloutWidth = maxWidth < 360 ? 84.0 : 108.0;
        final leftColumnLeft = horizontalPadding;
        final rightColumnLeft = maxWidth - calloutWidth - horizontalPadding;
        final centerX = maxWidth / 2;

        final availableHalf = math.min(
          centerX - (leftColumnLeft + calloutWidth),
          rightColumnLeft - centerX,
        );
        final safeOuterRadius = math.max(32.0, availableHalf - 14.0);
        final chartSizeByGap = safeOuterRadius / 0.30;
        final chartSize = math
            .min(math.min(maxWidth * 0.62, 190.0), chartSizeByGap)
          .clamp(126.0, 190.0)
          .toDouble();

        final ringRadius = chartSize * 0.22;
        final ringStrokeWidth = chartSize * 0.16;
        final outerRadius = ringRadius + (ringStrokeWidth / 2);
        final innerRadius = ringRadius - (ringStrokeWidth / 2);
        final stackHeight = chartSize + 132;
        final center = Offset(maxWidth / 2, stackHeight / 2);

        final callouts = _buildCallouts(
          context,
          groups,
          stackHeight,
          center,
          outerRadius,
          calloutWidth,
          leftColumnLeft,
          rightColumnLeft,
        );

        return SizedBox(
          height: stackHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CalloutConnectorPainter(callouts),
                ),
              ),
              Align(
                child: SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: CustomPaint(
                    painter: _RoundedDonutPainter(
                      groups: groups,
                      colors: _groupColors,
                      ringRadius: ringRadius,
                      ringStrokeWidth: ringStrokeWidth,
                    ),
                  ),
                ),
              ),
              Align(
                child: Container(
                  width: math.max(24, innerRadius * 1.55),
                  height: math.max(24, innerRadius * 1.55),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F8FA),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              ...callouts.map((callout) => _buildCalloutWidget(context, callout)),
            ],
          ),
        );
      },
    );
  }

  List<_CalloutLayout> _buildCallouts(
    BuildContext context,
    List<StatisticsGroupModel> groups,
    double height,
    Offset center,
    double chartOuterRadius,
    double calloutWidth,
    double leftColumnLeft,
    double rightColumnLeft,
  ) {
    final total = groups.fold<double>(0, (sum, group) => sum + group.percentage);
    if (total <= 0) {
      return [];
    }

    const calloutHeight = 58.0;
    const minTopPadding = 8.0;
    const minGap = 8.0;

    final maxTop = height - calloutHeight - minTopPadding;

    var angle = -90.0;
    final drafts = <_CalloutDraft>[];

    for (final group in groups) {
      final sweep = (group.percentage / total) * 360;
      final mid = angle + sweep / 2;
      final rad = mid * math.pi / 180;
      final direction = Offset(math.cos(rad), math.sin(rad));
      final edge = center + direction * (chartOuterRadius + 8);
      final isRight = direction.dx >= 0;
      final top = (center.dy + direction.dy * (chartOuterRadius + 26)) - (calloutHeight / 2);

      final color = group.groupType < _groupColors.length
          ? _groupColors[group.groupType]
          : _groupColors.last;

      drafts.add(
        _CalloutDraft(
          group: group,
          isRightSide: isRight,
          sectionEdge: edge,
          preferredTop: top,
          color: color,
        ),
      );

      angle += sweep;
    }

    final rightDrafts = drafts.where((draft) => draft.isRightSide).toList()
      ..sort((a, b) => a.preferredTop.compareTo(b.preferredTop));
    final leftDrafts = drafts.where((draft) => !draft.isRightSide).toList()
      ..sort((a, b) => a.preferredTop.compareTo(b.preferredTop));

    List<double> resolveTops(List<_CalloutDraft> sideDrafts) {
      if (sideDrafts.isEmpty) {
        return [];
      }

      final tops = List<double>.filled(sideDrafts.length, 0);
      tops[0] = sideDrafts[0].preferredTop.clamp(minTopPadding, maxTop);

      for (int i = 1; i < sideDrafts.length; i++) {
        final desired = sideDrafts[i].preferredTop.clamp(minTopPadding, maxTop);
        tops[i] = math.max(desired, tops[i - 1] + calloutHeight + minGap);
      }

      if (tops.last > maxTop) {
        tops[tops.length - 1] = maxTop;
        for (int i = tops.length - 2; i >= 0; i--) {
          final upper = tops[i + 1] - calloutHeight - minGap;
          tops[i] = math.min(tops[i], upper);
        }

        if (tops.first < minTopPadding) {
          tops[0] = minTopPadding;
          for (int i = 1; i < tops.length; i++) {
            tops[i] = math.max(tops[i], tops[i - 1] + calloutHeight + minGap);
          }
        }
      }

      return tops;
    }

    final rightTops = resolveTops(rightDrafts);
    final leftTops = resolveTops(leftDrafts);
    final layouts = <_CalloutLayout>[];

    for (int i = 0; i < rightDrafts.length; i++) {
      final draft = rightDrafts[i];
      final rect = Rect.fromLTWH(rightColumnLeft, rightTops[i], calloutWidth, calloutHeight);
      final elbow = Offset(rect.left - 10, rect.center.dy - 8);
      layouts.add(
        _CalloutLayout(
          group: draft.group,
          isRightSide: true,
          sectionEdge: draft.sectionEdge,
          elbowPoint: elbow,
          labelRect: rect,
          color: draft.color,
        ),
      );
    }

    for (int i = 0; i < leftDrafts.length; i++) {
      final draft = leftDrafts[i];
      final rect = Rect.fromLTWH(leftColumnLeft, leftTops[i], calloutWidth, calloutHeight);
      final elbow = Offset(rect.right + 10, rect.center.dy - 8);
      layouts.add(
        _CalloutLayout(
          group: draft.group,
          isRightSide: false,
          sectionEdge: draft.sectionEdge,
          elbowPoint: elbow,
          labelRect: rect,
          color: draft.color,
        ),
      );
    }

    return layouts;
  }

  Widget _buildCalloutWidget(BuildContext context, _CalloutLayout callout) {
    final percentage = _formatPercentage(callout.group.percentage);
    final textColor = const Color(0xFF345166);

    return Positioned(
      left: callout.labelRect.left,
      top: callout.labelRect.top,
      width: callout.labelRect.width,
      height: callout.labelRect.height,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: callout.isRightSide ? Alignment.topLeft : Alignment.topRight,
        child: SizedBox(
          width: callout.labelRect.width,
          child: Column(
            crossAxisAlignment:
                callout.isRightSide ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD7E2E9),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: callout.color.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForGroup(callout.group.groupType),
                        size: 11,
                        color: callout.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _groupLabel(context, callout.group.groupType),
                maxLines: 2,
                textAlign: callout.isRightSide ? TextAlign.left : TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF7A8892),
                      fontWeight: FontWeight.w500,
                  height: 1.15,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _groupLabel(BuildContext context, int groupType) {
    switch (groupType) {
      case 0:
        return context.l10n.groupNecessary;
      case 1:
        return context.l10n.groupSavings;
      case 2:
        return _splitIntoTwoLines(context.l10n.groupSelfDevelopment);
      case 3:
        return context.l10n.groupEntertainment;
      case 4:
        return context.l10n.groupGiving;
      default:
        return 'Group $groupType';
    }
  }

  IconData _iconForGroup(int groupType) {
    switch (groupType) {
      case 0:
        return Icons.shopping_bag_rounded;
      case 1:
        return Icons.savings_rounded;
      case 2:
        return Icons.menu_book_rounded;
      case 3:
        return Icons.movie_rounded;
      case 4:
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  String _formatPercentage(double percentage) {
    if (percentage >= 10) {
      return percentage.round().toString();
    }
    if (percentage >= 1) {
      return percentage.toStringAsFixed(percentage % 1 == 0 ? 0 : 1);
    }
    return percentage.toStringAsFixed(1);
  }

  String _splitIntoTwoLines(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= 1) {
      return text;
    }

    final cut = (words.length / 2).ceil();
    final firstLine = words.take(cut).join(' ');
    final secondLine = words.skip(cut).join(' ');
    return '$firstLine\n$secondLine';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 80,
            color: AppColors.light.neutralTextDisable,
          ),
          const SizedBox(height: AppSizes.m),
          Text(
            'Chưa có dữ liệu thống kê',
            style: TextStyle(
              fontSize: AppSizes.textM,
              color: AppColors.light.neutralTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalloutLayout {
  final StatisticsGroupModel group;
  final bool isRightSide;
  final Offset sectionEdge;
  final Offset elbowPoint;
  final Rect labelRect;
  final Color color;

  const _CalloutLayout({
    required this.group,
    required this.isRightSide,
    required this.sectionEdge,
    required this.elbowPoint,
    required this.labelRect,
    required this.color,
  });
}

class _CalloutDraft {
  final StatisticsGroupModel group;
  final bool isRightSide;
  final Offset sectionEdge;
  final double preferredTop;
  final Color color;

  const _CalloutDraft({
    required this.group,
    required this.isRightSide,
    required this.sectionEdge,
    required this.preferredTop,
    required this.color,
  });
}

class _RoundedDonutPainter extends CustomPainter {
  final List<StatisticsGroupModel> groups;
  final List<Color> colors;
  final double ringRadius;
  final double ringStrokeWidth;

  const _RoundedDonutPainter({
    required this.groups,
    required this.colors,
    required this.ringRadius,
    required this.ringStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = groups.fold<double>(0, (sum, group) => sum + group.percentage);
    if (total <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    const gapAngle = 0.085; // radian
    var start = -math.pi / 2;

    for (final group in groups) {
      final sweep = (group.percentage / total) * math.pi * 2;
      final drawSweep = math.max(sweep - gapAngle, sweep * 0.55);
      final offset = (sweep - drawSweep) / 2;

      final color = group.groupType < colors.length
          ? colors[group.groupType]
          : colors.last;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringStrokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, start + offset, drawSweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RoundedDonutPainter oldDelegate) {
    return oldDelegate.groups != groups ||
        oldDelegate.colors != colors ||
        oldDelegate.ringRadius != ringRadius ||
        oldDelegate.ringStrokeWidth != ringStrokeWidth;
  }
}

class _CalloutConnectorPainter extends CustomPainter {
  final List<_CalloutLayout> callouts;

  const _CalloutConnectorPainter(this.callouts);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9D6DE)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final callout in callouts) {
      final target = Offset(
        callout.isRightSide ? callout.labelRect.left : callout.labelRect.right,
        callout.labelRect.center.dy - 8,
      );

      _drawDashedLine(canvas, paint, callout.sectionEdge, callout.elbowPoint);
      _drawDashedLine(canvas, paint, callout.elbowPoint, target);
    }
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final vector = end - start;
    final distance = vector.distance;
    if (distance == 0) {
      return;
    }

    final direction = vector / distance;
    const dashLength = 4.0;
    const gap = 3.0;
    var drawn = 0.0;

    while (drawn < distance) {
      final dashStart = start + direction * drawn;
      final dashEnd = start + direction * math.min(drawn + dashLength, distance);
      canvas.drawLine(dashStart, dashEnd, paint);
      drawn += dashLength + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _CalloutConnectorPainter oldDelegate) {
    return oldDelegate.callouts != callouts;
  }
}
