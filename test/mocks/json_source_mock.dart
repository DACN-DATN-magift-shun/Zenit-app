import 'package:mocktail/mocktail.dart';
export 'package:mocktail/mocktail.dart' show when;

abstract class JsonSource {
  dynamic get value;
}

class MockJsonSource extends Mock implements JsonSource {}
