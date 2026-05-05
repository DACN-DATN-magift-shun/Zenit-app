import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/providers/locale_provider.dart';

import '../../mocks/platform/secure_storage_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageTestController storage;
  late LocaleProvider provider;

  setUp(() {
    storage = SecureStorageTestController();
    storage.install();
    provider = LocaleProvider();
  });

  tearDown(() {
    storage.uninstall();
  });

  test('loadSavedLocale applies a supported saved locale', () async {
    await provider.setLocale(const Locale('vi'));

    final loadedProvider = LocaleProvider();
    await loadedProvider.loadSavedLocale();

    expect(loadedProvider.locale.languageCode, 'vi');
  });

  test('loadSavedLocale ignores unsupported or missing values', () async {
    final loadedProvider = LocaleProvider();

    await loadedProvider.loadSavedLocale();

    expect(loadedProvider.locale.languageCode, 'en');

    await provider.setLocale(const Locale('vi'));
    await provider.setLocale(const Locale('en'));

    await loadedProvider.loadSavedLocale();

    expect(loadedProvider.locale.languageCode, 'en');
  });

  test('setLocale persists supported locales and notifies listeners', () async {
    var notified = false;
    provider.addListener(() {
      notified = true;
    });

    await provider.setLocale(const Locale('vi'));

    expect(provider.locale.languageCode, 'vi');
    expect(notified, isTrue);
    expect(storage.snapshot()['LANGUAGE_CODE'], 'vi');
  });
}
