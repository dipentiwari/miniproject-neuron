import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/storage_service.dart';

class ActivityProvider extends ChangeNotifier {
  List<ActivityModel> _activities = [];
  String _selectedFilter = 'All';

  ActivityProvider() {
    _activities = _seedDefaultActivities();
    _init();
  }

  List<ActivityModel> get allActivities => List.unmodifiable(_activities);
  String get selectedFilter => _selectedFilter;

  List<ActivityModel> get filteredActivities {
    if (_selectedFilter == 'All') return _activities;
    return _activities.where((a) => a.category.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  Future<void> _init() async {
    final stored = await StorageService.loadActivities();
    if (stored != null && stored.isNotEmpty) {
      _activities = stored;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  Future<void> logActivity({
    required String title,
    required String source,
    required String category,
    required String actionType,
    int? iconCodePoint,
    int? colorValue,
    String details = '',
  }) async {
    final activity = ActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      source: source,
      category: category,
      actionType: actionType,
      timestamp: DateTime.now(),
      iconCodePoint: iconCodePoint ?? Icons.history.codePoint,
      colorValue: colorValue ?? 0xFF7955F5,
      details: details,
    );
    _activities.insert(0, activity);
    notifyListeners();
    await StorageService.saveActivities(_activities);
  }

  Future<void> refresh() async {
    // Reload from storage
    final stored = await StorageService.loadActivities();
    if (stored != null) {
      _activities = stored;
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    _activities.clear();
    notifyListeners();
    await StorageService.saveActivities(_activities);
  }

  List<ActivityModel> _seedDefaultActivities() {
    final now = DateTime.now();
    return [
      ActivityModel(
        id: 'act_1',
        title: 'Machine Learning Notes.pdf',
        source: 'Google Drive',
        category: 'Document',
        actionType: 'Viewed',
        timestamp: now.subtract(const Duration(hours: 2)),
        iconCodePoint: Icons.picture_as_pdf.codePoint,
        colorValue: 0xFFEF4444,
        details: 'Indexed 48 pages of deep learning fundamentals and transformer architectures.',
      ),
      ActivityModel(
        id: 'act_2',
        title: 'auth_service.dart',
        source: 'GitHub',
        category: 'Document',
        actionType: 'Edited',
        timestamp: now.subtract(const Duration(hours: 4)),
        iconCodePoint: Icons.code.codePoint,
        colorValue: 0xFF3B82F6,
        details: 'Updated JWT token validation and secure refresh rotation methods.',
      ),
      ActivityModel(
        id: 'act_3',
        title: 'Complete Flutter UI',
        source: 'Tasks',
        category: 'Task',
        actionType: 'Updated',
        timestamp: now.subtract(const Duration(hours: 6)),
        iconCodePoint: Icons.task_alt.codePoint,
        colorValue: 0xFF22C55E,
        details: 'Task set to high priority with due date today.',
      ),
      ActivityModel(
        id: 'act_4',
        title: 'Project Planning Notes',
        source: 'Notion',
        category: 'Document',
        actionType: 'Synced',
        timestamp: now.subtract(const Duration(days: 1)),
        iconCodePoint: Icons.note_outlined.codePoint,
        colorValue: 0xFF22C55E,
        details: 'Synchronized 12 pages from personal workspace.',
      ),
      ActivityModel(
        id: 'act_5',
        title: 'Google Calendar Connection',
        source: 'Google Calendar',
        category: 'Connection',
        actionType: 'Synced',
        timestamp: now.subtract(const Duration(days: 2)),
        iconCodePoint: Icons.calendar_today.codePoint,
        colorValue: 0xFFF59E0B,
        details: 'Retrieved 8 upcoming calendar events for the week.',
      ),
    ];
  }
}
