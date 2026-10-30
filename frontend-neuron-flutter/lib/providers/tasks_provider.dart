import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';
import 'activity_provider.dart';

class TasksProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  String _selectedFilter = 'All'; // 'All', 'Active', 'Done', 'High'
  String _searchQuery = '';
  ActivityProvider? _activityProvider;

  TasksProvider() {
    _tasks = _seedDefaultTasks();
    _init();
  }

  void updateActivityProvider(ActivityProvider provider) {
    _activityProvider = provider;
  }

  List<TaskModel> get allTasks => List.unmodifiable(_tasks);
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => totalCount - completedCount;
  double get completionRate => totalCount == 0 ? 0.0 : completedCount / totalCount;

  List<TaskModel> get todayTasks =>
      _tasks.where((t) => t.section == TaskSection.today).toList();

  List<TaskModel> get filteredTasks {
    var result = _tasks;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q))
          .toList();
    }
    switch (_selectedFilter) {
      case 'Active':
        return result.where((t) => !t.isCompleted).toList();
      case 'Done':
        return result.where((t) => t.isCompleted).toList();
      case 'High':
        return result.where((t) => t.priority == TaskPriority.high).toList();
      case 'All':
      default:
        return result;
    }
  }

  Future<void> _init() async {
    final stored = await StorageService.loadTasks();
    if (stored != null && stored.isNotEmpty) {
      _tasks = stored;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    task.isCompleted = !task.isCompleted;

    if (task.isCompleted) {
      task.section = TaskSection.completed;
      _activityProvider?.logActivity(
        title: 'Completed "${task.title}"',
        source: 'Tasks',
        category: 'Task',
        actionType: 'Completed',
        iconCodePoint: Icons.check_circle_outline.codePoint,
        colorValue: 0xFF22C55E,
      );
    } else {
      task.section = TaskSection.today;
      _activityProvider?.logActivity(
        title: 'Reopened "${task.title}"',
        source: 'Tasks',
        category: 'Task',
        actionType: 'Updated',
        iconCodePoint: Icons.radio_button_unchecked.codePoint,
        colorValue: 0xFFF59E0B,
      );
    }

    notifyListeners();
    await StorageService.saveTasks(_tasks);
  }

  Future<void> addTask({
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    TaskSection section = TaskSection.today,
    DateTime? dueDate,
  }) async {
    final task = TaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      section: section,
      dueDate: dueDate,
      isCompleted: false,
    );

    _tasks.insert(0, task);
    notifyListeners();
    await StorageService.saveTasks(_tasks);

    _activityProvider?.logActivity(
      title: 'Created task "${task.title}"',
      source: 'Tasks',
      category: 'Task',
      actionType: 'Created',
      iconCodePoint: Icons.add_task.codePoint,
      colorValue: 0xFF7955F5,
    );
  }

  Future<void> updateTask({
    required String id,
    required String title,
    String description = '',
    required TaskPriority priority,
    required TaskSection section,
    DateTime? dueDate,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    task.title = title.trim();
    task.description = description.trim();
    task.priority = priority;
    task.section = section;
    task.dueDate = dueDate;

    notifyListeners();
    await StorageService.saveTasks(_tasks);

    _activityProvider?.logActivity(
      title: 'Updated task "${task.title}"',
      source: 'Tasks',
      category: 'Task',
      actionType: 'Modified',
      iconCodePoint: Icons.edit_outlined.codePoint,
      colorValue: 0xFF3B82F6,
    );
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks.removeAt(index);
    notifyListeners();
    await StorageService.saveTasks(_tasks);

    _activityProvider?.logActivity(
      title: 'Deleted task "${task.title}"',
      source: 'Tasks',
      category: 'Task',
      actionType: 'Modified',
      iconCodePoint: Icons.delete_outline.codePoint,
      colorValue: 0xFFEF4444,
    );
  }

  List<TaskModel> _seedDefaultTasks() {
    final now = DateTime.now();
    return [
      TaskModel(
        id: 'task_1',
        title: 'Complete Flutter UI & Navigation',
        description: 'Wire all buttons, screens, and dialogs for zero inert controls.',
        section: TaskSection.today,
        priority: TaskPriority.high,
        dueDate: now,
      ),
      TaskModel(
        id: 'task_2',
        title: 'Submit AI/ML assignment',
        description: 'Prepare documentation on neural network architecture.',
        section: TaskSection.today,
        priority: TaskPriority.high,
        dueDate: now,
      ),
      TaskModel(
        id: 'task_3',
        title: 'Review BloodSync API endpoints',
        description: 'Verify JWT refresh token rotation and error responses.',
        section: TaskSection.upcoming,
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 2)),
      ),
      TaskModel(
        id: 'task_4',
        title: 'Read ML research paper on RAG',
        description: 'Study retrieval augmented generation with LangChain.',
        section: TaskSection.upcoming,
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 4)),
      ),
      TaskModel(
        id: 'task_5',
        title: 'Update project README & docs',
        description: 'Document instructions and architecture overview.',
        section: TaskSection.completed,
        priority: TaskPriority.medium,
        isCompleted: true,
      ),
    ];
  }
}
