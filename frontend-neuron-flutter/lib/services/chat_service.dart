import '../core/network/api_client.dart';
import '../models/chat_model.dart';
import '../models/document_model.dart';

class ChatResponseResult {
  final String text;
  final List<SourceCitation> sources;
  final bool isSimulated;
  final bool isError;
  final String? errorMessage;

  ChatResponseResult({
    required this.text,
    this.sources = const [],
    this.isSimulated = false,
    this.isError = false,
    this.errorMessage,
  });
}

class ChatService {
  final ApiClient _apiClient;

  ChatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  ApiClient get apiClient => _apiClient;

  Future<ChatResponseResult> sendMessage({
    required String query,
    required String responseStyle,
    List<DocumentModel> localDocuments = const [],
  }) async {
    // Attempt real backend call to FastAPI
    final result = await _apiClient.post('/api/chat', body: {
      'message': query,
      'response_style': responseStyle,
    });

    if (result.isSuccess && result.data != null) {
      final data = result.data!;
      final replyText = data['response'] as String? ?? data['text'] as String? ?? '';
      final rawSources = data['sources'] as List<dynamic>? ?? [];
      final sources = rawSources.map((s) {
        if (s is Map<String, dynamic>) {
          return SourceCitation.fromJson(s);
        }
        return SourceCitation(title: s.toString(), source: 'FastAPI / RAG');
      }).toList();

      return ChatResponseResult(
        text: replyText,
        sources: sources,
        isSimulated: false,
      );
    }

    // Backend is unavailable - provide honest simulated response based on knowledge base
    return _generateSimulatedResponse(query, responseStyle, localDocuments);
  }

  ChatResponseResult _generateSimulatedResponse(
    String query,
    String responseStyle,
    List<DocumentModel> documents,
  ) {
    final lower = query.toLowerCase();

    // Check for matching documents in knowledge base
    final matchingDocs = documents.where((doc) {
      final inTitle = doc.title.toLowerCase().contains(lower);
      final inContent = doc.content.toLowerCase().contains(lower);
      final inTags = doc.tags.any((t) => lower.contains(t.toLowerCase()));
      return inTitle || inContent || inTags;
    }).toList();

    final citations = <SourceCitation>[];

    String body = '';

    if (matchingDocs.isNotEmpty) {
      final top = matchingDocs.first;
      citations.add(SourceCitation(
        title: top.title,
        source: top.source,
        snippet: top.content.length > 80 ? '${top.content.substring(0, 80)}...' : top.content,
      ));

      if (lower.contains('auth') || lower.contains('jwt')) {
        body =
            '[Demo Mode: Offline Simulation]\n\nBased on your indexed document "${top.title}", authentication in BloodSync uses JWT with short-lived access tokens and refresh token rotation. Tokens are stored in secure mobile keystores.';
      } else if (lower.contains('flutter') || lower.contains('ui')) {
        body =
            '[Demo Mode: Offline Simulation]\n\nAccording to "${top.title}", your Flutter project is structured with Material 3, custom purple/blue theme tokens, Riverpod/Provider state management, and reusable components.';
      } else {
        body =
            '[Demo Mode: Offline Simulation]\n\nI located relevant notes in "${top.title}" (${top.source}):\n\n"${top.content.length > 140 ? '${top.content.substring(0, 140)}...' : top.content}"\n\nConnect a live FastAPI backend with LangChain in Settings to activate neural reasoning.';
      }
    } else if (lower.contains('schedule') || lower.contains('meeting') || lower.contains('today')) {
      citations.add(const SourceCitation(title: "Today's Schedule", source: 'Calendar'));
      body =
          '[Demo Mode: Offline Simulation]\n\nToday you have Team Standup at 10:00 AM, BloodSync Code Review at 2:00 PM, and a Client Call at 4:30 PM.';
    } else if (lower.contains('task') || lower.contains('todo')) {
      citations.add(const SourceCitation(title: 'Tasks Database', source: 'NEURON'));
      body =
          '[Demo Mode: Offline Simulation]\n\nYour active tasks include: Complete Flutter UI, Submit AI assignment, and Review BloodSync API.';
    } else {
      citations.add(const SourceCitation(title: 'NEURON Knowledge Graph', source: 'Local Index'));
      body =
          '[Demo Mode: Offline Simulation]\n\nI processed "$query" against your indexed offline knowledge. To generate live AI completions with full RAG embeddings, ensure your FastAPI backend is running at ${apiClient.baseUrl} and reachable.';
    }

    if (responseStyle == 'Concise') {
      body += '\n\n*Response formatted as concise summary.*';
    } else if (responseStyle == 'Detailed') {
      body += '\n\n*Detailed mode: Key sources and related context are pinned below.*';
    }

    return ChatResponseResult(
      text: body,
      sources: citations,
      isSimulated: true,
    );
  }
}

