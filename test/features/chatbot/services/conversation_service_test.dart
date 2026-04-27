import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/chatbot/services/conversation_service.dart';

import '../../../mocks/features/chatbot/services/conversation_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late ConversationService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = ConversationService(apiClient: apiClient);
  });

  test('getConversations unwraps data payload', () async {
    when(
      () => apiClient.get(ApiEndpoints.conversations, queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: conversationListData));

    final result = await service.getConversations(pageSize: 10);

    expect(result.items.length, 1);
    expect(result.items.first.id, 'conv1');
  });

  test('deleteConversation throws on empty id', () async {
    expect(() => service.deleteConversation('  '), throwsException);
  });
}
