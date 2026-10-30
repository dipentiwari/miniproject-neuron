import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../providers/navigation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/documents_provider.dart';
import '../providers/connections_provider.dart';
import '../providers/workspace_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showAddWorkspaceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.create_new_folder_outlined, color: AppColors.primaryLight, size: 22),
            SizedBox(width: 8),
            Text('New Workspace', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Workspace Name',
                hintText: 'e.g., Client Work, Thesis, Startup',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Purpose of this second-brain workspace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                ctx.read<WorkspaceProvider>().addWorkspace(
                  name: name,
                  description: descController.text.trim(),
                  icon: Icons.folder_special_outlined,
                  color: AppColors.primary,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Workspace "$name" created successfully.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text('NEURON Pro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unlock full second-brain capabilities:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 10),
            _proFeatureItem(Icons.auto_awesome, 'Unlimited AI LangChain & RAG queries'),
            _proFeatureItem(Icons.sync, 'Real-time 2-way cloud synchronization'),
            _proFeatureItem(Icons.all_inclusive, 'Infinite workspaces & document attachments'),
            _proFeatureItem(Icons.insights, 'Advanced cognitive reflection pattern analytics'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primaryLight, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Free 14-day trial included. No credit card required in Demo.',
                      style: TextStyle(fontSize: 11, color: AppColors.primaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upgraded to NEURON Pro! All features unlocked.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Free Trial'),
          ),
        ],
      ),
    );
  }

  static Widget _proFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final settings = context.watch<SettingsProvider>();
    final tasksProv = context.watch<TasksProvider>();
    final docsProv = context.watch<DocumentsProvider>();
    final connProv = context.watch<ConnectionsProvider>();
    final wsProv = context.watch<WorkspaceProvider>();

    return Drawer(
      backgroundColor: AppTheme.navSurface(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header with User Profile & Logo
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : 'N',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.userFullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          settings.userEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _showUpgradeDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium, color: Colors.amber, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'NEURON PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content: Navigation Items + Workspaces + Pro Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Section: Destinations
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    badge: null,
                    isSelected: nav.currentIndex == NavigationProvider.home,
                    onTap: () {
                      nav.navigateTo(NavigationProvider.home);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'AI Chat',
                    badge: 'Live/Demo',
                    isSelected: nav.currentIndex == NavigationProvider.chat,
                    onTap: () {
                      nav.navigateTo(NavigationProvider.chat);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.folder_outlined,
                    label: 'Knowledge Base',
                    badge: docsProv.allDocuments.length.toString(),
                    isSelected: nav.currentIndex == NavigationProvider.knowledge,
                    onTap: () {
                      nav.navigateTo(NavigationProvider.knowledge);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.task_alt_outlined,
                    label: 'Tasks',
                    badge: tasksProv.pendingCount.toString(),
                    isSelected: nav.currentIndex == NavigationProvider.tasks,
                    onTap: () {
                      nav.navigateTo(NavigationProvider.tasks);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.hub_outlined,
                    label: 'Connections',
                    badge: '${connProv.connectedCount}/7',
                    isSelected: nav.currentIndex == NavigationProvider.connections,
                    onTap: () {
                      nav.navigateTo(NavigationProvider.connections);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.timeline,
                    label: 'Activity Timeline',
                    badge: null,
                    isSelected: nav.currentIndex == NavigationProvider.timeline,
                    onTap: () {
                      nav.navigateTo(NavigationProvider.timeline);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.psychology_outlined,
                    label: 'Reflection',
                    badge: 'Daily',
                    isSelected: nav.currentIndex == NavigationProvider.reflection,
                    onTap: () {
                      nav.navigateTo(NavigationProvider.reflection);
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    badge: null,
                    isSelected: nav.currentIndex == NavigationProvider.settings,
                    onTap: () {
                      nav.navigateTo(NavigationProvider.settings);
                      Navigator.pop(context);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1),
                  ),

                  // Section: Workspaces Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WORKSPACES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppTheme.secondaryText(context),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          tooltip: 'Add Workspace',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showAddWorkspaceDialog(context),
                        ),
                      ],
                    ),
                  ),

                  // Workspaces Items
                  ...wsProv.workspaces.map((ws) {
                    final isActive = ws.id == wsProv.activeWorkspaceId;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        ws.icon,
                        size: 20,
                        color: isActive ? ws.color : AppTheme.secondaryText(context),
                      ),
                      title: Text(
                        ws.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? ws.color : AppTheme.primaryText(context),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ws.itemCount > 0)
                            Text(
                              '${ws.itemCount}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.secondaryText(context),
                              ),
                            ),
                          const SizedBox(width: 6),
                          if (isActive)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ws.color,
                              ),
                            ),
                        ],
                      ),
                      selected: isActive,
                      selectedTileColor: ws.color.withValues(alpha: 0.12),
                      onTap: () {
                        wsProv.selectWorkspace(ws.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Active Workspace: ${ws.name}'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 12),

                  // Pro Upgrade Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Upgrade to Pro',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Unlock unlimited AI queries, cloud sync & infinite storage.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showUpgradeDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text(
                                'Upgrade Now',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

            // Bottom User Profile Info & Version
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.border(context))),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                    child: Text(
                      settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : 'D',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.userFullName,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryText(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${AppConstants.appName} v${AppConstants.appVersion}',
                          style: TextStyle(fontSize: 10, color: AppTheme.secondaryText(context)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 18),
                    tooltip: 'Settings',
                    onPressed: () {
                      nav.navigateTo(NavigationProvider.settings);
                      Navigator.pop(context);
                    },
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryLight : AppTheme.secondaryText(context),
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primaryLight : AppTheme.primaryText(context),
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppTheme.cardElevated(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryLight : AppTheme.secondaryText(context),
                ),
              ),
            )
          : null,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.12),
      onTap: onTap,
    );
  }
}
