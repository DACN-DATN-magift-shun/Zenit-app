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

  final List<ConversationSummary> _conversations = [];
  final Map<String, List<ChatMessage>> _messagesByConversation = {};

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

    _isSending = true;
    notifyListeners();

    try {
      final response = await _messageService.sendMessage(
        conversationId: conversationId,
        text: text,
      );

      if (response != null && response.hasAssistantPayload) {
        _handleSseMessage(<String, dynamic>{
          'chatbotMessage': response.chatbotMessage,
          'suggestions': response.suggestions
              .map((item) => item.toJson())
              .toList(growable: false),
          'conversationId': response.conversationId ?? conversationId,
        });
      }

      _promoteConversation(conversationId);
    } catch (_) {
      messages.removeWhere((item) => item.id == optimisticMessageId);
      rethrow;
    } finally {
      _isSending = false;
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

    if (conversationId.trim().isEmpty) {
      return;
    }

    final token = await _storageService.getAccessToken();
    if (token == null || token.trim().isEmpty) {
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

    try {
      final streamedResponse = await _client.send(request);
      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode > 299) {
        return;
      }

      _sseSubscription = utf8.decoder
          .bind(streamedResponse.stream)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!line.startsWith('data: ')) {
                return;
              }

              final rawPayload = line.substring(6).trim();
              if (rawPayload.isEmpty || rawPayload == '[DONE]') {
                return;
              }

              try {
                final decoded = jsonDecode(rawPayload);
                final data = _safeMap(decoded);
                if (data.isEmpty) {
                  return;
                }

                _handleSseMessage(data);
              } catch (_) {
                // Ignore malformed event payloads and keep stream alive.
              }
            },
            onError: (_) {
              if (_activeConversationId == conversationId && _isSending) {
                _isSending = false;
                notifyListeners();
              }
            },
            cancelOnError: false,
          );
    } catch (_) {
      if (_activeConversationId == conversationId && _isSending) {
        _isSending = false;
        notifyListeners();
      }
    }
  }

  void _handleSseMessage(Map<String, dynamic> data) {
    final conversationId = data['conversationId']?.toString() ?? '';
    if (conversationId.isEmpty || conversationId != _activeConversationId) {
      return;
    }

    final content = data['chatbotMessage']?.toString().trim() ?? '';
    final suggestions = ChatSuggestion.fromList(data['suggestions']);

    if (content.isEmpty && suggestions.isEmpty) {
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
      _isSending = false;
      notifyListeners();
      return;
    }

    if (content.isEmpty && messages.isNotEmpty) {
      final lastMessage = messages.last;
      if (lastMessage.role == ChatMessageRole.assistant) {
        messages[messages.length - 1] = lastMessage.copyWith(
          suggestions: suggestions,
        );
        _isSending = false;
        notifyListeners();
        return;
      }
    }

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
            .map(
              (item) => ChatMessage.fromJson(
                item,
                conversationId: conversationId,
                currentUserId: _accountId,
                aiAccountId: _aiAccountId,
              ),
            )
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

  Map<String, dynamic> _safeMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    _client.close();
    super.dispose();
  }
}
