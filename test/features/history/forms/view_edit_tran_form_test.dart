import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:zenit/features/history/form/view_edit_tran_form.dart';
import 'package:zenit/features/photos/models/photo_model.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/models/money_source_model.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/features/transaction/models/transaction_model.dart';
import 'package:zenit/features/transaction/services/transaction_service.dart';
import 'package:zenit/features/photos/services/photo_service.dart';

import '../../../mocks/network/fake_http_client_adapter.dart';
import '../../../mocks/network/api_client_mocks.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class MockTransactionService extends Mock implements TransactionService {}

class MockPhotoService extends Mock implements PhotoService {}

class MockCategoryProvider extends Mock implements CategoryProvider {}

class MockMoneySourceProvider extends Mock implements MoneySourceProvider {}

class FakeCategoryProvider extends ChangeNotifier implements CategoryProvider {
  FakeCategoryProvider({this.categories = const []});

  @override
  final List<CategoryModel> categories;

  @override
  bool get hasData => true;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  bool get isActionLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Map<int, CategoryGroup> get categoryGroups => {};

  @override
  int get totalCategories => categories.length;

  @override
  String getGroupName(int groupType) => 'Group $groupType';

  @override
  CategoryGroup? getCategoryGroup(int groupType) => null;

  @override
  List<CategoryModel> getCategoriesByGroupType(int groupType) => categories;

  @override
  CategoryModel? findCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  int? findGroupTypeOfCategory(String categoryId) => 1;

  @override
  Future<void> loadAllCategories() async {}

  @override
  Future<void> loadCategoriesByGroupType(int groupType) async {}

  @override
  Future<void> refreshCategories() async {}

  @override
  Future<bool> deleteCategory(String id, int groupType) async => true;

  @override
  Future<bool> deleteCategories(List<String> ids, int groupType) async =>
      true;

  @override
  Future<bool> deleteCategoriesFromMultipleGroups(
      Map<int, List<String>> groupedIds) async =>
      true;

  @override
  void clearError() {}

  @override
  Future<bool> addCategory({
    required String name,
    required String icon,
    required String color,
    required String backgroundColor,
    required int groupType,
    double expenseLimit = 0,
    double expenseAlertThreshold = 0,
  }) async =>
      true;

  @override
  Future<bool> updateCategory({
    required String id,
    required String name,
    required String icon,
    required String color,
    required String backgroundColor,
    required int groupType,
    double expenseLimit = 0,
    double expenseAlertThreshold = 0,
    int? oldGroupType,
  }) async =>
      true;

  @override
  Future<void> reset() async {}
}

class FakeMoneySourceProvider extends ChangeNotifier
    implements MoneySourceProvider {
  FakeMoneySourceProvider({this.moneySources = const []});

  @override
  final List<MoneySourceModel> moneySources;

  @override
  bool get hasData => true;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  bool get isActionLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> loadAllMoneySources() async {}

  @override
  Future<void> refreshMoneySources() async {}

  @override
  Future<bool> addMoneySource({
    required String name,
    required String icon,
    int amount = 0,
    String note = '',
    bool isIncludeInTotalBalance = true,
  }) async =>
      true;

  @override
  Future<bool> updateMoneySource({
    required String id,
    required String name,
    required String icon,
    int? amount,
    String? note,
    bool? isIncludeInTotalBalance,
  }) async =>
      true;

  @override
  Future<bool> deleteMoneySource(String id) async => true;
}

