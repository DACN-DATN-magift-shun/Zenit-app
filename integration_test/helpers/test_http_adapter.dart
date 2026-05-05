import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class StaticHttpRule {
  const StaticHttpRule({
    required this.matches,
    this.statusCode = 200,
    this.data,
    this.dataBuilder,
  });

  final bool Function(RequestOptions options) matches;
  final int statusCode;
  final dynamic data;
  final dynamic Function()? dataBuilder;
}

class StaticHttpClientAdapter implements HttpClientAdapter {
  StaticHttpClientAdapter(this.rules);

  final List<StaticHttpRule> rules;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (requestStream != null) {
      await requestStream.drain<void>();
    }

    final rule = rules.firstWhere(
      (item) => item.matches(options),
      orElse: () {
        throw StateError('No static response for \'${options.method} ${options.path}\'');
      },
    );

    final resolvedData = rule.dataBuilder?.call() ?? rule.data;
    final body = resolvedData == null ? '' : jsonEncode(resolvedData);
    return ResponseBody.fromString(
      body,
      rule.statusCode,
      headers: const {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}
