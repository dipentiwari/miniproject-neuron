import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/responsive.dart';
import '../providers/navigation_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_sidebar.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'knowledge_screen.dart';
import 'tasks_screen.dart';
import 'settings_screen.dart';
import 'connections_screen.dart';
import 'timeline_screen.dart';
import 'reflection_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    ChatScreen(),
    KnowledgeScreen(),
    TasksScreen(),
    SettingsScreen(),
    ConnectionsScreen(),
    TimelineScreen(),
    ReflectionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final tasksProv = context.watch<TasksProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final currentScreen = _screens[nav.currentIndex.clamp(0, _screens.length - 1)];

    return PopScope(
      canPop: nav.currentIndex == NavigationProvider.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && nav.currentIndex != NavigationProvider.home) {
          nav.navigateTo(NavigationProvider.home);
        }
      },
      child: Scaffold(
        // Drawer is available on mobile and tablet
        drawer: !isDesktop ? const AppDrawer() : null,
        body: isDesktop
            ? Row(
                children: [
                  const AppSidebar(width: 250),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
                        child: currentScreen,
                      ),
                    ),
                  ),
                ],
              )
            : currentScreen,
        bottomNavigationBar: !isDesktop
            ? NavigationBar(
                selectedIndex: nav.currentIndex > 4 ? 0 : nav.currentIndex,
                onDestinationSelected: (index) => nav.navigateTo(index),
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline),
                    selectedIcon: Icon(Icons.chat_bubble),
                    label: 'Chat',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder),
                    label: 'Knowledge',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      label: Text(tasksProv.pendingCount.toString()),
                      isLabelVisible: tasksProv.pendingCount > 0,
                      child: const Icon(Icons.check_circle_outline),
                    ),
                    selectedIcon: Badge(
                      label: Text(tasksProv.pendingCount.toString()),
                      isLabelVisible: tasksProv.pendingCount > 0,
                      child: const Icon(Icons.check_circle),
                    ),
                    label: 'Tasks',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
