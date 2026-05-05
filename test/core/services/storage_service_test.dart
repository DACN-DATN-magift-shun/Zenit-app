import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/data/local/storage_service.dart';

import '../../mocks/platform/secure_storage_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageTestController storageController;
  final service = StorageService();

  setUp(() {
    storageController = SecureStorageTestController();
    storageController.install();
  });

  tearDown(() {
    storageController.uninstall();
  });

  test('saveToken and getAccessToken/getRefreshToken', () async {
    await service.saveToken('a-token', 'r-token');

    expect(storageController.snapshot()[StorageService.accessTokenKey], 'a-token');
    expect(storageController.snapshot()[StorageService.refreshTokenKey], 'r-token');

    final access = await service.getAccessToken();
    final refresh = await service.getRefreshToken();

    expect(access, 'a-token');
    expect(refresh, 'r-token');
  });

  test('saveUserId and getUserId', () async {
    await service.saveUserId('user-123');
    expect(await service.getUserId(), 'user-123');
  });

  test('clearStorage clears tokens', () async {
    await service.saveToken('a', 'b');
    await service.clearStorage();

    expect(storageController.snapshot()[StorageService.accessTokenKey], isNull);
    expect(storageController.snapshot()[StorageService.refreshTokenKey], isNull);
  });

  test('clearStorageAll clears all keys', () async {
    await service.saveToken('a', 'b');
    await service.saveUserId('uid');
    await service.clearStorageAll();

    expect(storageController.snapshot()[StorageService.accessTokenKey], isNull);
    expect(storageController.snapshot()[StorageService.refreshTokenKey], isNull);
    expect(storageController.snapshot()[StorageService.userIdKey], isNull);
  });
}
