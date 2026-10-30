import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../models/schedule_model.dart';
import '../providers/navigation_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/documents_provider.dart';
import '../providers/connections_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/workspace_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/neuron_card.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();

  final List<String> _quickPrompts = [
    'Find my Flutter notes',
    'Summarize ML assignment',
    'What tasks are due today?',
    'Review state management',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _submitPrompt(String prompt) {
    if (prompt.trim().isEmpty) return;
    final nav = context.read<NavigationProvider>();
    final chat = context.read<ChatProvider>();
    final docs = context.read<DocumentsProvider>().allDocuments;
    final settings = context.read<SettingsProvider>();

    _promptController.clear();
    nav.navigateTo(NavigationProvider.chat);
    chat.sendMessage(
      prompt,
      responseStyle: settings.aiResponseStyle,
      localDocuments: docs,
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final timeController = TextEditingController(text: '03:00 PM');
    ScheduleCategory selectedCategory = ScheduleCategory.work;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Schedule Event', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Event Title', hintText: 'e.g. Flutter Sprint'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subtitleController,
                  decoration: const InputDecoration(labelText: 'Subtitle / Notes', hintText: 'e.g. Discuss navigation refactor'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Time', hintText: 'e.g. 02:30 PM'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ScheduleCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ScheduleCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
                    );
                  }).toList(),
                  onChanged: (cat) {
                    if (cat != null) {
                      setDialogState(() => selectedCategory = cat);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  ctx.read<ScheduleProvider>().addScheduleItem(
                    time: timeController.text.trim(),
                    title: title,
                    subtitle: subtitleController.text.trim(),
                    category: selectedCategory,
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final tasksProv = context.watch<TasksProvider>();
    final docsProv = context.watch<DocumentsProvider>();
    final connProv = context.watch<ConnectionsProvider>();
    final actProv = context.watch<ActivityProvider>();
    final wsProv = context.watch<WorkspaceProvider>();
    final schProv = context.watch<ScheduleProvider>();
    final nav = context.read<NavigationProvider>();

    final now = DateTime.now();
    final hour = now.hour;
    final greetingPrefix = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    final dateFormatted = DateFormat('EEEE, MMMM d, y').format(now);
    final padding = Responsive.screenPadding(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop ? const AppDrawer() : null,
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'NEURON',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
                color: AppTheme.primaryText(context),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: wsProv.activeWorkspace.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: wsProv.activeWorkspace.color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  wsProv.activeWorkspace.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: wsProv.activeWorkspace.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            tooltip: 'Search Knowledge',
            onPressed: () => nav.navigateTo(NavigationProvider.knowledge),
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.25),
              child: Text(
                settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : 'D',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
              ),
            ),
            tooltip: 'Settings',
            onPressed: () => nav.navigateTo(NavigationProvider.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await actProv.refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Responsive Greeting
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greetingPrefix, ${settings.userName}! ☀️',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText(context),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              dateFormatted,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.secondaryText(context),
                              ),
                            ),
                            Text(
                              '• ${tasksProv.pendingCount} tasks pending',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Ask NEURON - Full Width Interactive Assistant Prompt Card
                    NeuronCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Ask NEURON',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryText(context),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardElevated(context),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#${wsProv.activeWorkspace.name}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: wsProv.activeWorkspace.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Text Input Field with Inner Actions
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardElevated(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border(context)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _promptController,
                                    decoration: const InputDecoration(
                                      hintText: 'Ask anything from your second brain...',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onSubmitted: _submitPrompt,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.attach_file, size: 20),
                                  tooltip: 'Attach Note / Document',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => AppDialogs.showDocumentSheet(context),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.mic_none, size: 20),
                                  tooltip: 'Voice Note (Simulated)',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Listening... Dictate your note or query.'),
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                                    tooltip: 'Send to AI',
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _submitPrompt(_promptController.text),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Quick Prompts Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _quickPrompts.map((q) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ActionChip(
                                    label: Text(q, style: const TextStyle(fontSize: 11)),
                                    backgroundColor: AppTheme.cardElevated(context),
                                    side: BorderSide(color: AppTheme.border(context)),
                                    onPressed: () => _submitPrompt(q),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Quick Actions Row (Ask AI, Add Doc, New Task, Reflection)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.chat_bubble_outline,
                                label: 'Ask AI',
                                color: AppColors.primary,
                                onTap: () => nav.navigateTo(NavigationProvider.chat),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.note_add_outlined,
                                label: 'Add Doc',
                                color: AppColors.blue,
                                onTap: () => AppDialogs.showDocumentSheet(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.add_task,
                                label: 'New Task',
                                color: AppColors.success,
                                onTap: () => AppDialogs.showTaskSheet(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.psychology_outlined,
                                label: 'Reflect',
                                color: AppColors.warning,
                                onTap: () => nav.navigateTo(NavigationProvider.reflection),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // AI Insight Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.insightGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                              Text(
                                'AI Second Brain Insight',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "You've been optimizing the Flutter layout responsiveness. Would you like to review the breakpoint guidelines and cognitive patterns?",
                            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: () => nav.navigateTo(NavigationProvider.chat),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Ask NEURON',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                              TextButton(
                                onPressed: () => nav.navigateTo(NavigationProvider.knowledge),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('View Documents', style: TextStyle(fontSize: 12)),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Statistics Section: 2 Columns on Mobile, 4 Columns on Wide Screen
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 700;
                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(
                                child: _StatCardWidget(
                                  title: 'Documents',
                                  value: docsProv.allDocuments.length.toString(),
                                  subtitle: 'Across sources',
                                  icon: Icons.description_outlined,
                                  color: AppColors.primary,
                                  onTap: () => nav.navigateTo(NavigationProvider.knowledge),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCardWidget(
                                  title: 'Active Tasks',
                                  value: tasksProv.pendingCount.toString(),
                                  subtitle: '${tasksProv.completedCount} completed',
                                  icon: Icons.check_circle_outline,
                                  color: AppColors.success,
                                  onTap: () => nav.navigateTo(NavigationProvider.tasks),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCardWidget(
                                  title: 'Connected',
                                  value: connProv.connectedCount.toString(),
                                  subtitle: 'Of 7 services',
                                  icon: Icons.hub_outlined,
                                  color: AppColors.blue,
                                  onTap: () => nav.navigateTo(NavigationProvider.connections),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCardWidget(
                                  title: 'Activities',
                                  value: actProv.allActivities.length.toString(),
                                  subtitle: 'Logged events',
                                  icon: Icons.timeline,
                                  color: AppColors.warning,
                                  onTap: () => nav.navigateTo(NavigationProvider.timeline),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatCardWidget(
                                      title: 'Documents',
                                      value: docsProv.allDocuments.length.toString(),
                                      subtitle: 'Across sources',
                                      icon: Icons.description_outlined,
                                      color: AppColors.primary,
                                      onTap: () => nav.navigateTo(NavigationProvider.knowledge),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatCardWidget(
                                      title: 'Active Tasks',
                                      value: tasksProv.pendingCount.toString(),
                                      subtitle: '${tasksProv.completedCount} completed',
                                      icon: Icons.check_circle_outline,
                                      color: AppColors.success,
                                      onTap: () => nav.navigateTo(NavigationProvider.tasks),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatCardWidget(
                                      title: 'Connected',
                                      value: connProv.connectedCount.toString(),
                                      subtitle: 'Of 7 services',
                                      icon: Icons.hub_outlined,
                                      color: AppColors.blue,
                                      onTap: () => nav.navigateTo(NavigationProvider.connections),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatCardWidget(
                                      title: 'Activities',
                                      value: actProv.allActivities.length.toString(),
                                      subtitle: 'Logged events',
                                      icon: Icons.timeline,
                                      color: AppColors.warning,
                                      onTap: () => nav.navigateTo(NavigationProvider.timeline),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Today's Schedule Card (Driven by ScheduleProvider)
                    NeuronCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_note, size: 18, color: AppColors.blue),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Today\'s Schedule',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryText(context),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    tooltip: 'Add Event',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _showAddEventDialog(context),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${schProv.completedCount}/${schProv.totalCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.secondaryText(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          ...schProv.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: () => schProv.toggleScheduleItem(item.id),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardElevated(context),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.border(context)),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Checkbox(
                                          value: item.isCompleted,
                                          onChanged: (_) => schProv.toggleScheduleItem(item.id),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.categoryColor(true).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.time,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: item.categoryColor(true),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                                color: item.isCompleted
                                                    ? AppTheme.secondaryText(context)
                                                    : AppTheme.primaryText(context),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              item.subtitle,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.secondaryText(context),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daily Task Progress & Due Today Card
                    NeuronCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Daily Task Progress',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryText(context),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () => nav.navigateTo(NavigationProvider.tasks),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryLight,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('View All', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: tasksProv.completionRate,
                                    minHeight: 8,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(tasksProv.completionRate * 100).toInt()}%',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (tasksProv.todayTasks.isEmpty)
                            Text(
                              'No tasks due today. Tap "New Task" above to add one.',
                              style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(context)),
                            )
                          else
                            ...tasksProv.todayTasks.take(3).map((task) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (_) => tasksProv.toggleTask(task.id),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                          color: task.isCompleted
                                              ? AppTheme.secondaryText(context)
                                              : AppTheme.primaryText(context),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recent Activity Card
                    NeuronCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Recent Activity',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryText(context),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () => nav.navigateTo(NavigationProvider.timeline),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryLight,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('View All', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...actProv.allActivities.take(3).map((act) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(act.icon, color: act.color, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(act.title, style: const TextStyle(fontSize: 16))),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Source: ${act.source}', style: const TextStyle(fontSize: 13)),
                                          const SizedBox(height: 4),
                                          Text('Category: ${act.category}', style: const TextStyle(fontSize: 13)),
                                          const SizedBox(height: 4),
                                          Text('Action: ${act.actionType}', style: const TextStyle(fontSize: 13)),
                                          const SizedBox(height: 4),
                                          Text('Time: ${act.timeAgo}', style: const TextStyle(fontSize: 13)),
                                          if (act.details.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Text(act.details, style: const TextStyle(fontSize: 13)),
                                          ],
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: act.color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(act.icon, size: 16, color: act.color),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            act.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.primaryText(context),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${act.source} • ${act.timeAgo}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.secondaryText(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: act.color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        act.actionType,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: act.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Active Integrations
                    NeuronCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Active Integrations',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryText(context),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () => nav.navigateTo(NavigationProvider.connections),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryLight,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('Manage', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: connProv.connections.map((c) {
                              final isConn = c.isConnected;
                              return InkWell(
                                onTap: () => nav.navigateTo(NavigationProvider.connections),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isConn ? c.color.withValues(alpha: 0.15) : AppTheme.cardElevated(context),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isConn ? c.color.withValues(alpha: 0.4) : AppTheme.border(context),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        c.icon,
                                        size: 14,
                                        color: isConn ? c.color : AppTheme.secondaryText(context),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        c.name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isConn ? AppTheme.primaryText(context) : AppTheme.secondaryText(context),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isConn ? AppColors.success : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCardWidget({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeuronCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const Icon(Icons.arrow_forward_ios, size: 9, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: AppTheme.secondaryText(context)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
