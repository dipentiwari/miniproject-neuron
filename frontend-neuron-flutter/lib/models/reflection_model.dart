import 'dart:convert';

class ReflectionModel {
  final String id;
  final DateTime date;
  final String energyLevel;
  final int focusRating;
  final String breakthrough;
  final String improvementArea;
  final String aiSynthesis;
  final String workspaceName;

  const ReflectionModel({
    required this.id,
    required this.date,
    required this.energyLevel,
    required this.focusRating,
    required this.breakthrough,
    required this.improvementArea,
    required this.aiSynthesis,
    required this.workspaceName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'energyLevel': energyLevel,
        'focusRating': focusRating,
        'breakthrough': breakthrough,
        'improvementArea': improvementArea,
        'aiSynthesis': aiSynthesis,
        'workspaceName': workspaceName,
      };

  factory ReflectionModel.fromJson(Map<String, dynamic> json) => ReflectionModel(
        id: json['id'] as String,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        energyLevel: json['energyLevel'] as String? ?? 'High Focus',
        focusRating: json['focusRating'] as int? ?? 4,
        breakthrough: json['breakthrough'] as String? ?? '',
        improvementArea: json['improvementArea'] as String? ?? '',
        aiSynthesis: json['aiSynthesis'] as String? ?? '',
        workspaceName: json['workspaceName'] as String? ?? 'Personal',
      );

  static String encodeList(List<ReflectionModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ReflectionModel> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => ReflectionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

