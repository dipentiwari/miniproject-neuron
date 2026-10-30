import 'package:flutter/material.dart';
import '../models/workspace_model.dart';
import '../services/storage_service.dart';
import 'activity_provider.dart';

class WorkspaceProvider extends ChangeNotifier {
  static const String _storageKey = 'neuron_workspaces_list';
  static const String _activeKey = 'neuron_active_workspace_id';

  List<WorkspaceModel> _workspaces = [];
  String _activeWorkspaceId = 'personal';
  ActivityProvider? _activityProvider;

  WorkspaceProvider() {
    _workspaces = _seedDefaultWorkspaces();
    _init();
  }

  List<WorkspaceModel> get workspaces => List.unmodifiable(_workspaces);
  String get activeWorkspaceId => _activeWorkspaceId;

  WorkspaceModel get activeWorkspace {
    return _workspaces.firstWhere(
      (w) => w.id == _activeWorkspaceId,
      orElse: () => _workspaces.first,
    );
  }

  void updateActivityProvider(ActivityProvider activity) {
    _activityProvider = activity;
  }

  Future<void> _init() async {
    final savedJson = await StorageService.getString(_storageKey);
    if (savedJson != null && savedJson.isNotEmpty) {
      final decoded = WorkspaceModel.decodeList(savedJson);
      if (decoded.isNotEmpty) {
        _workspaces = decoded;
      }
    }

    final activeId = await StorageService.getString(_activeKey);
    if (activeId != null && _workspaces.any((w) => w.id == activeId)) {
      _activeWorkspaceId = activeId;
    }
    notifyListeners();
  }

  Future<void> selectWorkspace(String id) async {
    if (_activeWorkspaceId != id && _workspaces.any((w) => w.id == id)) {
      _activeWorkspaceId = id;
      await StorageService.setString(_activeKey, id);
      notifyListeners();

      _activityProvider?.logActivity(
        title: 'Switched to Workspace: ${activeWorkspace.name}',
        source: 'Workspace',
        category: 'Workspace',
        actionType: 'Selected',
        iconCodePoint: activeWorkspace.iconCodePoint,
        colorValue: activeWorkspace.colorValue,
        details: 'Active workspace changed to ${activeWorkspace.name}.',
      );
    }
  }

  Future<void> addWorkspace({
    required String name,
    required String description,
    IconData icon = Icons.folder_outlined,
    Color color = const Color(0xFF7955F5),
  }) async {
    final newWs = WorkspaceModel(
      id: 'ws_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      iconCodePoint: icon.codePoint,
      colorValue: color.toARGB32(),
      itemCount: 0,
    );

    _workspaces.add(newWs);
    _activeWorkspaceId = newWs.id;
    await _save();
    notifyListeners();

    _activityProvider?.logActivity(
      title: 'Created Workspace: $name',
      source: 'Workspace',
      category: 'Workspace',
      actionType: 'Created',
      iconCodePoint: icon.codePoint,
      colorValue: color.toARGB32(),
      details: 'New workspace created and set as active context.',
    );
  }

  Future<void> _save() async {
    await StorageService.setString(_storageKey, WorkspaceModel.encodeList(_workspaces));
    await StorageService.setString(_activeKey, _activeWorkspaceId);
  }

  List<WorkspaceModel> _seedDefaultWorkspaces() {
    return [
      const WorkspaceModel(
        id: 'personal',
        name: 'Personal',
        description: 'Personal goals, daily reflection, health, and finances.',
        iconCodePoint: 0xe491, // Icons.person_outline
        colorValue: 0xFF7955F5,
        itemCount: 18,
      ),
      const WorkspaceModel(
        id: 'college',
        name: 'College',
        description: 'Coursework, AI/ML notes, exam prep, and schedules.',
        iconCodePoint: 0xe559, // Icons.school_outlined
        colorValue: 0xFF3B82F6,
        itemCount: 24,
      ),
      const WorkspaceModel(
        id: 'projects',
        name: 'Projects',
        description: 'NEURON Flutter app, BloodSync, and GitHub repositories.',
        iconCodePoint: 0xf028b, // Icons.folder_special_outlined
        colorValue: 0xFF10B981,
        itemCount: 15,
      ),
      const WorkspaceModel(
        id: 'research',
        name: 'Research',
        description: 'RAG papers, vector databases, and multi-agent systems.',
        iconCodePoint: 0xe55e, // Icons.science_outlined
        colorValue: 0xFFF59E0B,
        itemCount: 9,
      ),
    ];
  }
}
