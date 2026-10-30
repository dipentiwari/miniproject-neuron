import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../services/storage_service.dart';
import 'activity_provider.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  ActivityProvider? _activityProvider;

  String _userName = AppConstants.defaultUserName;
  String _userFullName = AppConstants.defaultUserFullName;
  String _userEmail = AppConstants.defaultUserEmail;

  String _aiResponseStyle = 'Detailed';
  String _language = 'English';
  bool _autoSync = true;
  String _syncFrequency = 'Hourly';
  bool _saveChatHistory = true;

  bool _pushNotifications = true;
  bool _taskReminders = true;
  bool _dailyDigest = false;

  String _apiUrl = AppConstants.defaultApiBaseUrl;
  String _apiKey = '';

  SettingsProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient() {
    _loadSettings();
  }

  void updateActivityProvider(ActivityProvider provider) {
    _activityProvider = provider;
  }

  ApiClient get apiClient => _apiClient;

  String get userName => _userName;
  String get userFullName => _userFullName;
  String get userEmail => _userEmail;

  String get aiResponseStyle => _aiResponseStyle;
  String get language => _language;
  bool get autoSync => _autoSync;
  String get syncFrequency => _syncFrequency;
  bool get saveChatHistory => _saveChatHistory;

  bool get pushNotifications => _pushNotifications;
  bool get taskReminders => _taskReminders;
  bool get dailyDigest => _dailyDigest;

  String get apiUrl => _apiUrl;
  String get apiKey => _apiKey;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(AppConstants.keyUserName)) {
      _userName = prefs.getString(AppConstants.keyUserName)!;
    }
    if (prefs.containsKey(AppConstants.keyUserFullName)) {
      _userFullName = prefs.getString(AppConstants.keyUserFullName)!;
    }
    if (prefs.containsKey(AppConstants.keyUserEmail)) {
      _userEmail = prefs.getString(AppConstants.keyUserEmail)!;
    }

    if (prefs.containsKey(AppConstants.keyAiResponseStyle)) {
      _aiResponseStyle = prefs.getString(AppConstants.keyAiResponseStyle)!;
    }
    if (prefs.containsKey(AppConstants.keyLanguage)) {
      _language = prefs.getString(AppConstants.keyLanguage)!;
    }
    if (prefs.containsKey(AppConstants.keyAutoSync)) {
      _autoSync = prefs.getBool(AppConstants.keyAutoSync)!;
    }
    if (prefs.containsKey(AppConstants.keySyncFrequency)) {
      _syncFrequency = prefs.getString(AppConstants.keySyncFrequency)!;
    }
    if (prefs.containsKey(AppConstants.keySaveChatHistory)) {
      _saveChatHistory = prefs.getBool(AppConstants.keySaveChatHistory)!;
    }

    if (prefs.containsKey(AppConstants.keyPushNotifications)) {
      _pushNotifications = prefs.getBool(AppConstants.keyPushNotifications)!;
    }
    if (prefs.containsKey(AppConstants.keyTaskReminders)) {
      _taskReminders = prefs.getBool(AppConstants.keyTaskReminders)!;
    }
    if (prefs.containsKey(AppConstants.keyDailyDigest)) {
      _dailyDigest = prefs.getBool(AppConstants.keyDailyDigest)!;
    }

    if (prefs.containsKey(AppConstants.keyApiUrl)) {
      _apiUrl = prefs.getString(AppConstants.keyApiUrl)!;
    }
    if (prefs.containsKey(AppConstants.keyApiKey)) {
      _apiKey = prefs.getString(AppConstants.keyApiKey)!;
    }

    _apiClient.updateConfig(baseUrl: _apiUrl, apiKey: _apiKey);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String fullName,
    required String email,
  }) async {
    _userName = name.trim();
    _userFullName = fullName.trim();
    _userEmail = email.trim();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, _userName);
    await prefs.setString(AppConstants.keyUserFullName, _userFullName);
    await prefs.setString(AppConstants.keyUserEmail, _userEmail);

    _activityProvider?.logActivity(
      title: 'Updated Profile Info',
      source: 'Settings',
      category: 'Settings',
      actionType: 'Modified',
      iconCodePoint: Icons.person_outline.codePoint,
      colorValue: 0xFF7955F5,
    );
  }

  Future<void> setAiResponseStyle(String style) async {
    _aiResponseStyle = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAiResponseStyle, style);
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, lang);
  }

  Future<void> setAutoSync(bool val) async {
    _autoSync = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyAutoSync, val);
  }

  Future<void> setSyncFrequency(String freq) async {
    _syncFrequency = freq;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySyncFrequency, freq);
  }

  Future<void> setSaveChatHistory(bool val) async {
    _saveChatHistory = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keySaveChatHistory, val);
  }

  Future<void> setPushNotifications(bool val) async {
    _pushNotifications = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyPushNotifications, val);
  }

  Future<void> setTaskReminders(bool val) async {
    _taskReminders = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyTaskReminders, val);
  }

  Future<void> setDailyDigest(bool val) async {
    _dailyDigest = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDailyDigest, val);
  }

  Future<void> updateApiConfig({required String url, required String key}) async {
    _apiUrl = url.trim();
    _apiKey = key.trim();
    _apiClient.updateConfig(baseUrl: _apiUrl, apiKey: _apiKey);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyApiUrl, _apiUrl);
    await prefs.setString(AppConstants.keyApiKey, _apiKey);

    _activityProvider?.logActivity(
      title: 'Updated FastAPI Backend Endpoint',
      source: 'Settings',
      category: 'Settings',
      actionType: 'Modified',
      iconCodePoint: Icons.cloud_sync.codePoint,
      colorValue: 0xFF3B82F6,
      details: 'New target URL: $_apiUrl',
    );
  }

  Future<ApiResult<Map<String, dynamic>>> testBackendConnection() async {
    return _apiClient.testConnection();
  }

  Future<String> exportLocalDataJson() async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = prefs.getString(AppConstants.keyTasksData) ?? '[]';
    final docs = prefs.getString(AppConstants.keyDocumentsData) ?? '[]';
    final connections = prefs.getString(AppConstants.keyConnectionsData) ?? '[]';
    final activities = prefs.getString(AppConstants.keyActivitiesData) ?? '[]';
    final chats = prefs.getString(AppConstants.keyChatSessionsData) ?? '[]';

    final snapshot = {
      'exported_at': DateTime.now().toIso8601String(),
      'app': AppConstants.appName,
      'version': AppConstants.appVersion,
      'user': {
        'name': _userName,
        'fullName': _userFullName,
        'email': _userEmail,
      },
      'settings': {
        'response_style': _aiResponseStyle,
        'language': _language,
        'auto_sync': _autoSync,
        'sync_frequency': _syncFrequency,
        'api_url': _apiUrl,
      },
      'tasks': jsonDecode(tasks),
      'documents': jsonDecode(docs),
      'connections': jsonDecode(connections),
      'activities': jsonDecode(activities),
      'chat_sessions': jsonDecode(chats),
    };

    return const JsonEncoder.withIndent('  ').convert(snapshot);
  }

  Future<void> clearAllData() async {
    await StorageService.clearAll();
    await _loadSettings();
    _activityProvider?.logActivity(
      title: 'Reset Local Database',
      source: 'Settings',
      category: 'Settings',
      actionType: 'Modified',
      iconCodePoint: Icons.delete_forever.codePoint,
      colorValue: 0xFFEF4444,
      details: 'All locally stored records were cleared.',
    );
  }
}
