import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/statistics/models/statistics_model.dart';
import 'package:zenit/features/statistics/widgets/date_range_selector.dart';
import 'package:zenit/features/statistics/widgets/statistics_legend.dart';
import 'package:zenit/features/statistics/widgets/statistics_pie_chart.dart';
import 'package:zenit/l10n/app_localizations.dart';

import '../../../fixtures/features/statistics/statistics_widget_fixtures.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('Statistics widgets', () {
    testWidgets('DateRangeSelector shows labels and handles taps', (
      tester,
    ) async {
      var startTapCount = 0;
      var endTapCount = 0;

      await tester.pumpWidget(
        _buildApp(
          DateRangeSelector(
            startDate: DateTime(2026, 4, 1),
            endDate: DateTime(2026, 4, 27),
            onStartDateTap: () => startTapCount += 1,
            onEndDateTap: () => endTapCount += 1,
          ),
        ),
      );

      expect(find.text('From'), findsOneWidget);
      expect(find.text('01/04/2026'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('27/04/2026'), findsOneWidget);

      await tester.tap(find.text('01/04/2026'));
      await tester.pump();
      await tester.tap(find.text('27/04/2026'));
      await tester.pump();

      expect(startTapCount, 1);
      expect(endTapCount, 1);
    });

    testWidgets('StatisticsLegend renders labels and amounts', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          StatisticsLegend(groups: <StatisticsGroupModel>[statisticsWidgetNecessaryGroup]),
        ),
      );

      expect(find.text('Necessary'), findsOneWidget);
      expect(find.text('Assets'), findsNothing);
      expect(find.textContaining('1.200'), findsOneWidget);
      expect(find.textContaining('800'), findsNothing);
    });

    testWidgets('StatisticsLegend hides itself for empty groups', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(const StatisticsLegend(groups: [])));

      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('StatisticsPieChart shows empty state when no data', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(const SizedBox(width: 360, child: StatisticsPieChart(groups: []))),
      );

      expect(find.text('Chưa có dữ liệu thống kê'), findsOneWidget);
    });

    testWidgets('StatisticsPieChart renders callouts for groups', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          SizedBox(
            width: 420,
            child: StatisticsPieChart(
              groups: <StatisticsGroupModel>[
                statisticsWidgetNecessaryGroup,
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('60%'), findsOneWidget);
      expect(find.text('Necessary'), findsOneWidget);
      expect(find.text('Assets'), findsNothing);
    });
  });
}