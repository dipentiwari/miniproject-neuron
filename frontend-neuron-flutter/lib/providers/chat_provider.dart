import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/document_model.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import 'activity_provider.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  List<ChatSession> _sessions = [];
  String _activeSessionId = '';
  bool _isLoading = false;
  String? _lastError;
  ActivityProvider? _activityProvider;

  ChatProvider({ChatService? chatService}) : _chatService = chatService ?? ChatService() {
    _sessions = _seedDefaultSessions();
    _activeSessionId = _sessions.first.id;
    _init();
  }

  void updateActivityProvider(ActivityProvider provider) {
    _activityProvider = provider;
  }

  ChatService get chatService => _chatService;
  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  String get activeSessionId => _activeSessionId;

  ChatSession get activeSession {
    final match = _sessions.where((s) => s.id == _activeSessionId);
    if (match.isNotEmpty) return match.first;
    if (_sessions.isNotEmpty) return _sessions.first;

    // Fallback if empty
    final fallback = ChatSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Conversation',
      createdAt: DateTime.now(),
      messages: [],
    );
    _sessions.add(fallback);
    _activeSessionId = fallback.id;
    return fallback;
  }

  List<ChatMessage> get messages => activeSession.messages;

  Future<void> _init() async {
    final stored = await StorageService.loadChatSessions();
    if (stored != null && stored.isNotEmpty) {
      _sessions = stored;
      _activeSessionId = _sessions.first.id;
      notifyListeners();
    }
  }

  void startNewSession() {
    final newSession = ChatSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Conversation',
      createdAt: DateTime.now(),
      messages: [],
    );
    _sessions.insert(0, newSession);
    _activeSessionId = newSession.id;
    _lastError = null;
    notifyListeners();
    StorageService.saveChatSessions(_sessions);

    _activityProvider?.logActivity(
      title: 'Started New AI Chat',
      source: 'Chat',
      category: 'Chat',
      actionType: 'Created',
      iconCodePoint: Icons.chat_bubble_outline.codePoint,
      colorValue: 0xFF7955F5,
    );
  }

  void selectSession(String sessionId) {
    if (_activeSessionId != sessionId) {
      _activeSessionId = sessionId;
      _lastError = null;
      notifyListeners();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    if (_sessions.length <= 1) {
      // Just clear current
      activeSession.messages.clear();
      activeSession.title = 'New Conversation';
      notifyListeners();
      await StorageService.saveChatSessions(_sessions);
      return;
    }

    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSessionId == sessionId) {
      _activeSessionId = _sessions.first.id;
    }
    notifyListeners();
    await StorageService.saveChatSessions(_sessions);
  }

  Future<void> sendMessage(
    String query, {
    String responseStyle = 'Detailed',
    List<DocumentModel> localDocuments = const [],
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _isLoading) return;

    final session = activeSession;

    // Auto-title session on first user message
    if (session.messages.isEmpty || session.title == 'New Conversation') {
      session.title = trimmed.length > 28 ? '${trimmed.substring(0, 28)}...' : trimmed;
    }

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    session.messages.add(userMsg);
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final reply = await _chatService.sendMessage(
        query: trimmed,
        responseStyle: responseStyle,
        localDocuments: localDocuments,
      );

      final aiMsg = ChatMessage(
        id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
        text: reply.text,
        isUser: false,
        timestamp: DateTime.now(),
        sources: reply.sources,
        isError: reply.isError,
        isSimulated: reply.isSimulated,
      );

      session.messages.add(aiMsg);
      _isLoading = false;
      notifyListeners();
      await StorageService.saveChatSessions(_sessions);

      _activityProvider?.logActivity(
        title: 'Query: "${trimmed.length > 24 ? '${trimmed.substring(0, 24)}...' : trimmed}"',
        source: 'AI Chat',
        category: 'Chat',
        actionType: 'Sent',
        iconCodePoint: Icons.auto_awesome.codePoint,
        colorValue: 0xFF7955F5,
      );
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      session.messages.add(ChatMessage(
        id: 'msg_err_${DateTime.now().millisecondsSinceEpoch}',
        text: 'An error occurred: $e. Tap retry to attempt again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
      notifyListeners();
      await StorageService.saveChatSessions(_sessions);
    }
  }

  Future<void> retryLastMessage({
    String responseStyle = 'Detailed',
    List<DocumentModel> localDocuments = const [],
  }) async {
    final session = activeSession;
    if (session.messages.isEmpty) return;

    // Find the last user message
    final lastUserMsg = session.messages.lastWhere((m) => m.isUser, orElse: () => session.messages.last);
    if (!lastUserMsg.isUser) return;

    // Remove the trailing error/simulated message if present
    if (!session.messages.last.isUser) {
      session.messages.removeLast();
    }

    await sendMessage(
      lastUserMsg.text,
      responseStyle: responseStyle,
      localDocuments: localDocuments,
    );
  }

  List<ChatSession> _seedDefaultSessions() {
    final now = DateTime.now();
    return [
      ChatSession(
        id: 'sess_default_1',
        title: 'Authentication & BloodSync',
        createdAt: now.subtract(const Duration(hours: 3)),
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'How did I implement authentication in BloodSync?',
            isUser: true,
            timestamp: now.subtract(const Duration(hours: 3, minutes: 2)),
          ),
          ChatMessage(
            id: 'm2',
            text:
                '[Demo Mode: Offline Simulation]\n\nYou implemented JWT-based authentication in the BloodSync backend. The auth flow uses access tokens with refresh token rotation stored securely in Android Keystore / iOS Keychain.',
            isUser: false,
            timestamp: now.subtract(const Duration(hours: 3)),
            isSimulated: true,
            sources: [
              const SourceCitation(title: 'auth_service.dart', source: 'GitHub'),
              const SourceCitation(title: 'Machine Learning Notes.pdf', source: 'Google Drive'),
            ],
          ),
        ],
      ),
      ChatSession(
        id: 'sess_default_2',
        title: 'Flutter State Management',
        createdAt: now.subtract(const Duration(days: 1)),
        messages: [
          ChatMessage(
            id: 'm3',
            text: 'What state management is recommended for NEURON?',
            isUser: true,
            timestamp: now.subtract(const Duration(days: 1, minutes: 5)),
          ),
          ChatMessage(
            id: 'm4',
            text:
                '[Demo Mode: Offline Simulation]\n\nProvider and Riverpod are used across NEURON. ChangeNotifier providers handle local reactive state, while SharedPreferences persists tasks, documents, connections, and chat sessions locally.',
            isUser: false,
            timestamp: now.subtract(const Duration(days: 1)),
            isSimulated: true,
            sources: [
              const SourceCitation(title: 'Flutter Architecture Blueprint', source: 'Notion'),
            ],
          ),
        ],
      ),
    ];
  }
}
