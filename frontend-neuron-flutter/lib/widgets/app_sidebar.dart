import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../providers/navigation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/documents_provider.dart';
import '../providers/connections_provider.dart';
import '../providers/workspace_provider.dart';

class AppSidebar extends StatelessWidget {
  final double width;

  const AppSidebar({
    super.key,
    this.width = 250,
  });

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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock full second-brain capabilities:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            SizedBox(height: 10),
            _ProFeature(Icons.auto_awesome, 'Unlimited AI LangChain & RAG queries'),
            _ProFeature(Icons.sync, 'Real-time 2-way cloud synchronization'),
            _ProFeature(Icons.all_inclusive, 'Infinite workspaces & document attachments'),
            _ProFeature(Icons.insights, 'Advanced cognitive reflection pattern analytics'),
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

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final settings = context.watch<SettingsProvider>();
    final tasksProv = context.watch<TasksProvider>();
    final docsProv = context.watch<DocumentsProvider>();
    final connProv = context.watch<ConnectionsProvider>();
    final wsProv = context.watch<WorkspaceProvider>();

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.navSurface(context),
        border: Border(right: BorderSide(color: AppTheme.border(context))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Logo Branding
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEURON',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppTheme.primaryText(context),
                          ),
                        ),
                        Text(
                          'Your Second Brain',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Navigation Destinations
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _NavButton(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    badge: null,
                    isSelected: nav.currentIndex == NavigationProvider.home,
                    onTap: () => nav.navigateTo(NavigationProvider.home),
                  ),
                  _NavButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'AI Chat',
                    badge: 'Live',
                    isSelected: nav.currentIndex == NavigationProvider.chat,
                    onTap: () => nav.navigateTo(NavigationProvider.chat),
                  ),
                  _NavButton(
                    icon: Icons.folder_outlined,
                    label: 'Knowledge',
                    badge: docsProv.allDocuments.length.toString(),
                    isSelected: nav.currentIndex == NavigationProvider.knowledge,
                    onTap: () => nav.navigateTo(NavigationProvider.knowledge),
                  ),
                  _NavButton(
                    icon: Icons.task_alt_outlined,
                    label: 'Tasks',
                    badge: tasksProv.pendingCount.toString(),
                    isSelected: nav.currentIndex == NavigationProvider.tasks,
                    onTap: () => nav.navigateTo(NavigationProvider.tasks),
                  ),
                  _NavButton(
                    icon: Icons.hub_outlined,
                    label: 'Connections',
                    badge: '${connProv.connectedCount}/7',
                    isSelected: nav.currentIndex == NavigationProvider.connections,
                    onTap: () => nav.navigateTo(NavigationProvider.connections),
                  ),
                  _NavButton(
                    icon: Icons.timeline,
                    label: 'Timeline',
                    badge: null,
                    isSelected: nav.currentIndex == NavigationProvider.timeline,
                    onTap: () => nav.navigateTo(NavigationProvider.timeline),
                  ),
                  _NavButton(
                    icon: Icons.psychology_outlined,
                    label: 'Reflection',
                    badge: 'Daily',
                    isSelected: nav.currentIndex == NavigationProvider.reflection,
                    onTap: () => nav.navigateTo(NavigationProvider.reflection),
                  ),
                  _NavButton(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    badge: null,
                    isSelected: nav.currentIndex == NavigationProvider.settings,
                    onTap: () => nav.navigateTo(NavigationProvider.settings),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),

                  // Workspaces Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WORKSPACES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppTheme.secondaryText(context),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showAddWorkspaceDialog(context),
                        ),
                      ],
                    ),
                  ),

                  ...wsProv.workspaces.map((ws) {
                    final isActive = ws.id == wsProv.activeWorkspaceId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: InkWell(
                        onTap: () => wsProv.selectWorkspace(ws.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: isActive ? ws.color.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                ws.icon,
                                size: 16,
                                color: isActive ? ws.color : AppTheme.secondaryText(context),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ws.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                    color: isActive ? ws.color : AppTheme.primaryText(context),
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ws.color,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Pro Upgrade Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upgrade to Pro',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Unlimited RAG & sync',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showUpgradeDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('Upgrade', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

            // User Info Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.border(context))),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                    child: Text(
                      settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : 'D',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.userFullName,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryText(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Pro Member',
                          style: TextStyle(fontSize: 9, color: AppTheme.secondaryText(context)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 16),
                    tooltip: 'Settings',
                    onPressed: () => nav.navigateTo(NavigationProvider.settings),
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppColors.primaryLight : AppTheme.secondaryText(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryLight : AppTheme.primaryText(context),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppTheme.cardElevated(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primaryLight : AppTheme.secondaryText(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProFeature(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }
}
