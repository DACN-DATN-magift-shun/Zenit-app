import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';
import '../../../mocks/features/chatbot/chat_models_mock_data.dart';
import '../../../mocks/json_source_mock.dart';

void main() {
  group('chat models', () {
    test('ConversationListResponse.fromJson parses items and meta', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(conversationListResponseMockJson);

      final response = ConversationListResponse.fromJson(source.value);

      expect(response.items.length, 1);
      expect(response.items.first.id, 'c1');
      expect(response.items.first.title, 'My conversation');
      expect(response.meta.totalItems, 1);
      expect(response.meta.page, 1);
    });

    test('ChatMessage.fromJson resolves assistant role by account id', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(assistantMessageMockJson);

      final message = ChatMessage.fromJson(source.value, currentUserId: 'user-1');

      expect(message.role, ChatMessageRole.assistant);
      expect(message.isMarkdown, true);
      expect(message.content, 'Hello from AI');
      expect(message.isUser, false);
    });

    test('ChatSuggestion.fromJson parses category and wallet payloads', () {
      final suggestion = ChatSuggestion.fromJson(<String, dynamic>{
        'category': 'Eating',
        'wallet': 'Tien mat me cho dung',
      });

      expect(suggestion.label, 'Eating');
      expect(suggestion.value, 'Tien mat me cho dung');
      expect(
        suggestion.displayText,
        'category: Eating, wallet: Tien mat me cho dung',
      );
    });

    test('ChatMessage.fromJson keeps category and wallet suggestions', () {
      final message = ChatMessage.fromJson(<String, dynamic>{
        'id': 'm1',
        'accountId': '00000000-0000-0000-0000-000000000001',
        'content': 'assistant message',
        'suggestions': [
          <String, dynamic>{
            'category': 'Eating',
            'wallet': 'Tien mat me cho dung',
          },
        ],
      });

      expect(message.suggestions, hasLength(1));
      expect(message.suggestions.first.label, 'Eating');
      expect(message.suggestions.first.value, 'Tien mat me cho dung');
    });

    test('ConversationDetail.fromJson maps messages list', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(conversationDetailMockJson);

      final detail = ConversationDetail.fromJson(source.value);

      expect(detail.id, 'conv-2');
      expect(detail.messages.length, 2);
      expect(detail.messages.first.conversationId, 'conv-2');
    });
  });
}
