import 'dart:convert';
import 'package:flutter/material.dart';

enum ScheduleCategory { work, study, meeting, personal }

class ScheduleModel {
  ScheduleModel({
    required this.id,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.category,
    this.isCompleted = false,
  });

  final String id;
  final String time;
  final String title;
  final String subtitle;
  final ScheduleCategory category;
  bool isCompleted;

  Color categoryColor(bool isDark) {
    switch (category) {
      case ScheduleCategory.work:
        return const Color(0xFF7955F5);
      case ScheduleCategory.study:
        return const Color(0xFF22C55E);
      case ScheduleCategory.meeting:
        return const Color(0xFF3B82F6);
      case ScheduleCategory.personal:
        return const Color(0xFFF59E0B);
    }
  }

  String get categoryLabel {
    switch (category) {
      case ScheduleCategory.work:
        return 'Work';
      case ScheduleCategory.study:
        return 'Study';
      case ScheduleCategory.meeting:
        return 'Meeting';
      case ScheduleCategory.personal:
        return 'Personal';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time,
        'title': title,
        'subtitle': subtitle,
        'category': category.name,
        'isCompleted': isCompleted,
      };

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'] as String,
        time: json['time'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        category: ScheduleCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => ScheduleCategory.work,
        ),
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  static String encodeList(List<ScheduleModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ScheduleModel> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
