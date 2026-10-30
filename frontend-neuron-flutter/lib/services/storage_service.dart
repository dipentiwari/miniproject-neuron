import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/task_model.dart';
import '../models/document_model.dart';
import '../models/connection_model.dart';
import '../models/activity_model.dart';
import '../models/chat_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- General String Helpers ---
  static Future<String?> getString(String key) async {
    final p = await prefs;
    return p.getString(key);
  }

  static Future<void> setString(String key, String value) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  // --- Tasks ---
  static Future<void> saveTasks(List<TaskModel> tasks) async {
    final p = await prefs;
    await p.setString(AppConstants.keyTasksData, TaskModel.encodeList(tasks));
  }

  static Future<List<TaskModel>?> loadTasks() async {
    final p = await prefs;
    final jsonStr = p.getString(AppConstants.keyTasksData);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    return TaskModel.decodeList(jsonStr);
  }

  // --- Documents ---
  static Future<void> saveDocuments(List<DocumentModel> docs) async {
    final p = await prefs;
    await p.setString(AppConstants.keyDocumentsData, DocumentModel.encodeList(docs));
  }

  static Future<List<DocumentModel>?> loadDocuments() async {
    final p = await prefs;
    final jsonStr = p.getString(AppConstants.keyDocumentsData);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    return DocumentModel.decodeList(jsonStr);
  }

  // --- Connections ---
  static Future<void> saveConnections(List<ConnectionModel> connections) async {
    final p = await prefs;
    await p.setString(AppConstants.keyConnectionsData, ConnectionModel.encodeList(connections));
  }

  static Future<List<ConnectionModel>?> loadConnections() async {
    final p = await prefs;
    final jsonStr = p.getString(AppConstants.keyConnectionsData);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    return ConnectionModel.decodeList(jsonStr);
  }

  // --- Activities ---
  static Future<void> saveActivities(List<ActivityModel> activities) async {
    final p = await prefs;
    await p.setString(AppConstants.keyActivitiesData, ActivityModel.encodeList(activities));
  }

  static Future<List<ActivityModel>?> loadActivities() async {
    final p = await prefs;
    final jsonStr = p.getString(AppConstants.keyActivitiesData);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    return ActivityModel.decodeList(jsonStr);
  }

  // --- Chat Sessions ---
  static Future<void> saveChatSessions(List<ChatSession> sessions) async {
    final p = await prefs;
    await p.setString(AppConstants.keyChatSessionsData, ChatSession.encodeList(sessions));
  }

  static Future<List<ChatSession>?> loadChatSessions() async {
    final p = await prefs;
    final jsonStr = p.getString(AppConstants.keyChatSessionsData);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    return ChatSession.decodeList(jsonStr);
  }

  // --- Clear All ---
  static Future<void> clearAll() async {
    final p = await prefs;
    await p.clear();
  }
}

