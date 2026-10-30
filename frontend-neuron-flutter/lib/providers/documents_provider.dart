import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../services/storage_service.dart';
import 'activity_provider.dart';

enum DocumentSort { recentlyModified, titleAsc, source }

class DocumentsProvider extends ChangeNotifier {
  List<DocumentModel> _documents = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  DocumentSort _currentSort = DocumentSort.recentlyModified;
  ActivityProvider? _activityProvider;

  DocumentsProvider() {
    _documents = _seedDefaultDocuments();
    _init();
  }

  void updateActivityProvider(ActivityProvider provider) {
    _activityProvider = provider;
  }

  List<DocumentModel> get allDocuments => List.unmodifiable(_documents);
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  DocumentSort get currentSort => _currentSort;

  List<DocumentModel> get filteredDocuments {
    var list = List<DocumentModel>.from(_documents);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((d) {
        final inTitle = d.title.toLowerCase().contains(q);
        final inContent = d.content.toLowerCase().contains(q);
        final inTags = d.tags.any((t) => t.toLowerCase().contains(q));
        final inSource = d.source.toLowerCase().contains(q);
        return inTitle || inContent || inTags || inSource;
      }).toList();
    }

    if (_selectedCategory != 'All') {
      list = list.where((d) => d.type.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    switch (_currentSort) {
      case DocumentSort.recentlyModified:
        list.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        break;
      case DocumentSort.titleAsc:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case DocumentSort.source:
        list.sort((a, b) => a.source.compareTo(b.source));
        break;
    }

    return list;
  }

  Future<void> _init() async {
    final stored = await StorageService.loadDocuments();
    if (stored != null && stored.isNotEmpty) {
      _documents = stored;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setSort(DocumentSort sort) {
    if (_currentSort != sort) {
      _currentSort = sort;
      notifyListeners();
    }
  }

  Future<void> togglePin(String id) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index == -1) return;

    _documents[index].isPinned = !_documents[index].isPinned;
    notifyListeners();
    await StorageService.saveDocuments(_documents);
  }

  Future<void> addDocument({
    required String title,
    required String content,
    required String type,
    required String source,
    required List<String> tags,
  }) async {
    final doc = DocumentModel(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      content: content.trim(),
      type: type,
      source: source,
      tags: tags,
      modifiedAt: DateTime.now(),
    );

    _documents.insert(0, doc);
    notifyListeners();
    await StorageService.saveDocuments(_documents);

    _activityProvider?.logActivity(
      title: 'Created "${doc.title}"',
      source: doc.source,
      category: 'Document',
      actionType: 'Created',
      iconCodePoint: Icons.note_add_outlined.codePoint,
      colorValue: 0xFF7955F5,
      details: 'Added new document to Knowledge Base under ${doc.type}.',
    );
  }

  Future<void> updateDocument({
    required String id,
    required String title,
    required String content,
    required String type,
    required String source,
    required List<String> tags,
  }) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final doc = _documents[index];
    doc.title = title.trim();
    doc.content = content.trim();
    doc.type = type;
    doc.source = source;
    doc.tags = tags;
    doc.modifiedAt = DateTime.now();

    notifyListeners();
    await StorageService.saveDocuments(_documents);

    _activityProvider?.logActivity(
      title: 'Updated "${doc.title}"',
      source: doc.source,
      category: 'Document',
      actionType: 'Modified',
      iconCodePoint: Icons.edit_note.codePoint,
      colorValue: 0xFF3B82F6,
    );
  }

  Future<void> deleteDocument(String id) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final doc = _documents.removeAt(index);
    notifyListeners();
    await StorageService.saveDocuments(_documents);

    _activityProvider?.logActivity(
      title: 'Deleted "${doc.title}"',
      source: doc.source,
      category: 'Document',
      actionType: 'Modified',
      iconCodePoint: Icons.delete_outline.codePoint,
      colorValue: 0xFFEF4444,
    );
  }

  List<DocumentModel> _seedDefaultDocuments() {
    final now = DateTime.now();
    return [
      DocumentModel(
        id: 'doc_1',
        title: 'Machine Learning Notes.pdf',
        content:
            'Comprehensive notes on Neural Networks, Transformers, RAG architecture, and embeddings. Includes mathematical formulations of self-attention and cross-entropy loss functions.',
        type: 'Document',
        source: 'Google Drive',
        tags: ['AI', 'ML', 'Research', 'Deep Learning'],
        modifiedAt: now.subtract(const Duration(hours: 2)),
        isPinned: true,
      ),
      DocumentModel(
        id: 'doc_2',
        title: 'auth_service.dart',
        content:
            'Flutter JWT Authentication Service with automated token refresh, persistent keystore storage, and biometric verification hooks. Handles edge cases for token expiry during network loss.',
        type: 'Code',
        source: 'GitHub',
        tags: ['Flutter', 'Dart', 'Auth', 'Security'],
        modifiedAt: now.subtract(const Duration(hours: 5)),
        isPinned: true,
      ),
      DocumentModel(
        id: 'doc_3',
        title: 'Flutter Architecture Blueprint',
        content:
            'Design guidelines for clean architecture in Flutter using Provider / Riverpod state management, sound null safety, and responsive adaptive layouts for mobile and web surfaces.',
        type: 'Note',
        source: 'Notion',
        tags: ['Flutter', 'Architecture', 'CleanCode'],
        modifiedAt: now.subtract(const Duration(days: 1)),
      ),
      DocumentModel(
        id: 'doc_4',
        title: 'BloodSync Project Overview',
        content:
            'Emergency blood donation and matching platform. Fast matching algorithms, live GPS routing, and push notification triggers for urgent nearby donor requests.',
        type: 'Project',
        source: 'GitHub',
        tags: ['Project', 'BloodSync', 'Mobile'],
        modifiedAt: now.subtract(const Duration(days: 3)),
      ),
      DocumentModel(
        id: 'doc_5',
        title: 'Resume - Dipen Patel.pdf',
        content:
            'Professional resume highlighting Flutter development, Full-Stack engineering with FastAPI, and AI integration experience with LangChain.',
        type: 'Document',
        source: 'Gmail',
        tags: ['Career', 'Resume', 'Dipen'],
        modifiedAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
