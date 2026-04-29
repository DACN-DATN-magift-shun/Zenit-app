import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/transfer/screen/transfer_screen.dart';
import 'package:zenit/features/transfer/providers/money_transfer_provider.dart';
import 'package:zenit/features/transfer/models/money_transfer_model.dart';
import 'package:zenit/features/transfer/services/money_transfer_service.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import '../../../mocks/features/setting_childs/money_source_manage/money_source_provider_mock_data.dart';
import '../../../mocks/network/fake_http_client_adapter.dart';

class FakeMoneyTransferService extends MoneyTransferService {
  FakeMoneyTransferService() : super();

  @override
  Future<MoneyTransferListResponse> getMoneyTransfers({DateTime? fromDate, DateTime? toDate, String? search, String? beforeId, required int pageSize, bool useCountTotal = true}) async {
    return MoneyTransferListResponse(
      items: [
        MoneyTransferModel(
          id: 't-1',
          fromWalletId: 'w1',
          toWalletId: 'w2',
          amount: 123,
          transferDate: DateTime.now(),
          note: 'note',
        ),
      ],
      meta: MoneyTransferMetaModel(
        totalItems: 1,
        pageCount: 1,
        page: 1,
        pageSize: pageSize,
      ),
    );
  }
}

class FakeTransferScreenProvider extends MoneyTransferProvider {
  FakeTransferScreenProvider({
    bool isLoading = false,
    String? errorMessage,
    List<MoneyTransferModel> transfers = const <MoneyTransferModel>[],
  }) : super(moneyTransferService: FakeMoneyTransferService()) {
    _isLoading = isLoading;
    _errorMessage = errorMessage;
    _transfers = List<MoneyTransferModel>.of(transfers);
  }

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _searchKeyword = '';
  List<MoneyTransferModel> _transfers = const <MoneyTransferModel>[];

  int loadTransfersCalls = 0;
  int refreshTransfersCalls = 0;
  int setSearchKeywordCalls = 0;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isActionLoading => _isActionLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  String get searchKeyword => _searchKeyword;

  @override
  List<MoneyTransferModel> get transfers => _transfers;

  @override
  bool get hasData => _transfers.isNotEmpty;

  @override
  Future<void> loadTransfers({String? search, int pageSize = 100}) async {
    loadTransfersCalls += 1;
  }

  @override
  Future<void> refreshTransfers() async {
    refreshTransfersCalls += 1;
  }

  @override
  Future<void> setSearchKeyword(String keyword) async {
    setSearchKeywordCalls += 1;
    _searchKeyword = keyword.trim();
    notifyListeners();
  }
}

Widget _buildApp(Widget child, MoneyTransferProvider provider) {
  return ChangeNotifierProvider(
    create: (_) => LocaleProvider(),
    child: MaterialApp(
      theme: lightTheme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<MoneyTransferProvider>.value(
        value: provider,
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('TransferScreen shows loading state', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        const Scaffold(body: TransferScreen()),
        FakeTransferScreenProvider(isLoading: true),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TransferScreen shows error state', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        const Scaffold(body: TransferScreen()),
        FakeTransferScreenProvider(errorMessage: 'boom'),
      ),
    );

    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('TransferScreen shows empty state and search clear branch', (
    tester,
  ) async {
    final provider = FakeTransferScreenProvider();

    await tester.pumpWidget(_buildApp(const Scaffold(body: TransferScreen()), provider));
    await tester.pump();

    expect(find.text('No transfer transactions yet'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  transfer note  ');
    await tester.pump();

    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(provider.setSearchKeywordCalls, 1);
    expect(provider.searchKeyword, isEmpty);
  });

  testWidgets('TransferScreen opens add drawer with wallets', (tester) async {
    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      if (options.path == ApiEndpoints.wallets) {
        return jsonResponse(
          moneySourceProviderInitialList.map((item) => item.toJson()).toList(),
        );
      }

      return jsonResponse(<String, dynamic>{}, statusCode: 404);
    });

    final provider = FakeTransferScreenProvider();

    await tester.pumpWidget(
      _buildApp(const Scaffold(body: TransferScreen()), provider),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // Wait for wallets to finish loading (form shows a progress indicator while loading).
    var attempts = 0;
    while (attempts < 30 && tester.any(find.byType(CircularProgressIndicator))) {
      await tester.pump(const Duration(milliseconds: 100));
      attempts += 1;
    }

    expect(find.text('Add transfer'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
