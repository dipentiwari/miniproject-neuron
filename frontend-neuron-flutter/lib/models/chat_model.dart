import 'dart:convert';

class SourceCitation {
  const SourceCitation({
    required this.title,
    required this.source,
    this.snippet = '',
  });

  final String title;
  final String source;
  final String snippet;

  Map<String, dynamic> toJson() => {
        'title': title,
        'source': source,
        'snippet': snippet,
      };

  factory SourceCitation.fromJson(Map<String, dynamic> json) => SourceCitation(
        title: json['title'] as String? ?? 'Reference',
        source: json['source'] as String? ?? 'Knowledge Base',
        snippet: json['snippet'] as String? ?? '',
      );
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources = const [],
    this.isError = false,
    this.isSimulated = false,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<SourceCitation> sources;
  final bool isError;
  final bool isSimulated;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'sources': sources.map((s) => s.toJson()).toList(),
        'isError': isError,
        'isSimulated': isSimulated,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        isUser: json['isUser'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        sources: (json['sources'] as List<dynamic>?)
                ?.map((e) => SourceCitation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isError: json['isError'] as bool? ?? false,
        isSimulated: json['isSimulated'] as bool? ?? false,
      );
}

class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  final String id;
  String title;
  final DateTime createdAt;
  List<ChatMessage> messages;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Conversation',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        messages: (json['messages'] as List<dynamic>?)
                ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  static String encodeList(List<ChatSession> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ChatSession> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

