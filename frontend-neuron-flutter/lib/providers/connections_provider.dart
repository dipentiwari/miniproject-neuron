import 'package:flutter/material.dart';
import '../models/connection_model.dart';
import '../services/storage_service.dart';
import 'activity_provider.dart';

class ConnectionsProvider extends ChangeNotifier {
  List<ConnectionModel> _connections = [];
  bool _isSyncingAll = false;
  ActivityProvider? _activityProvider;

  ConnectionsProvider() {
    _connections = _seedDefaultConnections();
    _init();
  }

  void updateActivityProvider(ActivityProvider provider) {
    _activityProvider = provider;
  }

  List<ConnectionModel> get connections => List.unmodifiable(_connections);
  bool get isSyncingAll => _isSyncingAll;

  int get connectedCount => _connections.where((c) => c.isConnected).length;

  Future<void> _init() async {
    final stored = await StorageService.loadConnections();
    if (stored != null && stored.isNotEmpty) {
      _connections = stored;
      notifyListeners();
    }
  }

  Future<void> connectDemo(String id) async {
    final index = _connections.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final conn = _connections[index];
    conn.status = ConnectionStatus.connectedDemo;
    conn.lastSyncTime = 'Just now';
    if (conn.accountDetail.isEmpty) {
      conn.accountDetail = 'dipen@demo.local';
    }

    notifyListeners();
    await StorageService.saveConnections(_connections);

    _activityProvider?.logActivity(
      title: 'Connected ${conn.name} (Demo Mode)',
      source: conn.name,
      category: 'Connection',
      actionType: 'Synced',
      iconCodePoint: conn.iconCodePoint,
      colorValue: conn.colorValue,
      details: 'Enabled simulated local integration mode with mock data indexing.',
    );
  }

  Future<void> connectLive(String id, String account) async {
    final index = _connections.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final conn = _connections[index];
    conn.status = ConnectionStatus.connectedLive;
    conn.accountDetail = account.trim().isNotEmpty ? account.trim() : 'Authorized User';
    conn.lastSyncTime = 'Just now';

    notifyListeners();
    await StorageService.saveConnections(_connections);

    _activityProvider?.logActivity(
      title: 'Connected ${conn.name} (Live OAuth)',
      source: conn.name,
      category: 'Connection',
      actionType: 'Synced',
      iconCodePoint: conn.iconCodePoint,
      colorValue: conn.colorValue,
      details: 'Live token issued and active synchronization registered.',
    );
  }

  Future<void> disconnect(String id) async {
    final index = _connections.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final conn = _connections[index];
    conn.status = ConnectionStatus.disconnected;
    conn.lastSyncTime = 'Disconnected';

    notifyListeners();
    await StorageService.saveConnections(_connections);

    _activityProvider?.logActivity(
      title: 'Disconnected ${conn.name}',
      source: conn.name,
      category: 'Connection',
      actionType: 'Modified',
      iconCodePoint: conn.iconCodePoint,
      colorValue: 0xFFEF4444,
      details: 'Tokens revoked and local sync paused.',
    );
  }

  Future<void> syncService(String id) async {
    final index = _connections.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final conn = _connections[index];
    conn.lastSyncTime = 'Just now';

    notifyListeners();
    await StorageService.saveConnections(_connections);

    _activityProvider?.logActivity(
      title: 'Synced ${conn.name}',
      source: conn.name,
      category: 'Connection',
      actionType: 'Synced',
      iconCodePoint: conn.iconCodePoint,
      colorValue: conn.colorValue,
      details: 'Re-indexed changes and verified token validity.',
    );
  }

  Future<void> syncAll() async {
    _isSyncingAll = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    for (final conn in _connections) {
      if (conn.isConnected) {
        conn.lastSyncTime = 'Just now';
      }
    }

    _isSyncingAll = false;
    notifyListeners();
    await StorageService.saveConnections(_connections);

    _activityProvider?.logActivity(
      title: 'Synchronized All Sources',
      source: 'NEURON',
      category: 'Connection',
      actionType: 'Synced',
      iconCodePoint: Icons.sync.codePoint,
      colorValue: 0xFF7955F5,
      details: 'Processed delta sync across all active integration endpoints.',
    );
  }

