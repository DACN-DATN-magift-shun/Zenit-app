import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class SecureStorageTestController {
  SecureStorageTestController({Map<String, String?>? initialValues})
    : _values = <String, String?>{...?initialValues};

  static const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  final Map<String, String?> _values;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, _handleMethodCall);
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  }

  Map<String, String?> snapshot() {
    return Map<String, String?>.from(_values);
  }

  Future<dynamic> _handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'read':
        return _values[_readKey(methodCall.arguments)];
      case 'readAll':
        return Map<String, String?>.from(_values);
      case 'write':
        _values[_writeKey(methodCall.arguments)] = _writeValue(methodCall.arguments);
        return null;
      case 'delete':
        _values.remove(_readKey(methodCall.arguments));
        return null;
      case 'deleteAll':
        _values.clear();
        return null;
      case 'containsKey':
        return _values.containsKey(_readKey(methodCall.arguments));
      default:
        return null;
    }
  }

  String _readKey(Object? arguments) {
    if (arguments is Map) {
      return arguments['key'] as String;
    }

    return arguments.toString();
  }

  String _writeKey(Object? arguments) {
    if (arguments is Map) {
      return arguments['key'] as String;
    }

    return arguments.toString();
  }

  String? _writeValue(Object? arguments) {
    if (arguments is Map) {
      return arguments['value'] as String?;
    }

    return null;
  }
}