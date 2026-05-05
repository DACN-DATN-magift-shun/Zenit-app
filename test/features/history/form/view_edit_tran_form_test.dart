import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/history/form/view_edit_tran_form.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';
import 'package:zenit/features/setting_childs/category_manage/providers/category_provider.dart';
import 'package:zenit/features/setting_childs/money_source_manage/providers/money_source_provider.dart';
import 'package:zenit/l10n/app_localizations.dart';

import '../../../fixtures/features/history/transaction_form_fixtures.dart';
import '../../../fixtures/features/setting_childs/money_source_manage/money_source_widget_fixtures.dart';
import '../../../mocks/features/setting_childs/category_manage/category_provider_widget_mock.dart';
import '../../../mocks/features/setting_childs/money_source_manage/money_source_provider_widget_mock.dart';
import '../../../mocks/network/fake_http_client_adapter.dart';

final _binding = TestWidgetsFlutterBinding.ensureInitialized();

const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

Widget _buildApp({
  required Widget child,
  required CategoryProvider categoryProvider,
  required MoneySourceProvider moneySourceProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
      ChangeNotifierProvider<MoneySourceProvider>.value(
        value: moneySourceProvider,
      ),
    ],
    child: MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  _binding;

  late dynamic originalAdapter;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (methodCall) async {
          switch (methodCall.method) {
            case 'read':
            case 'readAll':
            case 'delete':
            case 'deleteAll':
            case 'containsKey':
              return null;
            default:
              return null;
          }
        });

    originalAdapter = ApiClient().dio.httpClientAdapter;
    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      if (options.method == 'PATCH' &&
          options.path.contains(ApiEndpoints.transactions)) {
        return jsonResponse({}, statusCode: 200);
      }

      return jsonResponse({}, statusCode: 404);
    });
  });

  tearDown(() {
    ApiClient().dio.httpClientAdapter = originalAdapter;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  testWidgets('ViewEditTranForm shows details, edits and saves', (
    tester,
  ) async {
    final categoryProvider = MockCategoryProvider();
    when(() => categoryProvider.hasData).thenReturn(true);
    when(() => categoryProvider.categories).thenReturn([
      CategoryModel(
        id: 'c1',
        name: 'Food',
        icon: 'restaurant',
        color: '#111111',
        backgroundColor: '#EEEEEE',
        groupType: '0',
      ),
    ]);

    final moneySourceProvider = MockMoneySourceProvider();
    when(() => moneySourceProvider.hasData).thenReturn(true);
    when(
      () => moneySourceProvider.moneySources,
    ).thenReturn(buildMoneySourceWidgetList());

    final controller = ViewEditTranFormController();
    var updatedCount = 0;

    await tester.pumpWidget(
      _buildApp(
        child: ViewEditTranForm(
          transactionId: 'tx1',
          initialTransaction: transactionFormInitialTransaction,
          controller: controller,
          onTransactionUpdated: () async {
            updatedCount += 1;
          },
        ),
        categoryProvider: categoryProvider,
        moneySourceProvider: moneySourceProvider,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('team meal'), findsOneWidget);

    await controller.startEditing();
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(3));

    await tester.enterText(find.byType(TextFormField).at(0), 'Lunch updated');
    await tester.enterText(find.byType(TextFormField).at(1), '150000');
    await tester.enterText(find.byType(TextFormField).at(2), 'updated note');

    print("before save");

    await controller.saveChanges();

    print("after save");

    await tester.pumpAndSettle();

    print("after settle");

    expect(updatedCount, 1);
    expect(find.text('Lunch updated'), findsOneWidget);
    expect(controller.isEditing.value, isFalse);

    controller.dispose();
  }, skip: true);
}
