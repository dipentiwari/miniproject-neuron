import 'dart:convert';
import 'package:flutter/material.dart';

class ActivityModel {
  ActivityModel({
    required this.id,
    required this.title,
    required this.source,
    required this.category, // 'Document', 'Task', 'Connection', 'Settings', 'Chat'
    required this.actionType, // 'Created', 'Completed', 'Synced', 'Modified', 'Sent'
    required this.timestamp,
    required this.iconCodePoint,
    required this.colorValue,
    this.details = '',
  });

  final String id;
  final String title;
  final String source;
  final String category;
  final String actionType;
  final DateTime timestamp;
  final int iconCodePoint;
  final int colorValue;
  final String details;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'source': source,
        'category': category,
        'actionType': actionType,
        'timestamp': timestamp.toIso8601String(),
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'details': details,
      };

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        id: json['id'] as String,
        title: json['title'] as String,
        source: json['source'] as String,
        category: json['category'] as String? ?? 'General',
        actionType: json['actionType'] as String? ?? 'Viewed',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        iconCodePoint: json['iconCodePoint'] as int? ?? Icons.notifications_none.codePoint,
        colorValue: json['colorValue'] as int? ?? 0xFF7955F5,
        details: json['details'] as String? ?? '',
      );

  static String encodeList(List<ActivityModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ActivityModel> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
