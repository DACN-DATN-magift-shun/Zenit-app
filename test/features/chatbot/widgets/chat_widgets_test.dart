import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';
import 'package:zenit/features/chatbot/widgets/chat_action_chips_row.dart';
import 'package:zenit/features/chatbot/widgets/chat_history_sheet.dart';
import 'package:zenit/features/chatbot/widgets/chat_message_bubble.dart';
import 'package:zenit/l10n/app_localizations.dart';

import '../../../fixtures/features/chatbot/chat_widget_fixtures.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('Chat widgets', () {
    testWidgets('ChatMessageBubble renders user and assistant messages', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          Column(
            children: [
              ChatMessageBubble(message: chatWidgetUserMessage),
              ChatMessageBubble(message: chatWidgetAssistantMessage),
            ],
          ),
        ),
      );

      expect(find.text('Hello AI'), findsOneWidget);
      expect(find.text('07:00'), findsOneWidget);
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.text('07:05'), findsOneWidget);
    });

    testWidgets('ChatActionChipsRow handles taps and empty state', (
      tester,
    ) async {
      final tapped = <String>[];

      await tester.pumpWidget(
        _buildApp(
          Column(
            children: [
              ChatActionChipsRow(items: buildChatWidgetChips(tapped.add)),
              const ChatActionChipsRow(items: []),
            ],
          ),
        ),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);

      await tester.tap(find.text('One'));
      await tester.pump();

      expect(tapped, <String>['One']);
      expect(find.byType(ActionChip), findsNWidgets(2));
    });

    testWidgets('ChatHistorySheet shows empty state and create button', (
      tester,
    ) async {
      var createCount = 0;

      await tester.pumpWidget(
        _buildApp(
          ChatHistorySheet(
            conversations: const <ConversationSummary>[],
            activeConversationId: null,
            onCreateNew: () => createCount += 1,
            onSelect: (_) {},
            onRename: (_) {},
            onDelete: (_) {},
          ),
        ),
      );

      expect(find.text('No conversations yet'), findsOneWidget);
      expect(find.text('New conversation'), findsOneWidget);

      await tester.tap(find.text('New conversation'));
      await tester.pump();

      expect(createCount, 1);
    });

    testWidgets('ChatHistorySheet selects and deletes conversations', (
      tester,
    ) async {
      ConversationSummary? selected;
      ConversationSummary? deleted;

      await tester.pumpWidget(
        _buildApp(
          ChatHistorySheet(
            conversations: buildChatWidgetConversations(),
            activeConversationId: chatWidgetConversation.id,
            onCreateNew: () {},
            onSelect: (conversation) => selected = conversation,
            onRename: (_) {},
            onDelete: (conversation) => deleted = conversation,
          ),
        ),
      );

      await tester.tap(find.text('Second conversation'));
      await tester.pump();

      expect(selected?.id, 'c2');

      await tester.drag(find.byType(Slidable).first, const Offset(-400, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Delete').last);
      await tester.pump();

      expect(deleted?.id, isNotEmpty);
    });
  });
}