import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/core/widgets/authenticated_network_image.dart';

import '../../mocks/platform/secure_storage_test_helper.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
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

  testWidgets('public image URLs do not add auth headers', (tester) async {
    const url = 'https://d3abc.cloudfront.net/image.png';

    await tester.pumpWidget(
      _buildApp(
        const AuthenticatedNetworkImage(
          imageUrl: url,
          errorBuilder: _imageErrorBuilder,
        ),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    final networkImage = image.image as NetworkImage;

    expect(networkImage.url, url);
    expect(networkImage.headers, isNull);
  });

  testWidgets('private image URLs add bearer auth headers', (tester) async {
    storage = SecureStorageTestController(initialValues: {
      StorageService.accessTokenKey: 'token-123',
    });
    storage.install();

    const url = 'https://api.example.com/private/image.png';

    await tester.pumpWidget(
      _buildApp(
        const AuthenticatedNetworkImage(
          imageUrl: url,
          errorBuilder: _imageErrorBuilder,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    final networkImage = image.image as NetworkImage;

    expect(networkImage.url, url);
    expect(networkImage.headers?['Authorization'], 'Bearer token-123');
  });
}

Widget _imageErrorBuilder(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) {
  return const SizedBox.shrink();
}