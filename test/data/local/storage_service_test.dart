import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/data/local/storage_service.dart';

import '../../mocks/platform/secure_storage_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageTestController storage;
  late StorageService service;

  setUp(() {
    storage = SecureStorageTestController();
    storage.install();
    service = StorageService();
  });

  tearDown(() {
    storage.uninstall();
  });

  test('save and read stored values', () async {
    await service.saveToken('access-1', 'refresh-1');
    await service.saveUserId('user-1');
    await service.saveLanguageCode('vi');

    expect(await service.getAccessToken(), 'access-1');
    expect(await service.getRefreshToken(), 'refresh-1');
    expect(await service.getUserId(), 'user-1');
    expect(await service.getLanguageCode(), 'vi');
  });

  test('clearStorage and clearStorageAll remove only expected keys', () async {
    await service.saveToken('access-1', 'refresh-1');
    await service.saveUserId('user-1');
    await service.saveLanguageCode('vi');

    await service.clearStorage();

    expect(await service.getAccessToken(), isNull);
    expect(await service.getRefreshToken(), isNull);
    expect(await service.getUserId(), 'user-1');
    expect(await service.getLanguageCode(), 'vi');

    await service.clearStorageAll();

    expect(await service.getAccessToken(), isNull);
    expect(await service.getRefreshToken(), isNull);
    expect(await service.getUserId(), isNull);
    expect(await service.getLanguageCode(), 'vi');
  });
}