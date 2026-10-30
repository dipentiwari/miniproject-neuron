import 'dart:convert';
import 'package:flutter/material.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String description;
  final int iconCodePoint;
  final int colorValue;
  final int itemCount;

  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCodePoint,
    required this.colorValue,
    this.itemCount = 0,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  WorkspaceModel copyWith({
    String? id,
    String? name,
    String? description,
    int? iconCodePoint,
    int? colorValue,
    int? itemCount,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'itemCount': itemCount,
      };

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) => WorkspaceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        iconCodePoint: json['iconCodePoint'] as int? ?? Icons.folder_outlined.codePoint,
        colorValue: json['colorValue'] as int? ?? 0xFF7955F5,
        itemCount: json['itemCount'] as int? ?? 0,
      );

  static String encodeList(List<WorkspaceModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<WorkspaceModel> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => WorkspaceModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

