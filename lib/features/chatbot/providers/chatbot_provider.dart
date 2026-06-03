import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zenit/features/auth/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/features/chatbot/models/chat_models.dart';
import 'package:zenit/features/chatbot/services/conversation_service.dart';
import 'package:zenit/features/chatbot/services/message_service.dart';

class ChatbotProvider extends ChangeNotifier {
  ChatbotProvider({
    ConversationService? conversationService,
    AccountService? accountService,
  }) : _conversationService = conversationService ?? ConversationService(),
       _messageService = MessageService(),
       _accountService = accountService ?? AccountService();

  final ConversationService _conversationService;
  final MessageService _messageService;
  final AccountService _accountService;
  final StorageService _storageService = StorageService();
  final http.Client _client = http.Client();

  static const int _defaultPageSize = 50;
  static const String _aiAccountId = '00000000-0000-0000-0000-000000000001';
  static final RegExp _conversationTitlePattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})_chat_number_(\d+)$',
  );

  final List<ConversationSummary> _conversations = [];
  final Map<String, List<ChatMessage>> _messagesByConversation = {};
  final Map<String, bool> _displayAcceptButtonByMessageId = {};

  /// IDs of assistant messages that were received live (via SSE or mock) in
  /// the current app session. Only these messages play the typewriter animation.
  /// Messages loaded from history are never added here.
  final Set<String> _sseReceivedMessageIds = {};

  bool _isInitializing = false;
  bool _isLoadingConversations = false;
  bool _isSending = false;
  String? _activeConversationId;
  String? _accountId;
  bool _initialized = false;
  StreamSubscription<String>? _sseSubscription;

  List<ConversationSummary> get conversations =>
      List.unmodifiable(_conversations);
  bool get isInitializing => _isInitializing;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isSending => _isSending;
  String? get activeConversationId => _activeConversationId;

  /// Returns true only for assistant messages that arrived live via SSE
  /// (not fetched from history). Used to gate the typewriter animation.
  bool shouldAnimateMessage(String messageId) =>
      _sseReceivedMessageIds.contains(messageId);

  List<ChatMessage> get activeMessages {
    final conversationId = _activeConversationId;
    if (conversationId == null) {
      return const [];
    }
    return List.unmodifiable(
      _messagesByConversation[conversationId] ?? const [],
    );
  }

  Future<void> initialize() async {
    if (_initialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    notifyListeners();

    try {
      await _ensureAccountId();
      await refreshConversations();

      if (_conversations.isEmpty) {
        await createNewConversation();
      } else {
        await selectConversation(_conversations.first.id);
      }

      _initialized = true;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> refreshConversations() async {
    _isLoadingConversations = true;
    notifyListeners();

    try {
      final response = await _conversationService.getConversations(
        pageSize: _defaultPageSize,
      );

      _conversations
        ..clear()
        ..addAll(response.items);

      _sortConversationsByMostRecentTitle();

      if (_activeConversationId == null && _conversations.isNotEmpty) {
        _activeConversationId = _conversations.first.id;
      }
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> selectConversation(String conversationId) async {
    if (conversationId.trim().isEmpty) {
      return;
    }

    _activeConversationId = conversationId;
    notifyListeners();

    await _refreshMessagesForConversation(conversationId);
    await _listenToSse(conversationId);
    _promoteConversation(conversationId);
    notifyListeners();
  }

  Future<void> createNewConversation() async {
    final created = await _conversationService.createConversation(
      title: _buildAutoConversationTitle(),
    );

    _conversations.insert(0, created);
    _messagesByConversation[created.id] = <ChatMessage>[];
    _activeConversationId = created.id;
    await _listenToSse(created.id);
    notifyListeners();
  }

  Future<void> updateConversationTitle({
    required String conversationId,
    required String title,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    final updated = await _conversationService.updateConversationTitle(
      id: conversationId,
      title: trimmedTitle,
    );

    final index = _conversations.indexWhere(
      (item) => item.id == conversationId,
    );
    if (index != -1) {
      _conversations[index] = updated;
      _promoteConversation(conversationId);
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    final success = await _conversationService.deleteConversation(
      conversationId,
    );
    if (!success) {
      return;
    }

    _conversations.removeWhere((item) => item.id == conversationId);
    _messagesByConversation.remove(conversationId);

    if (_activeConversationId == conversationId) {
      if (_conversations.isNotEmpty) {
        _activeConversationId = _conversations.first.id;
        await selectConversation(_activeConversationId!);
      } else {
        _activeConversationId = null;
        await createNewConversation();
      }
    }

    notifyListeners();
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    await _ensureAccountId();

    if (_activeConversationId == null) {
      await createNewConversation();
    }

    final conversationId = _activeConversationId;
    if (conversationId == null) {
      throw Exception('Conversation is not ready.');
    }

    final messages = _messagesByConversation.putIfAbsent(
      conversationId,
      () => <ChatMessage>[],
    );

    final optimisticMessageId =
        'local_${DateTime.now().microsecondsSinceEpoch}_$conversationId';
    messages.add(
      ChatMessage(
        id: optimisticMessageId,
        conversationId: conversationId,
        accountId: _accountId ?? '',
        role: ChatMessageRole.user,
        content: text,
        createdAt: DateTime.now(),
      ),
    );

    final pendingAssistantMessageId =
        'pending_${DateTime.now().microsecondsSinceEpoch}_$conversationId';
    messages.add(
      ChatMessage(
        id: pendingAssistantMessageId,
        conversationId: conversationId,
        accountId: _aiAccountId,
        role: ChatMessageRole.assistant,
        content: '',
        createdAt: DateTime.now(),
        isMarkdown: true,
      ),
    );
    // Mark as live-received so the typewriter animation fires for this message.
    _sseReceivedMessageIds.add(pendingAssistantMessageId);

    _isSending = true;
    notifyListeners();

    try {
      debugPrint(
        'SSE/POST: sending message payload -> conversationId: $conversationId, text: ${text.length} chars',
      );
      await _messageService.sendMessage(
        conversationId: conversationId,
        text: text,
      );

      _promoteConversation(conversationId);
    } catch (_) {
      messages.removeWhere((item) => item.id == optimisticMessageId);
      _removePendingAssistantMessage(messages);
      _isSending = false;
      notifyListeners();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _ensureAccountId() async {
    if (_accountId != null && _accountId!.isNotEmpty) {
      return;
    }

    final response = await _accountService.getAccount();
    final root = _safeMap(response.data);
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;

    final id = data['id']?.toString();
    if (id == null || id.isEmpty) {
      throw Exception('Cannot resolve account id from account profile.');
    }

    _accountId = id;
  }

  Future<void> _listenToSse(String conversationId) async {
    await _sseSubscription?.cancel();
    _sseSubscription = null;

    debugPrint('SSE: start listening for conversationId="$conversationId"');

    if (conversationId.trim().isEmpty) {
      debugPrint('SSE: conversationId is empty - aborting');
      return;
    }

    final token = await _storageService.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      debugPrint('SSE: no access token - aborting');
      return;
    }

    final request =
        http.Request(
            'GET',
            Uri.parse(
              '${ApiEndpoints.messages}/stream?conversationId=${Uri.encodeQueryComponent(conversationId)}',
            ),
          )
          ..headers.addAll(<String, String>{
            'Authorization': 'Bearer $token',
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          });

    debugPrint('SSE: sending request to ${request.url}');

    try {
      final streamedResponse = await _client.send(request);
      debugPrint('SSE: response status ${streamedResponse.statusCode}');
      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode > 299) {
        debugPrint('SSE: non-success status - aborting');
        _removePendingAssistantMessage(
          _messagesByConversation.putIfAbsent(
            conversationId,
            () => <ChatMessage>[],
          ),
        );
        if (_activeConversationId == conversationId && _isSending) {
          _isSending = false;
          notifyListeners();
        }
        return;
      }

      _sseSubscription = utf8.decoder
          .bind(streamedResponse.stream)
          .transform(const LineSplitter())
          .listen(
            (line) {
              debugPrint('SSE: received line: $line');
              if (!line.startsWith('data: ')) {
                debugPrint('SSE: skipping non-data line');
                return;
              }

              final rawPayload = line.substring(6).trim();
              debugPrint('SSE: rawPayload="$rawPayload"');
              if (rawPayload.isEmpty || rawPayload == '[DONE]') {
                debugPrint('SSE: empty or DONE payload - ignoring');
                return;
              }

              try {
                final decoded = jsonDecode(rawPayload);
                final data = _safeMap(decoded);
                if (data.isEmpty) {
                  debugPrint('SSE: decoded data is empty - ignoring');
                  return;
                }

                debugPrint('SSE: dispatching parsed SSE message');
                _handleSseMessage(data);
              } catch (e, st) {
                debugPrint('SSE: malformed payload, decode error: $e\n$st');
                // Ignore malformed event payloads and keep stream alive.
              }
            },
            onError: (error) {
              debugPrint('SSE: stream onError: $error');
              if (_activeConversationId == conversationId && _isSending) {
                _removePendingAssistantMessage(
                  _messagesByConversation.putIfAbsent(
                    conversationId,
                    () => <ChatMessage>[],
                  ),
                );
                _isSending = false;
                notifyListeners();
              }
            },
            cancelOnError: false,
          );
    } catch (e, st) {
      debugPrint('SSE: exception while creating stream: $e\n$st');
      if (_activeConversationId == conversationId && _isSending) {
        _removePendingAssistantMessage(
          _messagesByConversation.putIfAbsent(
            conversationId,
            () => <ChatMessage>[],
          ),
        );
        _isSending = false;
        notifyListeners();
      }
    }
  }

  void _handleSseMessage(Map<String, dynamic> data) {
    final conversationId = data['conversationId']?.toString() ?? '';
    debugPrint(
      'SSE: handleSseMessage for conversationId="$conversationId", rawData=${data.toString()}',
    );
    if (conversationId.isEmpty || conversationId != _activeConversationId) {
      debugPrint('SSE: conversationId mismatch or empty - ignoring');
      return;
    }

    final content = data['chatbotMessage']?.toString().trim() ?? '';
    final suggestions = ChatSuggestion.fromList(data['suggestions']);
    final displayAcceptButton =
        data['display_accept_button'] == true ||
        data['display_accept_button']?.toString().toLowerCase() == 'true' ||
        data['displayAcceptButton'] == true ||
        data['displayAcceptButton']?.toString().toLowerCase() == 'true';
    debugPrint(
      'SSE: parsed content length=${content.length}, suggestions=${suggestions.length}',
    );

    if (content.isEmpty && suggestions.isEmpty) {
      debugPrint('SSE: both content and suggestions empty - ignoring');
      return;
    }

    final messages = _messagesByConversation.putIfAbsent(
      conversationId,
      () => <ChatMessage>[],
    );

    if (_isDuplicateAssistantMessage(
      messages: messages,
      content: content,
      suggestions: suggestions,
    )) {
      final lastMessage = messages.last;
      if (displayAcceptButton && !shouldShowAcceptButton(lastMessage.id)) {
        _displayAcceptButtonByMessageId[lastMessage.id] = true;
        _isSending = false;
        _promoteConversation(conversationId);
        notifyListeners();
        return;
      }

      debugPrint(
        'SSE: duplicate assistant message detected - stopping send state',
      );
      _isSending = false;
      notifyListeners();
      return;
    }

    if (messages.isNotEmpty) {
      final lastMessage = messages.last;
      if (lastMessage.role == ChatMessageRole.assistant &&
          lastMessage.content.trim().isEmpty &&
          lastMessage.id.startsWith('pending_')) {
        debugPrint('SSE: updating pending assistant message');
        messages[messages.length - 1] = lastMessage.copyWith(
          content: content.isNotEmpty ? content : lastMessage.content,
          suggestions: suggestions,
          isMarkdown: content.isNotEmpty ? true : lastMessage.isMarkdown,
        );
        _displayAcceptButtonByMessageId[messages.last.id] = displayAcceptButton;
        if (content.isNotEmpty) {
          // The pending_ ID was already registered; the message keeps its ID
          // so shouldAnimateMessage() will return true for it.
          _isSending = false;
        }
        notifyListeners();
        return;
      }
    }

    debugPrint('SSE: adding assistant message to messages list');
    messages.add(
      ChatMessage(
        id: 'sse_${DateTime.now().microsecondsSinceEpoch}_$conversationId',
        conversationId: conversationId,
        accountId: _aiAccountId,
        role: ChatMessageRole.assistant,
        content: content,
        createdAt: DateTime.now(),
        suggestions: suggestions,
        isMarkdown: true,
      ),
    );
    _displayAcceptButtonByMessageId[messages.last.id] = displayAcceptButton;
    // Mark as live-received so the typewriter animation fires.
    _sseReceivedMessageIds.add(messages.last.id);

    _isSending = false;
    _promoteConversation(conversationId);
    notifyListeners();
  }

  bool _isDuplicateAssistantMessage({
    required List<ChatMessage> messages,
    required String content,
    required List<ChatSuggestion> suggestions,
  }) {
    if (messages.isEmpty) {
      return false;
    }

    final lastMessage = messages.last;
    if (lastMessage.role != ChatMessageRole.assistant) {
      return false;
    }

    if (lastMessage.content.trim() != content.trim()) {
      return false;
    }

    if (lastMessage.suggestions.length != suggestions.length) {
      return false;
    }

    for (var index = 0; index < suggestions.length; index++) {
      final existing = lastMessage.suggestions[index];
      final incoming = suggestions[index];
      if (existing.label != incoming.label ||
          existing.value != incoming.value) {
        return false;
      }
    }

    return true;
  }

  void _removePendingAssistantMessage(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return;
    }

    final lastMessage = messages.last;
    if (lastMessage.role == ChatMessageRole.assistant &&
        lastMessage.content.trim().isEmpty &&
        lastMessage.id.startsWith('pending_')) {
      messages.removeLast();
    }
  }

  void _promoteConversation(String conversationId) {
    final index = _conversations.indexWhere(
      (item) => item.id == conversationId,
    );
    if (index <= 0) {
      return;
    }

    final item = _conversations.removeAt(index);
    _conversations.insert(0, item);
  }

  void _sortConversationsByMostRecentTitle() {
    _conversations.sort((a, b) {
      final aParsed = _parseConversationTitleOrder(a.title);
      final bParsed = _parseConversationTitleOrder(b.title);

      if (aParsed != null && bParsed != null) {
        final byDate = bParsed.date.compareTo(aParsed.date);
        if (byDate != 0) {
          return byDate;
        }

        final byNumber = bParsed.chatNumber.compareTo(aParsed.chatNumber);
        if (byNumber != 0) {
          return byNumber;
        }
      } else if (aParsed != null) {
        return -1;
      } else if (bParsed != null) {
        return 1;
      }

      final aUpdatedAt = a.updatedAt;
      final bUpdatedAt = b.updatedAt;
      if (aUpdatedAt != null && bUpdatedAt != null) {
        final byUpdatedAt = bUpdatedAt.compareTo(aUpdatedAt);
        if (byUpdatedAt != 0) {
          return byUpdatedAt;
        }
      } else if (aUpdatedAt != null) {
        return -1;
      } else if (bUpdatedAt != null) {
        return 1;
      }

      return b.title.compareTo(a.title);
    });
  }

  _ConversationTitleOrder? _parseConversationTitleOrder(String title) {
    final match = _conversationTitlePattern.firstMatch(title.trim());
    if (match == null) {
      return null;
    }

    final year = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final day = int.tryParse(match.group(3) ?? '');
    final chatNumber = int.tryParse(match.group(4) ?? '');

    if (year == null || month == null || day == null || chatNumber == null) {
      return null;
    }

    final date = DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );
    if (date == null) {
      return null;
    }

    return _ConversationTitleOrder(date: date, chatNumber: chatNumber);
  }

  String _buildAutoConversationTitle() {
    final now = DateTime.now();
    final datePart =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final pattern = RegExp('^${RegExp.escape(datePart)}_chat_number_(\\d+)\$');
    var maxNumber = 0;

    for (final conversation in _conversations) {
      final title = conversation.title.trim();
      final match = pattern.firstMatch(title);
      if (match == null) {
        continue;
      }

      final parsed = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (parsed > maxNumber) {
        maxNumber = parsed;
      }
    }

    final nextNumber = maxNumber + 1;
    return '${datePart}_chat_number_$nextNumber';
  }

  Future<List<ChatMessage>> _refreshMessagesForConversation(
    String conversationId,
  ) async {
    final response = await _messageService.getMessages(
      conversationId: conversationId,
      pageSize: _defaultPageSize,
    );

    final messages =
        response.items
            .map((item) {
              final message = ChatMessage.fromJson(
                item,
                conversationId: conversationId,
                currentUserId: _accountId,
                aiAccountId: _aiAccountId,
              );
              final raw = _safeMap(item);
              final accepts =
                  _parseBool(raw['display_accept_button']) ||
                  _parseBool(raw['displayAcceptButton']);
              if (accepts) {
                _displayAcceptButtonByMessageId[message.id] = true;
              }
              return message;
            })
            .where((item) => item.content.trim().isNotEmpty)
            .toList()
          ..sort((a, b) {
            final byTime = a.createdAt.compareTo(b.createdAt);
            if (byTime != 0) {
              return byTime;
            }

            return a.id.compareTo(b.id);
          });

    _messagesByConversation[conversationId] = messages;
    return messages;
  }

  bool shouldShowAcceptButton(String messageId) {
    return _displayAcceptButtonByMessageId[messageId] ?? false;
  }

  Map<String, dynamic> _safeMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  // -------------------------------------------------------------------------
  // MOCK – temporary dev helper, remove before release
  // -------------------------------------------------------------------------

  static const String _mockResponse =
      'Hello! I am **Zenos**, your AI assistant. '
      'This is a **mock response** used for testing the streaming animations. '
      'The gradient border should be spinning around the input field right now, '
      'and this text should be appearing *word by word* in a smooth typewriter effect. '
      'Isn\'t it looking great? 🎉\n\n'
      '> "The best way to predict the future is to invent it." — Alan Kay\n\n'
      'Feel free to test with the real API once you\'re satisfied with the animation.';

  Future<void> mockSimulateAiResponse() async {
    if (_isSending) return;

    if (_activeConversationId == null) {
      await createNewConversation();
    }

    final conversationId = _activeConversationId;
    if (conversationId == null) return;

    final messages = _messagesByConversation.putIfAbsent(
      conversationId,
      () => <ChatMessage>[],
    );

    final mockUserId =
        'mock_user_${DateTime.now().microsecondsSinceEpoch}';
    messages.add(
      ChatMessage(
        id: mockUserId,
        conversationId: conversationId,
        accountId: _accountId ?? 'mock_account',
        role: ChatMessageRole.user,
        content: 'Mock test message',
        createdAt: DateTime.now(),
      ),
    );

    final pendingId = 'pending_${DateTime.now().microsecondsSinceEpoch}';
    messages.add(
      ChatMessage(
        id: pendingId,
        conversationId: conversationId,
        accountId: _aiAccountId,
        role: ChatMessageRole.assistant,
        content: '',
        createdAt: DateTime.now(),
        isMarkdown: true,
      ),
    );

    _isSending = true;
    // Mark the mock message as live-received so the typewriter animation fires.
    _sseReceivedMessageIds.add(pendingId);
    notifyListeners();

    // Simulate a 2-second network delay
    await Future<void>.delayed(const Duration(seconds: 2));

    if (_activeConversationId != conversationId) {
      // User switched conversation — clean up silently
      messages.removeWhere(
        (m) => m.id == mockUserId || m.id == pendingId,
      );
      _isSending = false;
      notifyListeners();
      return;
    }

    // Replace the pending placeholder with the mock assistant response
    final pendingIndex = messages.indexWhere((m) => m.id == pendingId);
    if (pendingIndex != -1) {
      messages[pendingIndex] = messages[pendingIndex].copyWith(
        content: _mockResponse,
      );
    }

    _isSending = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    _client.close();
    super.dispose();
  }
}

class _ConversationTitleOrder {
  const _ConversationTitleOrder({required this.date, required this.chatNumber});

  final DateTime date;
  final int chatNumber;
}