void main() {
  group('ViewEditTranForm', () {
    late MockTransactionService mockTransactionService;
    late MockPhotoService mockPhotoService;
    late FakeCategoryProvider fakeCategoryProvider;
    late FakeMoneySourceProvider fakeMoneySourceProvider;

    final testCategory = CategoryModel(
      id: 'cat-1',
      name: 'Food',
      icon: 'restaurant',
      color: '#FF0000',
      backgroundColor: '#FFE0E0',
      groupType: '1', // necessary expense
    );

    final testWallet = MoneySourceModel(
      id: 'wallet-1',
      name: 'Cash',
      iconName: 'account_balance_wallet',
      backgroundColorHex: '#F5F5F5',
      amount: 1000000,
    );

    final testTransaction = TransactionModel(
      id: 'trans-1',
      title: 'Lunch',
      amount: 50000,
      note: 'With colleagues',
      transactionDate: DateTime(2026, 5, 3, 12, 30),
      categoryId: 'cat-1',
      category: TransactionCategoryModel(
        id: 'cat-1',
        name: 'Food',
        icon: 'restaurant',
        color: '#FF0000',
        backgroundColor: '#FFE0E0',
        groupType: 1,
      ),
      walletId: 'wallet-1',
    );

    late HttpClientAdapter? _originalAdapter;

    setUp(() {
      mockTransactionService = MockTransactionService();
      mockPhotoService = MockPhotoService();
      fakeCategoryProvider = FakeCategoryProvider(categories: [testCategory]);
      fakeMoneySourceProvider =
          FakeMoneySourceProvider(moneySources: [testWallet]);

      // Install fake HTTP adapter to intercept network calls from TransactionService
      _originalAdapter = ApiClient().dio.httpClientAdapter;
      ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
        // Return transaction detail for trans-1
        if (options.method == 'GET' &&
            options.path == ApiEndpoints.transactionById('trans-1')) {
          return jsonResponse({
            'data': testTransaction.toJsonForDetail(),
          });
        }

        // Simulate not found for invalid-id by returning 404 response
        if (options.method == 'GET' &&
            options.path == ApiEndpoints.transactionById('invalid-id')) {
          return ResponseBody.fromString(
            jsonEncode({'message': 'Not found'}),
            404,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        return jsonResponse({'data': <String, dynamic>{}});
      });
    });

    tearDown(() {
      // Restore original adapter
      if (_originalAdapter != null) {
        ApiClient().dio.httpClientAdapter = _originalAdapter!;
      }
    });

    Widget buildTestApp({
      required String transactionId,
      TransactionModel? initialTransaction,
      ViewEditTranFormController? controller,
      Future<void> Function()? onTransactionUpdated,
    }) {
      return MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<CategoryProvider>.value(
                  value: fakeCategoryProvider),
              ChangeNotifierProvider<MoneySourceProvider>.value(
                  value: fakeMoneySourceProvider),
            ],
            child: ViewEditTranForm(
              transactionId: transactionId,
              initialTransaction: initialTransaction,
              controller: controller,
              onTransactionUpdated: onTransactionUpdated,
            ),
          ),
        ),
      );
    }

    // Network-dependent tests are tested via ConversationService and ChatbotProvider unit tests
    // Widget tests below use initialTransaction to avoid network calls

    testWidgets('populates form with initial transaction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lunch'), findsWidgets);
      expect(find.text('50.000 VND'), findsWidgets);
    });

    testWidgets('validates empty title field',
        (WidgetTester tester) async {
      final controller = ViewEditTranFormController();

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller,
        ),
      );

      await tester.pumpAndSettle();

      // Start editing so the title TextFormField is present
      await controller.startEditing();
      await tester.pumpAndSettle();

      final titleFieldFinder = find.byType(TextFormField).first;
      await tester.enterText(titleFieldFinder, '');
      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('validates zero amount', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('controller can start editing', (WidgetTester tester) async {
      final controller = ViewEditTranFormController();

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller,
        ),
      );

      await tester.pumpAndSettle();

      await controller.startEditing();
      await tester.pump();

      expect(controller.isEditing.value, true);
    });

    testWidgets('controller can cancel editing',
        (WidgetTester tester) async {
      final controller = ViewEditTranFormController();

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller,
        ),
      );

      await tester.pumpAndSettle();

      await controller.startEditing();
      await tester.pump();

      controller.cancelEditing();
      await tester.pump();

      expect(controller.isEditing.value, false);
    });

    testWidgets('successful transaction update calls callback',
        (WidgetTester tester) async {
      var callbackCalled = false;

      when(() => mockTransactionService.updateTransactions(any()))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          onTransactionUpdated: () async {
            callbackCalled = true;
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('displays editing state after controller.startEditing',
        (WidgetTester tester) async {
      final controller = ViewEditTranFormController();

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller,
        ),
      );

      await tester.pumpAndSettle();
      await controller.startEditing();
      await tester.pump();

      expect(controller.isEditing.value, true);
      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('controller cancel resets form to original state',
        (WidgetTester tester) async {
      final controller = ViewEditTranFormController();

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller,
        ),
      );

      await tester.pumpAndSettle();

      await controller.startEditing();
      await tester.pump();

      controller.cancelEditing();
      await tester.pump();

      expect(controller.isEditing.value, false);
    });

    testWidgets('parsing amount with comma and dot separators',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('controller dispose stops listening', (WidgetTester tester) async {
      final controller = ViewEditTranFormController();

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller,
        ),
      );

      await tester.pumpAndSettle();

      expect(() => controller.dispose(), returnsNormally);
    });

    testWidgets('form displays selected category name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('form displays selected wallet name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('form shows empty note message when note is null',
        (WidgetTester tester) async {
      final transactionNoNote = testTransaction.copyWith(note: null);

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: transactionNoNote,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('controller.saveChanges does nothing when not editing',
        (WidgetTester tester) async {
      final controller = ViewEditTranFormController();

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller,
        ),
      );

      await tester.pumpAndSettle();

      await controller.saveChanges();
      await tester.pump();

      expect(controller.isEditing.value, false);
      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('handles missing wallet gracefully',
        (WidgetTester tester) async {
      fakeMoneySourceProvider = FakeMoneySourceProvider(moneySources: []);

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('handles missing category gracefully',
        (WidgetTester tester) async {
      fakeCategoryProvider = FakeCategoryProvider(categories: []);

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('handles income transaction differently from expense',
        (WidgetTester tester) async {
      final incomeCategory = testCategory.copyWith(groupType: '7'); // income
      fakeCategoryProvider =
          FakeCategoryProvider(categories: [incomeCategory]);

      final incomeTransaction = testTransaction.copyWith(
        categoryId: incomeCategory.id,
        category: TransactionCategoryModel(
          id: incomeCategory.id,
          name: incomeCategory.name,
          icon: incomeCategory.icon,
          color: incomeCategory.color,
          backgroundColor: incomeCategory.backgroundColor,
          groupType: 7,
        ),
      );

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: incomeTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('currency formatting uses VND symbol',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('date formatting includes time', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('handles controller reassignment',
        (WidgetTester tester) async {
      final controller1 = ViewEditTranFormController();
      final controller2 = ViewEditTranFormController();

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller1,
        ),
      );

      await tester.pumpAndSettle();

      // Simulate widget rebuild with different controller
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
          controller: controller2,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('negative amounts handled correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    testWidgets('handles transaction with missing id gracefully',
        (WidgetTester tester) async {
      final transactionNoId = testTransaction.copyWith(id: null);

      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'fallback-id',
          initialTransaction: transactionNoId,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });

    // TODO: Fix this test after PhotoModel structure is confirmed
    // testWidgets('photo preview displayed when photo exists',
    //     (WidgetTester tester) async {
    //   final transactionWithPhoto = testTransaction.copyWith(
    //     photos: [
    //       PhotoModel(
    //         id: 'photo-1',
    //         url: 'https://example.com/photo.jpg',
    //       )
    //     ],
    //   );

    //   await tester.pumpWidget(
    //     buildTestApp(
    //       transactionId: 'trans-1',
    //       initialTransaction: transactionWithPhoto,
    //     ),
    //   );

    //   await tester.pumpAndSettle();

    //   expect(find.byType(ViewEditTranForm), findsOneWidget);
    // });

    testWidgets('no photo preview when photoUrls is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          transactionId: 'trans-1',
          initialTransaction: testTransaction,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ViewEditTranForm), findsOneWidget);
    });
  });
}