  List<ConnectionModel> _seedDefaultConnections() {
    return [
      ConnectionModel(
        id: 'drive',
        name: 'Google Drive',
        description: 'Read and index your documents, spreadsheets, and PDFs in real-time.',
        iconCodePoint: Icons.cloud_outlined.codePoint,
        colorValue: 0xFF3B82F6,
        status: ConnectionStatus.connectedDemo,
        accountDetail: '12.4 GB used (Demo)',
        lastSyncTime: '2h ago',
        requiredScopes: [
          'https://www.googleapis.com/auth/drive.readonly',
          'https://www.googleapis.com/auth/drive.metadata.readonly',
        ],
        setupNotes:
            'Requires Google Cloud Console OAuth 2.0 Client ID for Android and Web redirect flow.',
      ),
      ConnectionModel(
        id: 'gmail',
        name: 'Gmail',
        description: 'Search important emails, receipts, travel confirmations, and updates.',
        iconCodePoint: Icons.email_outlined.codePoint,
        colorValue: 0xFFEF4444,
        status: ConnectionStatus.connectedDemo,
        accountDetail: 'dipen@gmail.com (Demo)',
        lastSyncTime: 'Yesterday',
        requiredScopes: [
          'https://www.googleapis.com/auth/gmail.readonly',
        ],
        setupNotes: 'Requires Gmail API enabled and test user access in Google Cloud Console.',
      ),
      ConnectionModel(
        id: 'github',
        name: 'GitHub',
        description: 'Sync repositories, issues, pull requests, and commit snippets.',
        iconCodePoint: Icons.code.codePoint,
        colorValue: 0xFF8B5CF6,
        status: ConnectionStatus.connectedDemo,
        accountDetail: '42 repositories (Demo)',
        lastSyncTime: '4h ago',
        requiredScopes: ['repo', 'read:user', 'read:org'],
        setupNotes: 'Use a GitHub Personal Access Token (classic) or GitHub App OAuth flow.',
      ),
      ConnectionModel(
        id: 'notion',
        name: 'Notion',
        description: 'Import pages, project databases, and structured meeting notes.',
        iconCodePoint: Icons.note_alt_outlined.codePoint,
        colorValue: 0xFF22C55E,
        status: ConnectionStatus.connectedDemo,
        accountDetail: '8 workspaces (Demo)',
        lastSyncTime: '1d ago',
        requiredScopes: ['Read content', 'Read user info without email'],
        setupNotes: 'Requires an Internal Integration Secret token from Notion Developers Portal.',
      ),
      ConnectionModel(
        id: 'slack',
        name: 'Slack',
        description: 'Index team announcements, direct messages, and code snippets.',
        iconCodePoint: Icons.chat_outlined.codePoint,
        colorValue: 0xFF06B6D4,
        status: ConnectionStatus.disconnected,
        accountDetail: '',
        lastSyncTime: 'Not configured',
        requiredScopes: ['channels:read', 'groups:read', 'im:read', 'mpim:read'],
        setupNotes: 'Create a Slack App with Bot User OAuth Token in your workspace.',
      ),
      ConnectionModel(
        id: 'spotify',
        name: 'Spotify',
        description: 'Track listening habits, study playlists, and podcast transcripts.',
        iconCodePoint: Icons.music_note_outlined.codePoint,
        colorValue: 0xFF1DB954,
        status: ConnectionStatus.disconnected,
        accountDetail: '',
        lastSyncTime: 'Not configured',
        requiredScopes: ['user-read-recently-played', 'user-top-read'],
        setupNotes: 'Requires Spotify Developer Dashboard Client ID and Secret.',
      ),
      ConnectionModel(
        id: 'calendar',
        name: 'Google Calendar',
        description: 'Track schedule, meeting attendees, time blocks, and deadlines.',
        iconCodePoint: Icons.calendar_today_outlined.codePoint,
        colorValue: 0xFFF59E0B,
        status: ConnectionStatus.connectedDemo,
        accountDetail: '8 events this week (Demo)',
        lastSyncTime: '2d ago',
        requiredScopes: ['https://www.googleapis.com/auth/calendar.readonly'],
        setupNotes: 'Google Calendar API enabled on GCP project with OAuth credentials.',
      ),
    ];
  }
}
