import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../widgets/neuron_card.dart';
import '../widgets/empty_state.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  final List<String> _filters = const [
    'All',
    'Document',
    'Task',
    'Connection',
    'Settings',
    'Chat',
    'Reflection',
  ];

  @override
  Widget build(BuildContext context) {
    final actProv = context.watch<ActivityProvider>();
    final activities = actProv.filteredActivities;
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
          'Activity Timeline',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'Refresh Timeline',
            onPressed: () => actProv.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = actProv.selectedFilter.toLowerCase() == filter.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => actProv.setFilter(filter),
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

          // Feed List
          Expanded(
            child: activities.isEmpty
                ? EmptyState(
                    icon: Icons.history,
                    title: 'No Activities Found',
                    description: 'No events match the selected category filter.',
                    actionLabel: 'Show All Activities',
                    onAction: () => actProv.setFilter('All'),
                  )
                : RefreshIndicator(
                    onRefresh: () => actProv.refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final act = activities[index];
                        return _buildTimelineItem(context, act);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, ActivityModel act) {
    final timeFormatted = DateFormat('MMM d, hh:mm a').format(act.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeuronCard(
        padding: const EdgeInsets.all(14),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: act.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(act.icon, size: 18, color: act.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      act.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
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
                  Text('Time: $timeFormatted (${act.timeAgo})', style: const TextStyle(fontSize: 13)),
                  if (act.details.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Details:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(act.details, style: const TextStyle(fontSize: 13, height: 1.4)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: act.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(act.icon, size: 20, color: act.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          act.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: act.color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${act.source} • ${act.category}',
                    style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(context)),
                  ),
                  if (act.details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      act.details,
                      style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    act.timeAgo,
                    style: TextStyle(fontSize: 10, color: AppTheme.secondaryText(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
