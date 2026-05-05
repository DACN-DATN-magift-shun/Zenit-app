import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/setting_childs/money_source_manage/forms/view_edit_money_source_form.dart';
import 'package:zenit/l10n/app_localizations.dart';

import '../../../../fixtures/features/setting_childs/money_source_manage/money_source_widget_fixtures.dart';
import '../../../../mocks/features/setting_childs/money_source_manage/money_source_provider_widget_mock.dart';
import '../../../../mocks/network/fake_http_client_adapter.dart';

final _binding = TestWidgetsFlutterBinding.ensureInitialized();

const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

Widget _buildApp(Widget child, {required MockMoneySourceProvider provider}) {
  return ChangeNotifierProvider<MockMoneySourceProvider>.value(
    value: provider,
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
      if (
        options.method == 'GET' &&
        options.path.contains(ApiEndpoints.walletById('w1'))
      ) {
        return jsonResponse(moneySourceWidgetCash.toJson());
      }

      return jsonResponse({}, statusCode: 404);
    });
  });

  tearDown(() {
    ApiClient().dio.httpClientAdapter = originalAdapter;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  testWidgets('ViewEditMoneySourceForm shows read-only details and edit mode', (
    tester,
  ) async {
    final provider = MockMoneySourceProvider();
    final isEditing = ValueNotifier<bool>(false);

    await tester.pumpWidget(
      _buildApp(
        ViewEditMoneySourceForm(
          moneySourceId: 'w1',
          isEditing: isEditing,
        ),
        provider: provider,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Wallet name'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('1.200đ'), findsOneWidget);
    expect(find.text('Pocket money'), findsOneWidget);

    isEditing.value = true;
    await tester.pumpAndSettle();

    expect(find.text('Money source name'), findsOneWidget);
    expect(find.text('Include in total balance'), findsOneWidget);
    expect(find.text('Select icon'), findsOneWidget);
    expect(find.text('Cash'), findsWidgets);

    isEditing.dispose();
  });
}