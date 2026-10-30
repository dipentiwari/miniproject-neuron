import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/storage_service.dart';
import 'activity_provider.dart';

class ScheduleProvider extends ChangeNotifier {
  static const String _storageKey = 'neuron_schedule_today';

  List<ScheduleModel> _items = [];
  ActivityProvider? _activityProvider;

  ScheduleProvider() {
    _items = _seedDefaultSchedule();
    _init();
  }

  List<ScheduleModel> get items => List.unmodifiable(_items);

  int get completedCount => _items.where((i) => i.isCompleted).length;
  int get totalCount => _items.length;

  void updateActivityProvider(ActivityProvider activity) {
    _activityProvider = activity;
  }

  Future<void> _init() async {
    final savedJson = await StorageService.getString(_storageKey);
    if (savedJson != null && savedJson.isNotEmpty) {
      final decoded = ScheduleModel.decodeList(savedJson);
      if (decoded.isNotEmpty) {
        _items = decoded;
        notifyListeners();
      }
    }
  }

  Future<void> toggleScheduleItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isCompleted = !_items[index].isCompleted;
      await StorageService.setString(_storageKey, ScheduleModel.encodeList(_items));
      notifyListeners();

      _activityProvider?.logActivity(
        title: _items[index].isCompleted
            ? 'Completed Event: ${_items[index].title}'
            : 'Reopened Event: ${_items[index].title}',
        source: 'Schedule',
        category: 'Schedule',
        actionType: _items[index].isCompleted ? 'Completed' : 'Updated',
        iconCodePoint: Icons.event_available.codePoint,
        colorValue: 0xFF3B82F6,
        details: 'Event status updated for ${_items[index].time}.',
      );
    }
  }

  Future<void> addScheduleItem({
    required String time,
    required String title,
    required String subtitle,
    required ScheduleCategory category,
  }) async {
    final newItem = ScheduleModel(
      id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
      time: time,
      title: title,
      subtitle: subtitle,
      category: category,
      isCompleted: false,
    );

    _items.add(newItem);
    await StorageService.setString(_storageKey, ScheduleModel.encodeList(_items));
    notifyListeners();

    _activityProvider?.logActivity(
      title: 'Added Event: $title',
      source: 'Schedule',
      category: 'Schedule',
      actionType: 'Created',
      iconCodePoint: Icons.event.codePoint,
      colorValue: 0xFF3B82F6,
      details: 'Scheduled at $time.',
    );
  }

  List<ScheduleModel> _seedDefaultSchedule() {
    return [
      ScheduleModel(
        id: 'sch_1',
        time: '09:00 AM',
        title: 'Team Standup & Sprint Sync',
        subtitle: 'Review Flutter mobile UI & RAG integration milestones',
        category: ScheduleCategory.meeting,
        isCompleted: true,
      ),
      ScheduleModel(
        id: 'sch_2',
        time: '11:30 AM',
        title: 'AI & Machine Learning Study Block',
        subtitle: 'Vector embeddings, semantic search, and cosine distance',
        category: ScheduleCategory.study,
        isCompleted: false,
      ),
      ScheduleModel(
        id: 'sch_3',
        time: '02:00 PM',
        title: 'Neuron Dashboard Code Review',
        subtitle: 'Audit responsive constraints, safe insets, and zero inert buttons',
        category: ScheduleCategory.work,
        isCompleted: false,
      ),
      ScheduleModel(
        id: 'sch_4',
        time: '05:30 PM',
        title: 'Gym & Cardio Workout',
        subtitle: '45-minute aerobic workout and physical recovery',
        category: ScheduleCategory.personal,
        isCompleted: false,
      ),
    ];
  }
}

