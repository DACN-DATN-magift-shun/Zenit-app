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

class FakeGoalsService extends GoalsService {
  FakeGoalsService() : super();

  @override
  Future<List<GoalModel>> getGoals({
    String? search,
    String? beforeId,
    int pageSize = 100,
    bool useCountTotal = false,
  }) async {
    return [
      GoalModel(
        id: 'g-1',
        name: 'Buy laptop',
        targetAmount: 10000000,
        currentAmount: 2500000,
        backgroundColor: '#D2E4FF',
        icon: 'savings',
        createdAt: DateTime(2026, 4, 1),
        dueDate: DateTime(2026, 8, 1),
        note: 'saving plan',
        status: GoalStatus.ongoing,
      ),
      GoalModel(
        id: 'g-2',
        name: 'Trip',
        targetAmount: 5000000,
        currentAmount: 5000000,
        backgroundColor: '#E7F8D2',
        icon: 'flight',
        createdAt: DateTime(2026, 3, 1),
        dueDate: DateTime(2026, 7, 1),
        status: GoalStatus.completed,
      ),
    ];
  }
}

class FakeGoalsProvider extends GoalsProvider {
  FakeGoalsProvider({
    List<GoalModel> initialGoals = const <GoalModel>[],
    bool isLoading = false,
    String? errorMessage,
    bool keepLoadingOnLoad = false,
  }) : super(goalsService: FakeGoalsService()) {
    _allGoals = List<GoalModel>.of(initialGoals);
    _isLoading = isLoading;
    _errorMessage = errorMessage;
    _keepLoadingOnLoad = keepLoadingOnLoad;
  }

  List<GoalModel> _allGoals = const <GoalModel>[];
  bool _isLoading = false;
  String? _errorMessage;
  bool _keepLoadingOnLoad = false;
  GoalStatus? _selectedStatusFilter;
  String _searchKeyword = '';

  int loadGoalsCalls = 0;
  int refreshGoalsCalls = 0;
  int setSearchKeywordCalls = 0;
  int setStatusFilterCalls = 0;

  @override
  List<GoalModel> get goals {
    return _allGoals.where((goal) {
      if (_selectedStatusFilter == null) {
        return true;
      }
      return goal.status == _selectedStatusFilter;
    }).toList();
  }

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  GoalStatus? get selectedStatusFilter => _selectedStatusFilter;

  @override
  String get searchKeyword => _searchKeyword;

  @override
  bool get hasData => goals.isNotEmpty;

  @override
  double get amountProgress => 0.25;

  @override
  int get totalTargetAmount => 15000000;

  @override
  int get totalCurrentAmount => 5000000;

  @override
  double get completionRate => goals.isEmpty ? 0 : 0.5;

  @override
  int get completedGoalsCount => goals.where((item) => item.status == GoalStatus.completed).length;

  @override
  Future<void> loadGoals({String? search, int pageSize = 100}) async {
    loadGoalsCalls += 1;
    if (!_keepLoadingOnLoad) {
      _isLoading = false;
    }
    _searchKeyword = search ?? _searchKeyword;
    notifyListeners();
  }

  @override
  Future<void> refreshGoals() async {
    refreshGoalsCalls += 1;
  }

  @override
  Future<void> setSearchKeyword(String keyword) async {
    setSearchKeywordCalls += 1;
    _searchKeyword = keyword.trim();
    notifyListeners();
  }

  @override
  Future<void> setStatusFilter(GoalStatus? status) async {
    setStatusFilterCalls += 1;
    _selectedStatusFilter = status;
    notifyListeners();
  }
}

Widget _buildApp(Widget child, GoalsProvider provider, {Locale locale = const Locale('en')}) {
  return ChangeNotifierProvider(
    create: (_) => LocaleProvider(),
    child: MaterialApp(
      theme: lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<GoalsProvider>.value(
        value: provider,
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('GoalsScreen shows loading state', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        const Scaffold(body: GoalsScreen()),
        FakeGoalsProvider(isLoading: true, keepLoadingOnLoad: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('GoalsScreen shows error state', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        const Scaffold(body: GoalsScreen()),
        FakeGoalsProvider(errorMessage: 'boom'),
      ),
    );

    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('GoalsScreen shows search branch', (tester) async {
    final provider = FakeGoalsProvider(
      initialGoals: [
        GoalModel(
          id: 'g-1',
          name: 'Buy laptop',
          targetAmount: 10000000,
          currentAmount: 2500000,
          backgroundColor: '#D2E4FF',
          icon: 'savings',
          createdAt: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 8, 1),
          note: 'saving plan',
          status: GoalStatus.ongoing,
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(const Scaffold(body: GoalsScreen()), provider));

    await tester.pump();

    expect(find.text('Buy laptop'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  laptop  ');
    await tester.pump();

    expect(provider.setSearchKeywordCalls, 1);
    expect(provider.searchKeyword, 'laptop');
  });

  testWidgets('GoalsScreen shows summary, filters and opens add drawer', (tester) async {
    final provider = FakeGoalsProvider(
      initialGoals: [
        GoalModel(
          id: 'g-1',
          name: 'Buy laptop',
          targetAmount: 10000000,
          currentAmount: 2500000,
          backgroundColor: '#D2E4FF',
          icon: 'savings',
          createdAt: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 8, 1),
          note: 'saving plan',
          status: GoalStatus.ongoing,
        ),
        GoalModel(
          id: 'g-2',
          name: 'Trip',
          targetAmount: 5000000,
          currentAmount: 5000000,
          backgroundColor: '#E7F8D2',
          icon: 'flight',
          createdAt: DateTime(2026, 3, 1),
          dueDate: DateTime(2026, 7, 1),
          status: GoalStatus.completed,
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(const Scaffold(body: GoalsScreen()), provider));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Goal progress'), findsWidgets);
    expect(find.text('Buy laptop'), findsOneWidget);
    expect(find.text('Trip'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pump();
    expect(provider.setStatusFilterCalls, 1);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Add goal'), findsOneWidget);
  });

  testWidgets('GoalsScreen opens goal details drawer from list item', (tester) async {
    final provider = FakeGoalsProvider(
      initialGoals: [
        GoalModel(
          id: 'g-1',
          name: 'Buy laptop',
          targetAmount: 10000000,
          currentAmount: 2500000,
          backgroundColor: '#D2E4FF',
          icon: 'savings',
          createdAt: DateTime(2026, 4, 1),
          dueDate: DateTime(2026, 8, 1),
          note: 'saving plan',
          status: GoalStatus.ongoing,
        ),
      ],
    );

    await tester.pumpWidget(
      _buildApp(const Scaffold(body: GoalsScreen()), provider),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Buy laptop'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Goal details'), findsOneWidget);
  });
}
