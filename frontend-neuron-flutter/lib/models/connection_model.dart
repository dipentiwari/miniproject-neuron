import 'dart:convert';
import 'package:flutter/material.dart';

enum ConnectionStatus { disconnected, setupRequired, connectedDemo, connectedLive }

class ConnectionModel {
  ConnectionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCodePoint,
    required this.colorValue,
    this.status = ConnectionStatus.disconnected,
    this.accountDetail = '',
    this.lastSyncTime = '',
    required this.requiredScopes,
    this.setupNotes = '',
  });

  final String id;
  final String name;
  final String description;
  final int iconCodePoint;
  final int colorValue;
  ConnectionStatus status;
  String accountDetail;
  String lastSyncTime;
  final List<String> requiredScopes;
  final String setupNotes;

  bool get isConnected =>
      status == ConnectionStatus.connectedLive || status == ConnectionStatus.connectedDemo;

  bool get isLive => status == ConnectionStatus.connectedLive;
  bool get isDemo => status == ConnectionStatus.connectedDemo;

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'status': status.name,
        'accountDetail': accountDetail,
        'lastSyncTime': lastSyncTime,
        'requiredScopes': requiredScopes,
        'setupNotes': setupNotes,
      };

  factory ConnectionModel.fromJson(Map<String, dynamic> json) => ConnectionModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        colorValue: json['colorValue'] as int,
        status: ConnectionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ConnectionStatus.disconnected,
        ),
        accountDetail: json['accountDetail'] as String? ?? '',
        lastSyncTime: json['lastSyncTime'] as String? ?? '',
        requiredScopes: (json['requiredScopes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        setupNotes: json['setupNotes'] as String? ?? '',
      );

  static String encodeList(List<ConnectionModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ConnectionModel> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => ConnectionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
