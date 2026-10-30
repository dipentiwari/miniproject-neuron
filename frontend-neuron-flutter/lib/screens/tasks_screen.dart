import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../models/task_model.dart';
import '../providers/tasks_provider.dart';
import '../widgets/neuron_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_dialogs.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Active', 'Done', 'High'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksProv = context.watch<TasksProvider>();
    final tasks = tasksProv.filteredTasks;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        leading: !isDesktop
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, size: 24),
                  tooltip: 'Open Menu',
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        title: const Text(
          'Tasks & Deadlines',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            tooltip: 'Add Task',
            onPressed: () => AppDialogs.showTaskSheet(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: Column(
            children: [
          // Completion Progress Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: NeuronCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress Overview',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryText(context),
                        ),
                      ),
                      Text(
                        '${tasksProv.completedCount} of ${tasksProv.totalCount} completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: tasksProv.completionRate,
                      minHeight: 8,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => tasksProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          tasksProv.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = tasksProv.selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => tasksProv.setFilter(filter),
                    backgroundColor: AppTheme.card(context),
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryLight : AppTheme.secondaryText(context),
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppTheme.border(context),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Tasks List
          Expanded(
            child: tasks.isEmpty
                ? EmptyState(
                    icon: Icons.checklist,
                    title: 'No Tasks Found',
                    description: _searchController.text.isNotEmpty
                        ? 'No tasks match "${_searchController.text}".'
                        : 'No tasks currently match this filter. Stay productive by creating a task.',
                    actionLabel: 'Create Task',
                    onAction: () => AppDialogs.showTaskSheet(context),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ...tasks.map((task) => _buildTaskItem(context, task, tasksProv)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    ),
  ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppDialogs.showTaskSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task, TasksProvider provider) {
    Color priorityColor;
    String priorityLabel;

    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = AppColors.error;
        priorityLabel = 'High';
        break;
      case TaskPriority.medium:
        priorityColor = AppColors.warning;
        priorityLabel = 'Med';
        break;
      case TaskPriority.low:
        priorityColor = AppColors.success;
        priorityLabel = 'Low';
        break;
    }

    String? dueStr;
    if (task.dueDate != null) {
      dueStr = DateFormat('MMM d').format(task.dueDate!);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeuronCard(
        padding: const EdgeInsets.all(14),
        onTap: () => AppDialogs.showTaskSheet(context, existingTask: task),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (_) => provider.toggleTask(task.id),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted
                          ? AppTheme.secondaryText(context)
                          : AppTheme.primaryText(context),
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          priorityLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.cardElevated(context),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.border(context)),
                        ),
                        child: Text(
                          task.section == TaskSection.today ? 'Due Today' : 'Upcoming',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.secondaryText(context),
                          ),
                        ),
                      ),
                      if (dueStr != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_today, size: 10, color: AppTheme.secondaryText(context)),
                        const SizedBox(width: 4),
                        Text(
                          dueStr,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.secondaryText(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              tooltip: 'Delete Task',
              onPressed: () {
                AppDialogs.showConfirmDialog(
                  context,
                  title: 'Delete Task?',
                  message: 'Are you sure you want to remove "${task.title}"?',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                  onConfirm: () => provider.deleteTask(task.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
