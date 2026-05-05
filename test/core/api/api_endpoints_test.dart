import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/api/api_endpoints.dart';

void main() {
  test('categoryById and transactionById build expected URLs', () {
    expect(ApiEndpoints.categoryById('123'), '${ApiEndpoints.categoryBaseUrl}Categories/123');
    expect(ApiEndpoints.transactionById('t1'), '${ApiEndpoints.transactionBaseUrl}Transactions/t1');
  });

  test('timeouts are configured', () {
    expect(ApiEndpoints.connectionTimeout, greaterThan(0));
    expect(ApiEndpoints.receiveTimeout, greaterThan(0));
  });

  test('messages endpoint uses base url', () {
    expect(ApiEndpoints.messages, '${ApiEndpoints.baseUrl}Messages');
  });
}
