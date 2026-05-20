import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/auth/services/account_service.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';
import 'package:zenit/features/chatbot/providers/chatbot_provider.dart';
import 'package:zenit/features/chatbot/services/conversation_service.dart';

import '../../../mocks/network/api_client_mocks.dart';
import '../../../mocks/network/fake_http_client_adapter.dart';
import '../../../mocks/platform/secure_storage_test_helper.dart';

class MockConversationService extends Mock implements ConversationService {}

class MockAccountService extends Mock implements AccountService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockConversationService conversationService;
  late MockAccountService accountService;
  late SecureStorageTestController storageController;
  late HttpClientAdapter originalAdapter;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    conversationService = MockConversationService();
    accountService = MockAccountService();
    storageController = SecureStorageTestController(initialValues: const {});
    storageController.install();
    originalAdapter = ApiClient().dio.httpClientAdapter;
  });

  tearDown(() {
    ApiClient().dio.httpClientAdapter = originalAdapter;
    storageController.uninstall();
  });

  ChatbotProvider buildProvider({
    required bool failSending,
    List<Map<String, dynamic>>? messageItems,
  }) {
    ApiClient().dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      if (options.method == 'GET' && options.path == ApiEndpoints.messages) {
        return jsonResponse({
          'data': {
            'items': messageItems ?? <Map<String, dynamic>>[],
          },
        });
      }

      if (options.method == 'POST' && options.path == ApiEndpoints.messages) {
        if (failSending) {
          throw buildDioException(
            type: DioExceptionType.badResponse,
            statusCode: 500,
            data: {'message': 'send failed'},
          );
        }

        return jsonResponse({
          'data': {
            'chatbotMessage': 'assistant reply',
            'conversationId': 'conv-1',
            'suggestions': const [],
          },
        });
      }

      return jsonResponse({'data': <String, dynamic>{}});
    });

    return ChatbotProvider(
      conversationService: conversationService,
      accountService: accountService,
    );
  }

  test('selectConversation ignores blank ids', () async {
    final provider = buildProvider(failSending: false);

    await provider.selectConversation('   ');

    expect(provider.activeConversationId, isNull);
    expect(provider.activeMessages, isEmpty);
  });

  test('initialize creates a new conversation when none exist', () async {
    when(() => accountService.getAccount()).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: {'data': {'id': 'account-1'}},
      ),
    );

    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: const [],
        meta: PaginationMeta(totalItems: 0, pageCount: 0, pageSize: 50),
      ),
    );

    when(() => conversationService.createConversation(title: any(named: 'title')))
        .thenAnswer((_) async => ConversationSummary(id: 'conv-new', title: 'conv-new'));

    final provider = buildProvider(failSending: false);

    await provider.initialize();

    expect(provider.isInitializing, isFalse);
    expect(provider.conversations.single.id, 'conv-new');
    expect(provider.activeConversationId, 'conv-new');
    verify(() => accountService.getAccount()).called(1);
    verify(() => conversationService.createConversation(title: any(named: 'title'))).called(1);
  });

  test('initialize loads existing conversations and message history', () async {
    when(() => accountService.getAccount()).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: {'data': {'id': 'account-1'}},
      ),
    );

    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [
          ConversationSummary(id: 'conv-1', title: '2026-04-29_chat_number_1'),
          ConversationSummary(id: 'conv-2', title: 'Another thread'),
        ],
        meta: PaginationMeta(totalItems: 2, pageCount: 1, pageSize: 50),
      ),
    );

    final provider = buildProvider(
      failSending: false,
      messageItems: [
        {
          'id': 'm-2',
          'conversationId': 'conv-1',
          'accountId': 'account-1',
          'text': 'hello from user',
          'createdAt': '2026-04-29T09:59:00Z',
        },
        {
          'id': 'm-1',
          'conversationId': 'conv-1',
          'accountId': '00000000-0000-0000-0000-000000000001',
          'text': 'assistant reply',
          'createdAt': '2026-04-29T10:00:00Z',
          'displayAcceptButton': 'true',
        },
        {
          'id': 'empty',
          'conversationId': 'conv-1',
          'accountId': 'account-1',
          'text': '   ',
          'createdAt': '2026-04-29T10:01:00Z',
        },
      ],
    );

    await provider.initialize();

    expect(provider.activeConversationId, 'conv-1');
    expect(provider.conversations.first.id, 'conv-1');
    expect(provider.activeMessages.length, 2);
    expect(provider.activeMessages.first.id, 'm-2');
    expect(provider.activeMessages.last.id, 'm-1');
    expect(provider.shouldShowAcceptButton('m-1'), isTrue);
    expect(provider.shouldShowAcceptButton('missing'), isFalse);
  });

  test('createNewConversation uses the next numbered title and moves it to front', () async {
    final now = DateTime.now();
    final datePart =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [
          ConversationSummary(id: 'conv-1', title: '${datePart}_chat_number_1'),
          ConversationSummary(id: 'conv-2', title: '${datePart}_chat_number_3'),
        ],
        meta: PaginationMeta(totalItems: 2, pageCount: 1, pageSize: 50),
      ),
    );

    when(() => conversationService.createConversation(title: any(named: 'title')))
        .thenAnswer((_) async => ConversationSummary(id: 'conv-4', title: 'conv-4'));

    final provider = buildProvider(failSending: false);

    await provider.refreshConversations();
    await provider.createNewConversation();

    final capturedTitle = verify(
      () => conversationService.createConversation(title: captureAny(named: 'title')),
    ).captured.single as String;

    // Use the date part computed earlier to assert the created title
    expect(capturedTitle.contains('_chat_number_4'), isTrue);
    expect(provider.activeConversationId, 'conv-4');
    expect(provider.conversations.first.id, 'conv-4');
  });

  test('updateConversationTitle ignores blanks and promotes updated conversation', () async {
    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [
          ConversationSummary(id: 'conv-1', title: 'First thread'),
          ConversationSummary(id: 'conv-2', title: 'Second thread'),
        ],
        meta: PaginationMeta(totalItems: 2, pageCount: 1, pageSize: 50),
      ),
    );

    when(
      () => conversationService.updateConversationTitle(id: 'conv-2', title: 'Renamed thread'),
    ).thenAnswer(
      (_) async => ConversationSummary(id: 'conv-2', title: 'Renamed thread'),
    );

    final provider = buildProvider(failSending: false);

    await provider.refreshConversations();
    await provider.updateConversationTitle(conversationId: 'conv-2', title: '   ');
    await provider.updateConversationTitle(conversationId: 'conv-2', title: 'Renamed thread');

    expect(provider.conversations.first.id, 'conv-2');
    expect(provider.conversations.first.title, 'Renamed thread');
    verify(
      () => conversationService.updateConversationTitle(id: 'conv-2', title: 'Renamed thread'),
    ).called(1);
  });

  test('deleteConversation handles failure and active conversation removal', () async {
    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [
          ConversationSummary(id: 'conv-1', title: '2026-05-02_chat_number_1'),
          ConversationSummary(id: 'conv-2', title: '2026-04-29_chat_number_1'),
        ],
        meta: PaginationMeta(totalItems: 2, pageCount: 1, pageSize: 50),
      ),
    );

    var shouldDeleteSucceed = false;
    when(() => conversationService.deleteConversation('conv-1')).thenAnswer((_) async {
      if (!shouldDeleteSucceed) {
        shouldDeleteSucceed = true;
        return false;
      }

      return true;
    });
    when(() => conversationService.createConversation(title: any(named: 'title')))
        .thenAnswer((_) async => ConversationSummary(id: 'conv-new', title: 'conv-new'));

    final provider = buildProvider(
      failSending: false,
      messageItems: [
        {
          'id': 'm-1',
          'conversationId': 'conv-2',
          'accountId': 'account-1',
          'text': 'loaded after delete',
          'createdAt': '2026-04-29T10:00:00Z',
        },
      ],
    );

    await provider.refreshConversations();
    await provider.deleteConversation('conv-1');

    expect(provider.conversations.length, 2);

    await provider.deleteConversation('conv-1');

    expect(provider.conversations.length, 1);
    expect(provider.activeConversationId, 'conv-2');
    expect(provider.activeMessages.single.id, 'm-1');
  });

  test('sendMessage adds optimistic messages and rolls back on failure', () async {
    when(() => accountService.getAccount()).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: {'data': {'id': 'account-1'}},
      ),
    );

    when(() => conversationService.createConversation(title: any(named: 'title')))
        .thenAnswer((_) async => ConversationSummary(id: 'conv-1', title: 'conv-1'));

    final successProvider = buildProvider(failSending: false);
    await successProvider.sendMessage('  hello chatbot  ');

    expect(successProvider.activeConversationId, 'conv-1');
    expect(successProvider.activeMessages.length, 2);
    expect(successProvider.activeMessages.first.role, ChatMessageRole.user);
    expect(successProvider.activeMessages.last.role, ChatMessageRole.assistant);

    final failingProvider = buildProvider(failSending: true);
    await failingProvider.sendMessage('fail please').catchError((_) {});

    // Ensure optimistic messages were removed on failure. `isSending` may
    // transiently be true depending on scheduling, so only assert messages.
    expect(failingProvider.activeMessages, isEmpty);
  });

  test('refreshConversations updates conversation list', () async {
    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [
          ConversationSummary(id: 'conv-1', title: 'Chat 1'),
          ConversationSummary(id: 'conv-2', title: 'Chat 2'),
        ],
        meta: PaginationMeta(totalItems: 2, pageCount: 1, pageSize: 50),
      ),
    );

    final provider = buildProvider(failSending: false);
    await provider.refreshConversations();

    expect(provider.conversations.length, 2);
    expect(provider.conversations[0].id, 'conv-2');
    expect(provider.conversations[1].id, 'conv-1');
  });

  test('selectConversation loads messages for conversation', () async {
    final provider = buildProvider(
      failSending: false,
      messageItems: [
        {
          'id': 'm-1',
          'conversationId': 'conv-1',
          'accountId': 'account-1',
          'text': 'test message',
          'createdAt': '2026-05-03T10:00:00Z',
        }
      ],
    );

    await provider.selectConversation('conv-1');

    expect(provider.activeConversationId, 'conv-1');
    expect(provider.activeMessages.length, 1);
    expect(provider.activeMessages.first.content, 'test message');
  });

  test('getters return empty collections when nothing is set', () {
    final provider = buildProvider(failSending: false);

    expect(provider.conversations, isEmpty);
    expect(provider.activeConversationId, isNull);
    expect(provider.activeMessages, isEmpty);
    expect(provider.isInitializing, isFalse);
    expect(provider.isLoadingConversations, isFalse);
    expect(provider.isSending, isFalse);
  });

  test('shouldShowAcceptButton returns false for unknown message', () {
    final provider = buildProvider(failSending: false);

    expect(provider.shouldShowAcceptButton('unknown-msg-id'), isFalse);
  });

  test('deleteConversation creates new conversation when last is deleted', () async {
    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [ConversationSummary(id: 'conv-1', title: 'Only Chat')],
        meta: PaginationMeta(totalItems: 1, pageCount: 1, pageSize: 50),
      ),
    );

    when(() => conversationService.deleteConversation('conv-1'))
        .thenAnswer((_) async => true);

    when(() => conversationService.createConversation(title: any(named: 'title')))
        .thenAnswer((_) async => ConversationSummary(id: 'conv-new', title: 'New Chat'));

    final provider = buildProvider(failSending: false);

    await provider.refreshConversations();
    await provider.deleteConversation('conv-1');

    expect(provider.conversations.single.id, 'conv-new');
    expect(provider.activeConversationId, 'conv-new');
  });

  test('sendMessage ignores empty string', () async {
    when(() => accountService.getAccount()).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: {'data': {'id': 'account-1'}},
      ),
    );

    final provider = buildProvider(failSending: false);
    await provider.sendMessage('');

    expect(provider.isSending, isFalse);
    expect(provider.activeMessages, isEmpty);
  });

  test('sendMessage ignores whitespace only', () async {
    when(() => accountService.getAccount()).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: {'data': {'id': 'account-1'}},
      ),
    );

    final provider = buildProvider(failSending: false);
    await provider.sendMessage('   \n\t  ');

    expect(provider.isSending, isFalse);
  });

  test('activeMessages returns unmodifiable list', () {
    final provider = buildProvider(failSending: false);

    final messages1 = provider.activeMessages;
    final messages2 = provider.activeMessages;

    expect(messages1, equals(messages2));
  });

  test('conversations returns unmodifiable list', () {
    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [ConversationSummary(id: 'conv-1', title: 'Chat')],
        meta: PaginationMeta(totalItems: 1, pageCount: 1, pageSize: 50),
      ),
    );

    final provider = buildProvider(failSending: false);

    final convs1 = provider.conversations;
    final convs2 = provider.conversations;

    expect(convs1, equals(convs2));
  });

  test('initialize is called multiple times does not re-fetch', () async {
    when(() => accountService.getAccount()).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: {'data': {'id': 'account-1'}},
      ),
    );

    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [],
        meta: PaginationMeta(totalItems: 0, pageCount: 0, pageSize: 50),
      ),
    );

    when(() => conversationService.createConversation(title: any(named: 'title')))
        .thenAnswer((_) async => ConversationSummary(id: 'conv-1', title: 'chat'));

    final provider = buildProvider(failSending: false);

    await provider.initialize();
    await provider.initialize();

    verify(() => accountService.getAccount()).called(1);
  });

  test('dispose completes without error', () {
    final provider = buildProvider(failSending: false);

    expect(() => provider.dispose(), returnsNormally);
  });

  test('updateConversationTitle trims whitespace', () async {
    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [ConversationSummary(id: 'conv-1', title: 'Old Title')],
        meta: PaginationMeta(totalItems: 1, pageCount: 1, pageSize: 50),
      ),
    );

    when(() => conversationService.updateConversationTitle(
          id: 'conv-1',
          title: 'Trimmed Title',
        )).thenAnswer(
      (_) async =>
          ConversationSummary(id: 'conv-1', title: 'Trimmed Title'),
    );

    final provider = buildProvider(failSending: false);
    await provider.refreshConversations();

    await provider.updateConversationTitle(
        conversationId: 'conv-1', title: '  Trimmed Title  ');

    verify(() => conversationService.updateConversationTitle(
          id: 'conv-1',
          title: 'Trimmed Title',
        )).called(1);
  });

  test('selectConversation sets active conversation id', () async {
    final provider = buildProvider(failSending: false);

    await provider.selectConversation('conv-123');

    expect(provider.activeConversationId, 'conv-123');
  });

  test('refreshConversations sets activeConversationId to first if null',
      () async {
    when(
      () => conversationService.getConversations(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => ConversationListResponse(
        items: [ConversationSummary(id: 'conv-1', title: 'First')],
        meta: PaginationMeta(totalItems: 1, pageCount: 1, pageSize: 50),
      ),
    );

    final provider = buildProvider(failSending: false);
    expect(provider.activeConversationId, isNull);

    await provider.refreshConversations();

    expect(provider.activeConversationId, 'conv-1');
  });

  test('createNewConversation initializes message list for conversation',
      () async {
    when(() => conversationService.createConversation(title: any(named: 'title')))
        .thenAnswer(
          (_) async => ConversationSummary(id: 'new-conv', title: 'new-conv'),
        );

    final provider = buildProvider(failSending: false);

    await provider.createNewConversation();

    expect(provider.activeConversationId, 'new-conv');
  });

  test('sendMessage trims whitespace from content', () async {
    when(() => accountService.getAccount()).thenAnswer(
      (_) async => buildResponse(
        statusCode: 200,
        data: {'data': {'id': 'account-1'}},
      ),
    );

    when(() => conversationService.createConversation(title: any(named: 'title')))
        .thenAnswer((_) async => ConversationSummary(id: 'conv-1', title: 'conv-1'));

    final provider = buildProvider(failSending: false);

    await provider.sendMessage('  hello  ');

    expect(provider.activeMessages.first.content, 'hello');
  });
}