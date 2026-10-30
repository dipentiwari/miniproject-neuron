import 'dart:convert';

enum TaskPriority { low, medium, high }
enum TaskSection { today, upcoming, completed }

class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.section,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  final String id;
  String title;
  String description;
  TaskSection section;
  bool isCompleted;
  TaskPriority priority;
  DateTime? dueDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'section': section.name,
        'isCompleted': isCompleted,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        section: TaskSection.values.firstWhere(
          (e) => e.name == json['section'],
          orElse: () => TaskSection.today,
        ),
        isCompleted: json['isCompleted'] as bool? ?? false,
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        dueDate: json['dueDate'] != null
            ? DateTime.tryParse(json['dueDate'] as String)
            : null,
      );

  static String encodeList(List<TaskModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<TaskModel> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
