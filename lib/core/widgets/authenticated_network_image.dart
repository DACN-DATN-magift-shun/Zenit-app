import 'package:flutter/material.dart';
import 'package:zenit/data/local/storage_service.dart';

/// Render network image with bearer token for protected endpoints.
class AuthenticatedNetworkImage extends StatelessWidget {
  const AuthenticatedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
  });

  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  bool _isPublicImageUrl(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.toLowerCase() ?? '';
    return host.contains('amazonaws.com') || host.contains('cloudfront.net');
  }

  @override
  Widget build(BuildContext context) {
    if (_isPublicImageUrl(imageUrl)) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    }

    return FutureBuilder<String?>(
      future: StorageService().getAccessToken(),
      builder: (context, snapshot) {
        final token = snapshot.data;
        final headers = (token != null && token.isNotEmpty)
            ? <String, String>{'Authorization': 'Bearer $token'}
            : null;

        return Image.network(
          imageUrl,
          fit: fit,
          width: width,
          height: height,
          headers: headers,
          errorBuilder: errorBuilder,
        );
      },
    );
  }
}
