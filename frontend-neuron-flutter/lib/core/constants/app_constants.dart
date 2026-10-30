class AppConstants {
  AppConstants._();

  static const appName = 'NEURON';
  static const appTagline = 'Your Second Brain for the Digital World';
  static const appVersion = '1.0.0';
  static const appBuildNumber = '100';

  // Default User Profile
  static const defaultUserName = 'Dipen';
  static const defaultUserFullName = 'Dipen Patel';
  static const defaultUserEmail = 'dipen@example.com';

  // Backend Defaults (10.0.2.2 is Android emulator loopback for localhost)
  static const defaultApiBaseUrl = 'http://10.0.2.2:8000';
  static const apiTimeout = Duration(seconds: 10);

  // Storage Keys
  static const keyThemePref = 'neuron_theme_preference';
  static const keyUserName = 'neuron_user_name';
  static const keyUserFullName = 'neuron_user_full_name';
  static const keyUserEmail = 'neuron_user_email';
  static const keyApiUrl = 'neuron_api_url';
  static const keyApiKey = 'neuron_api_key';
  static const keyAiResponseStyle = 'neuron_ai_response_style';
  static const keyLanguage = 'neuron_language';
  static const keyAutoSync = 'neuron_auto_sync';
  static const keySyncFrequency = 'neuron_sync_frequency';
  static const keySaveChatHistory = 'neuron_save_chat_history';
  static const keyPushNotifications = 'neuron_push_notifications';
  static const keyTaskReminders = 'neuron_task_reminders';
  static const keyDailyDigest = 'neuron_daily_digest';
  static const keyTasksData = 'neuron_tasks_json';
  static const keyDocumentsData = 'neuron_documents_json';
  static const keyConnectionsData = 'neuron_connections_json';
  static const keyActivitiesData = 'neuron_activities_json';
  static const keyChatSessionsData = 'neuron_chat_sessions_json';
}
