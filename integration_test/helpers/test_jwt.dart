import 'dart:convert';

String buildJwtToken({required int expiresInSeconds}) {
  final nowInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final payload = <String, dynamic>{'exp': nowInSeconds + expiresInSeconds};

  final headerPart = _base64Url(<String, dynamic>{'alg': 'HS256', 'typ': 'JWT'});
  final payloadPart = _base64Url(payload);

  // Signature is not validated by AuthService, so a fixed placeholder is enough for tests.
  return '$headerPart.$payloadPart.signature';
}

String _base64Url(Map<String, dynamic> data) {
  return base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
}
