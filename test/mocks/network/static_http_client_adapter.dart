import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class StaticHttpResponseRule {
  const StaticHttpResponseRule({
    required this.matches,
    required this.statusCode,
    this.data,
  });

  final bool Function(RequestOptions requestOptions) matches;
  final int statusCode;
  final dynamic data;
}

class StaticHttpClientAdapter implements HttpClientAdapter {
  StaticHttpClientAdapter(this.rules);

  final List<StaticHttpResponseRule> rules;
  RequestOptions? lastRequestOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions requestOptions,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = requestOptions;

    final rule = rules.firstWhere(
      (item) => item.matches(requestOptions),
      orElse: () {
        throw StateError('No static response for ${requestOptions.method} ${requestOptions.path}');
      },
    );

    final body = rule.data == null ? '' : jsonEncode(rule.data);
    return ResponseBody.fromString(
      body,
      rule.statusCode,
      headers: const {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}