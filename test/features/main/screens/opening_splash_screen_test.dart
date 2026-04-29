import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/main/screens/opening_splash_screen.dart';
import 'package:zenit/core/theme/app_theme.dart';
import '../../../mocks/platform/secure_storage_test_helper.dart';
import 'package:zenit/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';

class TestAssetBundle extends CachingAssetBundle {
  static final Uint8List _kTransparentImage = Uint8List.fromList([
    0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
    0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,
    0x89,0x00,0x00,0x00,0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
    0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,
    0x42,0x60,0x82
  ]);

  @override
  Future<ByteData> load(String key) async {
    return ByteData.view(_kTransparentImage.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '';
  }

  @override
  Future<T> loadStructuredData<T>(String key, Future<T> Function(String) parser) async {
    if (key.contains('AssetManifest')) {
      return <String, List<String>>{} as T;
    }
    final str = await loadString(key);
    return parser(str);
  }

  @override
  Future<T> loadStructuredBinaryData<T>(String key, FutureOr<T> Function(ByteData) parser) async {
    if (key.contains('AssetManifest')) {
      final encoded = const StandardMessageCodec().encodeMessage(<String, List<String>>{});
      if (encoded == null) return <String, List<String>>{} as T;
      final result = parser(encoded);
      if (result is Future<T>) return await result;
      return result as T;
    }
    final data = await load(key);
    final result = parser(data);
    if (result is Future<T>) return await result;
    return result as T;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorageTestController storage;

  setUp(() {
    storage = SecureStorageTestController();
    storage.install();
  });

  tearDown(() {
    storage.uninstall();
  });

  testWidgets('OpeningSplashScreen navigates to login when not authenticated', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: MaterialApp(
            theme: lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routes: {
              '/login': (context) => const Scaffold(body: Text('login')),
              '/home': (context) => const Scaffold(body: Text('home')),
            },
            home: const OpeningSplashScreen(),
          ),
        ),
      ),
    );

    // pump enough time for the splash delay
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('OpeningSplashScreen navigates to home when authenticated', (tester) async {
    storage = SecureStorageTestController(initialValues: { 'ACCESS_TOKEN': 't' });
    storage.install();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: MaterialApp(
            theme: lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routes: {
              '/login': (context) => const Scaffold(body: Text('login')),
              '/home': (context) => const Scaffold(body: Text('home')),
            },
            home: const OpeningSplashScreen(),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}
