import 'dart:convert';

class DocumentModel {
  DocumentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.source,
    required this.tags,
    required this.modifiedAt,
    this.isPinned = false,
  });

  final String id;
  String title;
  String content;
  String type; // 'PDF', 'Note', 'Code', 'Document', 'Project'
  String source; // 'Google Drive', 'Notion', 'GitHub', 'Local', 'Gmail'
  List<String> tags;
  DateTime modifiedAt;
  bool isPinned;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'type': type,
        'source': source,
        'tags': tags,
        'modifiedAt': modifiedAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        type: json['type'] as String? ?? 'Document',
        source: json['source'] as String? ?? 'Local',
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        modifiedAt: json['modifiedAt'] != null
            ? DateTime.tryParse(json['modifiedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        isPinned: json['isPinned'] as bool? ?? false,
      );

  static String encodeList(List<DocumentModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<DocumentModel> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

