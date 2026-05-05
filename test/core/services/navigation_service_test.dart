import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/services/navigation_service.dart';

Widget _buildApp() {
  return MaterialApp(
    navigatorKey: NavigationService.instance.navigatorKey,
    initialRoute: '/home',
    routes: {
      '/home': (_) => const Scaffold(body: Text('home')),
      '/details': (_) => const Scaffold(body: Text('details')),
      '/settings': (_) => const Scaffold(body: Text('settings')),
      '/login': (_) => const Scaffold(body: Text('login')),
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('navigateTo pushes a new route', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    NavigationService.instance.navigateTo('/details');
    await tester.pumpAndSettle();

    expect(find.text('details'), findsOneWidget);
  });

  testWidgets('pushReplacement swaps the current route', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    NavigationService.instance.pushReplacement('/settings');
    await tester.pumpAndSettle();

    expect(find.text('settings'), findsOneWidget);
    expect(find.text('home'), findsNothing);
  });

  testWidgets('pushAndRemoveUntil clears the stack', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    NavigationService.instance.navigateTo('/details');
    await tester.pumpAndSettle();

    NavigationService.instance.pushAndRemoveUntil('/login');
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
    expect(NavigationService.instance.goBack(), isFalse);
  });

  testWidgets('goBack pops when the stack can pop', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    NavigationService.instance.navigateTo('/details');
    await tester.pumpAndSettle();

    expect(NavigationService.instance.goBack(), isTrue);
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}