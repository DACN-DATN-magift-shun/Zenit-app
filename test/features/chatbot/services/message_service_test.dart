import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/features/chatbot/services/message_service.dart';

import '../../../mocks/features/chatbot/services/message_service_mock_data.dart';
import '../../../mocks/network/api_client_mocks.dart';

void main() {
  late MockApiClient apiClient;
  late MessageService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    apiClient = MockApiClient();
    service = MessageService(apiClient: apiClient);
  });

  test('sendMessage returns parsed response', () async {
    when(() => apiClient.post(ApiEndpoints.messages, data: any(named: 'data')))
        .thenAnswer((_) async => buildResponse(statusCode: 200, data: sendMessageData));

    final result = await service.sendMessage(conversationId: 'conv1', text: 'hello');

    expect(result, isNotNull);
    expect(result!.chatbotMessage, 'hello');
  });

  test('getMessages parses list from wrapped payload', () async {
    when(
      () => apiClient.get(ApiEndpoints.messages, queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => buildResponse(statusCode: 200, data: messageListData));

    final result = await service.getMessages(conversationId: 'conv1', pageSize: 20);

    expect(result.items.length, 1);
    expect((result.items.first as Map<String, dynamic>)['id'], 'm1');
  });
}
