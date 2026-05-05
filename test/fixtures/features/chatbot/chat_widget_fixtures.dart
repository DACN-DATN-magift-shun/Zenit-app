import 'package:zenit/features/chatbot/widgets/chat_action_chips_row.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';

final chatWidgetUserMessage = ChatMessage(
  id: 'm1',
  conversationId: 'c1',
  accountId: 'u1',
  role: ChatMessageRole.user,
  content: 'Hello AI',
  createdAt: DateTime(2026, 4, 21, 7),
);

final chatWidgetAssistantMessage = ChatMessage(
  id: 'm2',
  conversationId: 'c1',
  accountId: '00000000-0000-0000-0000-000000000001',
  role: ChatMessageRole.assistant,
  content: 'Line 1\n\n- Item 1\n- Item 2',
  createdAt: DateTime(2026, 4, 21, 7, 5),
  isMarkdown: true,
);

final chatWidgetConversation = ConversationSummary(
  id: 'c1',
  title: 'My conversation',
  updatedAt: DateTime(2026, 4, 20, 10),
);

final chatWidgetConversationTwo = ConversationSummary(
  id: 'c2',
  title: 'Second conversation',
  updatedAt: DateTime(2026, 4, 22, 9),
);

List<ConversationSummary> buildChatWidgetConversations() {
  return <ConversationSummary>[
    chatWidgetConversation,
    chatWidgetConversationTwo,
  ];
}

List<ChatActionChipItem> buildChatWidgetChips(void Function(String) onTap) {
  return <ChatActionChipItem>[
    ChatActionChipItem(label: 'One', onPressed: () => onTap('One')),
    ChatActionChipItem(label: 'Two', onPressed: () => onTap('Two')),
  ];
}