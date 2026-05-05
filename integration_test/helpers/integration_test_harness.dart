import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/data/network/api_client.dart';

import 'test_http_adapter.dart';
import 'test_secure_storage.dart';

class IntegrationTestHarness {
  IntegrationTestHarness._(this.storageController);

  final TestSecureStorageController storageController;

  static IntegrationTestHarness setup({
    List<StaticHttpRule> rules = const <StaticHttpRule>[],
    Map<String, String?> initialStorage = const <String, String?>{},
    bool useIntegrationTestBinding = false,
    bool installHttpAdapter = true,
  }) {
    if (useIntegrationTestBinding) {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    } else {
      TestWidgetsFlutterBinding.ensureInitialized();
    }

    final storageController = TestSecureStorageController(
      initialValues: initialStorage,
    );
    storageController.install();

    final apiClient = ApiClient();
    apiClient.resetForTest();
    if (installHttpAdapter) {
      apiClient.setHttpClientAdapterForTest(StaticHttpClientAdapter(rules));
    }

    final harness = IntegrationTestHarness._(storageController);

    addTearDown(() async {
      harness.dispose();
    });

    return harness;
  }

  void dispose() {
    storageController.uninstall();
    ApiClient().resetForTest();
  }

  static Map<String, String?> unauthenticatedStorage() {
    return <String, String?>{};
  }

  static Map<String, String?> authenticatedStorage({
    required String accessToken,
    String refreshToken = 'refresh-token-test',
  }) {
    return <String, String?>{
      StorageService.accessTokenKey: accessToken,
      StorageService.refreshTokenKey: refreshToken,
    };
  }
}
