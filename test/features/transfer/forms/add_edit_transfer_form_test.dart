import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/transfer/forms/add_edit_transfer_form.dart';
import 'package:zenit/l10n/app_localizations.dart';

import '../../../fixtures/features/setting_childs/money_source_manage/money_source_widget_fixtures.dart';
import '../../../fixtures/features/transfer/transfer_form_fixtures.dart';
import '../../../mocks/network/fake_http_client_adapter.dart';

final _binding = TestWidgetsFlutterBinding.ensureInitialized();

const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

Widget _buildApp(Widget child) {
  return MaterialApp(
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
  });

  setUp(() {
    originalAdapter = ApiClient().dio.httpClientAdapter;
    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      if (
        options.method == 'GET' &&
        options.path.contains(ApiEndpoints.wallets)
      ) {
        return jsonResponse({
          'items': buildMoneySourceWidgetList()
              .map((wallet) => wallet.toJson())
              .toList(),
          'meta': {
            'totalItems': 2,
            'pageCount': 1,
            'page': 1,
            'pageSize': 100,
          },
        });
      }

      return jsonResponse({}, statusCode: 404);
    });
  });

  tearDown(() {
    ApiClient().dio.httpClientAdapter = originalAdapter;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  testWidgets('AddEditTransferForm submits transfer data', (tester) async {
    final controller = AddEditTransferFormController();
    TransferFormData? submittedData;

    await tester.pumpWidget(
      _buildApp(
        AddEditTransferForm(
          controller: controller,
          initialTransfer: transferFormInitialTransfer,
          onSubmit: (data) async {
            submittedData = data;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('From wallet'), findsOneWidget);
    expect(find.text('To wallet'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Transfer date'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bank').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '250000');
    await tester.enterText(find.byType(TextFormField).at(1), 'move balance');

    await controller.submit();
    await tester.pumpAndSettle();

    expect(submittedData?.fromWalletId, 'w1');
    expect(submittedData?.toWalletId, 'w2');
    expect(submittedData?.amount, 250000);
    expect(submittedData?.note, 'move balance');
  });

  testWidgets('AddEditTransferForm prefills transfer details in edit mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        AddEditTransferForm(
          initialTransfer: transferFormInitialTransfer,
          onSubmit: (_) async {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('From wallet'), findsOneWidget);
    expect(find.text('To wallet'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Bank'), findsOneWidget);

    final amountField = tester.widget<TextFormField>(find.byType(TextFormField).at(0));
    final noteField = tester.widget<TextFormField>(find.byType(TextFormField).at(1));

    expect(amountField.controller?.text, '100000');
    expect(noteField.controller?.text, 'move funds');
  });
}