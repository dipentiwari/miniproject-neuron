import 'package:flutter/material.dart';

class KnowledgeStatModel {
  const KnowledgeStatModel({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String value;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
