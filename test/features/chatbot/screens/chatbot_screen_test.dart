import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/providers/locale_provider.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';
import 'package:zenit/features/chatbot/providers/chatbot_provider.dart';
import 'package:zenit/features/chatbot/screen/chatbot_screen.dart';
import 'package:zenit/l10n/app_localizations.dart';

class FakeChatbotProvider extends ChatbotProvider {
  FakeChatbotProvider({
    bool isInitializing = false,
    bool isSending = false,
    String? activeConversationId,
    List<ConversationSummary> conversations = const <ConversationSummary>[],
    List<ChatMessage> messages = const <ChatMessage>[],
    Set<String> confirmMessageIds = const <String>{},
  })  : _isInitializing = isInitializing,
        _isSending = isSending,
        _activeConversationId = activeConversationId,
        _conversations = List<ConversationSummary>.of(conversations),
        _messages = List<ChatMessage>.of(messages),
        _confirmMessageIds = Set<String>.of(confirmMessageIds);

  bool _isInitializing = false;
  bool _isSending = false;
  String? _activeConversationId;
  final List<ConversationSummary> _conversations;
  final List<ChatMessage> _messages;
  final Set<String> _confirmMessageIds;

  int refreshConversationsCalls = 0;
  int createNewConversationCalls = 0;
  int sendMessageCalls = 0;
  int selectConversationCalls = 0;

  @override
  bool get isInitializing => _isInitializing;

  @override
  bool get isSending => _isSending;

  @override
  String? get activeConversationId => _activeConversationId;

  @override
  List<ConversationSummary> get conversations => _conversations;

  @override
  List<ChatMessage> get activeMessages => _messages;

  @override
  Future<void> initialize() async {
    _isInitializing = false;
    notifyListeners();
  }

  @override
  Future<void> refreshConversations() async {
    refreshConversationsCalls += 1;
  }

  @override
  Future<void> createNewConversation() async {
    createNewConversationCalls += 1;
  }

  @override
  Future<void> selectConversation(String conversationId) async {
    selectConversationCalls += 1;
    _activeConversationId = conversationId;
    notifyListeners();
  }

  @override
  Future<void> sendMessage(String rawText) async {
    sendMessageCalls += 1;
  }

  @override
  bool shouldShowAcceptButton(String messageId) => _confirmMessageIds.contains(messageId);
}

Widget _buildApp(Widget child, ChatbotProvider provider) {
  return ChangeNotifierProvider<ChatbotProvider>.value(
    value: provider,
    child: ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: MaterialApp(
        theme: lightTheme,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

void main() {
  testWidgets('ChatbotScreen shows empty conversation state', (tester) async {
    await tester.pumpWidget(
      _buildApp(const ChatbotScreen(), FakeChatbotProvider()),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Zenos'), findsOneWidget);
    expect(
      find.text(
        'Start a conversation. Messages are sent to the backend and AI replies are fetched from message history.',
      ),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    expect(find.byTooltip('Start voice input'), findsOneWidget);
    expect(find.byTooltip('Conversation history'), findsOneWidget);
    expect(find.byTooltip('New conversation'), findsOneWidget);
  });

  testWidgets('ChatbotScreen shows loading state while initializing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        const ChatbotScreen(),
        FakeChatbotProvider(isInitializing: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ChatbotScreen renders messages and actions', (tester) async {
    final provider = FakeChatbotProvider(
      activeConversationId: 'c1',
      conversations: const [ConversationSummary(id: 'c1', title: 'First chat')],
      messages: [
        ChatMessage(
          id: 'u1',
          conversationId: 'c1',
          accountId: 'user',
          role: ChatMessageRole.user,
          content: 'Hello AI',
          createdAt: DateTime.parse('2026-04-26T07:00:00Z'),
        ),
        ChatMessage(
          id: 'a1',
          conversationId: 'c1',
          accountId: 'ai',
          role: ChatMessageRole.assistant,
          content: 'Pick a suggestion',
          createdAt: DateTime.parse('2026-04-26T07:01:00Z'),
          suggestions: const [ChatSuggestion(label: 'Budget', value: 'budget')],
          isMarkdown: true,
        ),
      ],
      confirmMessageIds: const {'a1'},
    );

    await tester.pumpWidget(_buildApp(const ChatbotScreen(), provider));
    await tester.pump();

    expect(find.text('Hello AI'), findsOneWidget);
    expect(find.text('Pick a suggestion'), findsOneWidget);
    expect(find.byType(ActionChip), findsNWidgets(2));

    await tester.tap(find.byType(ActionChip).first);
    await tester.pump();
    await tester.tap(find.byType(ActionChip).last);
    await tester.pump();

    expect(provider.sendMessageCalls, 2);

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(provider.sendMessageCalls, 2);

    await tester.enterText(find.byType(TextField), '  hello from test  ');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(provider.sendMessageCalls, 3);
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, isEmpty);

    await tester.tap(find.byTooltip('New conversation'));
    await tester.pump();
    await tester.tap(find.byTooltip('Conversation history'));
    await tester.pump();

    await tester.tap(find.byTooltip('Start voice input'));
    await tester.pump();

    expect(provider.refreshConversationsCalls, 1);
    expect(provider.createNewConversationCalls, 1);
  });
}