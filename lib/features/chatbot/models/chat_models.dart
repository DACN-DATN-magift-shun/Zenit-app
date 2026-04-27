class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.title,
    this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime? updatedAt;

  factory ConversationSummary.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);

    return ConversationSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled conversation',
      updatedAt: _parseDate(
        json['updatedAt'] ?? json['lastUpdatedAt'] ?? json['createdAt'],
      ),
    );
  }
}

class PaginationMeta {
  const PaginationMeta({
    required this.totalItems,
    required this.pageCount,
    this.page,
    required this.pageSize,
  });

  final int totalItems;
  final int pageCount;
  final int? page;
  final int pageSize;

  factory PaginationMeta.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);

    return PaginationMeta(
      totalItems: _parseInt(json['totalItems']),
      pageCount: _parseInt(json['pageCount']),
      page: _nullableInt(json['page']),
      pageSize: _parseInt(json['pageSize']),
    );
  }
}

class ConversationListResponse {
  const ConversationListResponse({required this.items, required this.meta});

  final List<ConversationSummary> items;
  final PaginationMeta meta;

  factory ConversationListResponse.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    final items = _safeList(json['items']);

    return ConversationListResponse(
      items: items.map(ConversationSummary.fromJson).toList(),
      meta: PaginationMeta.fromJson(json['meta']),
    );
  }
}

enum ChatMessageRole { user, assistant }

class ChatSuggestion {
  const ChatSuggestion({required this.label, required this.value});

  final String label;
  final String value;

  factory ChatSuggestion.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    final label =
        json['label']?.toString().trim() ??
        json['title']?.toString().trim() ??
        json['text']?.toString().trim() ??
        json['prompt']?.toString().trim() ??
        json['message']?.toString().trim() ??
        json['content']?.toString().trim() ??
        '';

    final value =
        json['value']?.toString().trim() ??
        json['prompt']?.toString().trim() ??
        json['message']?.toString().trim() ??
        json['text']?.toString().trim() ??
        json['content']?.toString().trim() ??
        label;

    return ChatSuggestion(label: label, value: value);
  }

  Map<String, String> toJson() => <String, String>{
    'label': label,
    'value': value,
  };

  static List<ChatSuggestion> fromList(dynamic rawList) {
    final items = _safeList(rawList);
    return items
        .map(ChatSuggestion.fromJson)
        .where((item) => item.label.isNotEmpty || item.value.isNotEmpty)
        .toList(growable: false);
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.accountId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.suggestions = const <ChatSuggestion>[],
    this.isMarkdown = false,
  });

  final String id;
  final String conversationId;
  final String accountId;
  final ChatMessageRole role;
  final String content;
  final DateTime createdAt;
  final List<ChatSuggestion> suggestions;
  final bool isMarkdown;

  bool get isUser => role == ChatMessageRole.user;

  factory ChatMessage.fromJson(
    dynamic rawJson, {
    String? conversationId,
    String? currentUserId,
    String aiAccountId = '00000000-0000-0000-0000-000000000001',
  }) {
    final json = _safeMap(rawJson);
    final messageId =
        json['id']?.toString() ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final accountId = json['accountId']?.toString() ?? '';
    final normalizedRole = (json['role'] ?? json['sender'] ?? json['type'])
        ?.toString()
        .toLowerCase();

    final role =
        normalizedRole == 'assistant' ||
            normalizedRole == 'ai' ||
            accountId == aiAccountId
        ? ChatMessageRole.assistant
        : (currentUserId != null && accountId == currentUserId
              ? ChatMessageRole.user
              : ChatMessageRole.user);

    return ChatMessage(
      id: messageId,
      conversationId:
          json['conversationId']?.toString() ?? conversationId ?? '',
      accountId: accountId,
      role: role,
      content:
          json['text']?.toString() ??
          json['content']?.toString() ??
          json['message']?.toString() ??
          '',
      createdAt:
          _parseDate(json['createdAt']) ??
          _parseDateFromUuidV7(messageId) ??
          DateTime.now(),
      suggestions: ChatSuggestion.fromList(json['suggestions']),
      isMarkdown: role == ChatMessageRole.assistant,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? accountId,
    ChatMessageRole? role,
    String? content,
    DateTime? createdAt,
    List<ChatSuggestion>? suggestions,
    bool? isMarkdown,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      accountId: accountId ?? this.accountId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      suggestions: suggestions ?? this.suggestions,
      isMarkdown: isMarkdown ?? this.isMarkdown,
    );
  }
}

class SendMessageResponse {
  const SendMessageResponse({
    this.chatbotMessage,
    required this.suggestions,
    this.conversationId,
  });

  final String? chatbotMessage;
  final List<ChatSuggestion> suggestions;
  final String? conversationId;

  factory SendMessageResponse.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return SendMessageResponse(
      chatbotMessage: json['chatbotMessage']?.toString(),
      suggestions: ChatSuggestion.fromList(json['suggestions']),
      conversationId: json['conversationId']?.toString(),
    );
  }

  bool get hasAssistantPayload {
    final content = chatbotMessage?.trim() ?? '';
    return content.isNotEmpty || suggestions.isNotEmpty;
  }
}

class ConversationDetail {
  const ConversationDetail({
    required this.id,
    required this.title,
    required this.messages,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;

  factory ConversationDetail.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    final id = json['id']?.toString() ?? '';
    final messages = _safeList(
      json['messages'] ?? json['items'] ?? json['conversationMessages'],
    );

    return ConversationDetail(
      id: id,
      title: json['title']?.toString() ?? 'Untitled conversation',
      messages: messages
          .map((item) => ChatMessage.fromJson(item, conversationId: id))
          .toList(),
    );
  }
}

class MessageListResponse {
  const MessageListResponse({required this.items, this.meta});

  final List<dynamic> items;
  final PaginationMeta? meta;

  factory MessageListResponse.fromJson(dynamic rawJson) {
    final json = _safeMap(rawJson);
    return MessageListResponse(
      items: _safeList(json['items']),
      meta: json['meta'] == null ? null : PaginationMeta.fromJson(json['meta']),
    );
  }
}

Map<String, dynamic> _safeMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return {};
}

List<dynamic> _safeList(dynamic data) {
  if (data is List) {
    return data;
  }
  return <dynamic>[];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

DateTime? _parseDateFromUuidV7(String value) {
  if (value.length < 15 || value[14] != '7') {
    return null;
  }

  final compact = value.replaceAll('-', '');
  if (compact.length < 12) {
    return null;
  }

  final timestampHex = compact.substring(0, 12);
  final milliseconds = int.tryParse(timestampHex, radix: 16);
  if (milliseconds == null) {
    return null;
  }

  return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
