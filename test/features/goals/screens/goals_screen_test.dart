import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/features/goals/screen/goals_screen.dart';
import 'package:zenit/features/goals/providers/goals_provider.dart';
import 'package:zenit/features/goals/models/goal_model.dart';
import 'package:zenit/features/goals/services/goals_service.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/providers/locale_provider.dart';

class FakeGoalsService extends GoalsService {
  FakeGoalsService() : super();

  @override
  Future<List<GoalModel>> getGoals({String? search, String? beforeId, int pageSize = 100, bool useCountTotal = false}) async {
    return [
      GoalModel(
        id: 'g-1',
        name: 'Buy laptop',
        targetAmount: 1000,
        currentAmount: 250,
        backgroundColor: '#D2E4FF',
        icon: 'savings',
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        status: GoalStatus.ongoing,
      ),
    ];
  }
}

void main() {
  testWidgets('GoalsScreen shows summary and list with mock provider', (tester) async {
    final provider = GoalsProvider(goalsService: FakeGoalsService());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: MaterialApp(
          theme: lightTheme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChangeNotifierProvider<GoalsProvider>.value(
            value: provider,
            child: const Scaffold(body: GoalsScreen()),
          ),
        ),
      ),
    );

    // trigger initial load; avoid pumpAndSettle timeout from animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // After loadGoals runs, we expect some UI pieces
    expect(find.textContaining('Goal progress'), findsWidgets);
    expect(find.text('Buy laptop'), findsOneWidget);
  });
}
