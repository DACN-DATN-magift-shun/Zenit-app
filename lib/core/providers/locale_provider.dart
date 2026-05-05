import 'package:flutter/material.dart';
import 'package:zenit/data/local/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('vi'),
  ];

  final StorageService _storageService = StorageService();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> loadSavedLocale() async {
    final savedCode = await _storageService.getLanguageCode();

    if (savedCode == null || !_isSupported(savedCode)) {
      return;
    }

    _locale = Locale(savedCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode) || locale == _locale) {
      return;
    }

    _locale = locale;
    await _storageService.saveLanguageCode(locale.languageCode);
    notifyListeners();
  }

  bool _isSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }
}
