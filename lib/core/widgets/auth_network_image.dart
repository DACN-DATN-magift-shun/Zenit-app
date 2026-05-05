import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zenit/data/network/api_client.dart';


class AuthNetworkImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context, Object error, StackTrace? stack)?
      errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  const AuthNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<AuthNetworkImage> createState() => _AuthNetworkImageState();
}

class _AuthNetworkImageState extends State<AuthNetworkImage> {
  late Future<Uint8List> _imageFuture;

  // Simple in-memory cache shared across all instances.
  static final Map<String, Uint8List> _cache = {};

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImage(widget.imageUrl);
  }

  @override
  void didUpdateWidget(covariant AuthNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageFuture = _loadImage(widget.imageUrl);
    }
  }

  Future<Uint8List> _loadImage(String url) async {
    // Return from cache if available.
    final cached = _cache[url];
    if (cached != null) {
      return cached;
    }

    final response = await ApiClient().dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = Uint8List.fromList(response.data!);

    // Cache the result (limit cache size to avoid memory issues).
    if (_cache.length > 100) {
      _cache.remove(_cache.keys.first);
    }
    _cache[url] = bytes;

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
              SizedBox(
                width: widget.width,
                height: widget.height,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(
              context,
              snapshot.error ?? Exception('No data'),
              null,
            );
          }
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          errorBuilder: (context, error, stack) {
            if (widget.errorBuilder != null) {
              return widget.errorBuilder!(context, error, stack);
            }
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      },
    );
  }
}

/// An [ImageProvider] that loads images with Authorization headers via Dio.
///
/// Use this where Flutter requires an [ImageProvider] (e.g. [CircleAvatar.backgroundImage]).
class AuthNetworkImageProvider extends ImageProvider<AuthNetworkImageProvider> {
  final String url;

  const AuthNetworkImageProvider(this.url);

  @override
  Future<AuthNetworkImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(
    AuthNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(_loadAsync(key, decode));
  }

  Future<ImageInfo> _loadAsync(
    AuthNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    final response = await ApiClient().dio.get<List<int>>(
      key.url,
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = Uint8List.fromList(response.data!);
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final codec = await decode(buffer);
    final frame = await codec.getNextFrame();

    return ImageInfo(image: frame.image);
  }

  @override
  bool operator ==(Object other) {
    if (other is AuthNetworkImageProvider) {
      return url == other.url;
    }
    return false;
  }

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'AuthNetworkImageProvider("$url")';
}
