import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_project/main.dart';
import 'package:mini_project/models/task_model.dart';
import 'package:mini_project/models/schedule_model.dart';
import 'package:mini_project/providers/tasks_provider.dart';
import 'package:mini_project/providers/documents_provider.dart';
import 'package:mini_project/providers/connections_provider.dart';
import 'package:mini_project/providers/settings_provider.dart';
import 'package:mini_project/providers/activity_provider.dart';
import 'package:mini_project/providers/workspace_provider.dart';
import 'package:mini_project/providers/reflection_provider.dart';
import 'package:mini_project/providers/schedule_provider.dart';
import 'package:mini_project/widgets/app_drawer.dart';
import 'package:mini_project/widgets/app_sidebar.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Neuron App Widget Smoke Tests', () {
    testWidgets('Renders MainNavigationScreen with bottom bar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const NeuronApp());
      await tester.pumpAndSettle();

      // Check Bottom Navigation Destinations exist
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Knowledge'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Check Quick Action buttons on Home
      expect(find.text('Ask AI'), findsOneWidget);
      expect(find.text('Add Doc'), findsOneWidget);
      expect(find.text('New Task'), findsOneWidget);
    });

    testWidgets('Bottom navigation switches destinations', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const NeuronApp());
      await tester.pumpAndSettle();

      // Tap Chat navigation destination via bottom bar
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.chat_bubble_outline),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Ask NEURON anything...'), findsOneWidget);

      // Tap Knowledge navigation destination via bottom bar
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.folder_outlined),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Knowledge Base'), findsOneWidget);

      // Tap Tasks navigation destination via bottom bar
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.check_circle_outline),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Tasks & Deadlines'), findsOneWidget);

      // Tap Settings navigation destination via bottom bar
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.settings_outlined),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Settings & Preferences'), findsOneWidget);
    });

    testWidgets('Mobile viewport hides sidebar and opens drawer with destinations and workspaces', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844); // Standard mobile phone viewport
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const NeuronApp());
      await tester.pumpAndSettle();

      // Verify persistent sidebar is NOT rendered on mobile
      expect(find.byType(AppSidebar), findsNothing);

      // Verify hamburger menu icon button is present in app bar
      final menuBtn = find.byTooltip('Open Menu');
      expect(menuBtn, findsOneWidget);

      // Tap hamburger menu to open drawer
      await tester.tap(menuBtn);
      await tester.pumpAndSettle();

      // Drawer should now be visible with navigation destinations
      expect(find.byType(AppDrawer), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('AI Chat'), findsOneWidget);
      expect(find.text('Knowledge Base'), findsOneWidget);
      expect(find.text('Tasks'), findsWidgets);
      expect(find.text('Connections'), findsOneWidget);
      expect(find.text('Activity Timeline'), findsOneWidget);
      expect(find.text('Reflection'), findsOneWidget);
      expect(find.text('Settings'), findsWidgets);

      // Verify Workspaces section exists inside drawer
      expect(find.text('WORKSPACES'), findsOneWidget);
      expect(find.descendant(of: find.byType(AppDrawer), matching: find.text('Personal')), findsOneWidget);
      expect(find.text('College'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Research'), findsOneWidget);

      // Tap Reflection destination in drawer
      await tester.tap(find.text('Reflection'));
      await tester.pumpAndSettle();

      // Verify navigated to Reflection screen
      expect(find.text('Daily Reflection & Synthesis'), findsOneWidget);
    });

    testWidgets('Desktop viewport renders persistent sidebar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800); // Desktop viewport
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const NeuronApp());
      await tester.pumpAndSettle();

      // Verify persistent sidebar IS rendered on desktop
      expect(find.byType(AppSidebar), findsOneWidget);
      // Verify bottom navigation bar is NOT rendered on desktop
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('TasksProvider Business Logic Tests', () {
    test('Can create, toggle, filter, and delete tasks', () async {
      final activity = ActivityProvider();
      final tasks = TasksProvider()..updateActivityProvider(activity);

      final initialCount = tasks.totalCount;

      // Add task
      await tasks.addTask(
        title: 'Unit Test Task',
        description: 'Test description',
        priority: TaskPriority.high,
      );

      expect(tasks.totalCount, initialCount + 1);
      final newTask = tasks.allTasks.first;
      expect(newTask.title, 'Unit Test Task');
      expect(newTask.isCompleted, false);

      // Toggle task completion
      await tasks.toggleTask(newTask.id);
      expect(newTask.isCompleted, true);
      expect(tasks.completedCount, greaterThan(0));

      // Filter tasks
      tasks.setFilter('Done');
      expect(tasks.filteredTasks.any((t) => t.id == newTask.id), true);

      tasks.setFilter('Active');
      expect(tasks.filteredTasks.any((t) => t.id == newTask.id), false);

      // Search tasks
      tasks.setFilter('All');
      tasks.setSearchQuery('Unit Test');
      expect(tasks.filteredTasks.length, 1);

      tasks.setSearchQuery('NonExistentQuery');
      expect(tasks.filteredTasks.isEmpty, true);

      // Delete task
      tasks.setSearchQuery('');
      await tasks.deleteTask(newTask.id);
      expect(tasks.totalCount, initialCount);
    });
  });

  group('DocumentsProvider Business Logic Tests', () {
    test('Can add, pin, search, and delete documents', () async {
      final activity = ActivityProvider();
      final docs = DocumentsProvider()..updateActivityProvider(activity);

      final initialCount = docs.allDocuments.length;

      // Add document
      await docs.addDocument(
        title: 'Flutter RAG Guide',
        content: 'Building agentic RAG with Flutter and FastAPI.',
        type: 'Note',
        source: 'Local',
        tags: ['AI', 'Agent'],
      );

      expect(docs.allDocuments.length, initialCount + 1);
      final newDoc = docs.allDocuments.first;
      expect(newDoc.title, 'Flutter RAG Guide');

      // Pin document
      await docs.togglePin(newDoc.id);
      expect(newDoc.isPinned, true);

      // Search
      docs.setSearchQuery('agentic');
      expect(docs.filteredDocuments.length, 1);

      docs.setSearchQuery('');
      await docs.deleteDocument(newDoc.id);
      expect(docs.allDocuments.length, initialCount);
    });
  });

  group('ConnectionsProvider Tests', () {
    test('Supports Connect Demo and Disconnect flows for all 7 services', () async {
      final activity = ActivityProvider();
      final conn = ConnectionsProvider()..updateActivityProvider(activity);

      expect(conn.connections.length, 7);

      // Connect demo mode for Slack
      await conn.connectDemo('slack');
      final slack = conn.connections.firstWhere((c) => c.id == 'slack');
      expect(slack.isConnected, true);
      expect(slack.isDemo, true);

      // Disconnect
      await conn.disconnect('slack');
      expect(slack.isConnected, false);
    });
  });

  group('SettingsProvider Tests', () {
    test('Saves preferences and exports structured JSON data', () async {
      final settings = SettingsProvider();

      await settings.updateProfile(
        name: 'Dipen',
        fullName: 'Dipen Patel',
        email: 'dipen@test.com',
      );

      expect(settings.userName, 'Dipen');
      expect(settings.userFullName, 'Dipen Patel');

      await settings.setAiResponseStyle('Concise');
      expect(settings.aiResponseStyle, 'Concise');

      final jsonStr = await settings.exportLocalDataJson();
      expect(jsonStr.contains('NEURON'), true);
      expect(jsonStr.contains('dipen@test.com'), true);
    });
  });

  group('WorkspaceProvider Tests', () {
    test('Manages default workspaces and supports creating custom workspace', () async {
      final act = ActivityProvider();
      final ws = WorkspaceProvider()..updateActivityProvider(act);

      expect(ws.workspaces.length >= 4, true);
      expect(ws.activeWorkspace.name, 'Personal');

      await ws.selectWorkspace('college');
      expect(ws.activeWorkspace.name, 'College');

      final countBefore = ws.workspaces.length;
      await ws.addWorkspace(
        name: 'Startup',
        description: 'New second brain venture',
      );

      expect(ws.workspaces.length, countBefore + 1);
      expect(ws.activeWorkspace.name, 'Startup');
    });
  });

  group('ReflectionProvider Tests', () {
    test('Synthesizes and persists daily reflection', () async {
      final act = ActivityProvider();
      final ref = ReflectionProvider()..updateActivityProvider(act);

      final countBefore = ref.reflections.length;
      await ref.saveReflection(
        energyLevel: 'Flow State',
        focusRating: 5,
        breakthrough: 'Solved mobile responsive UI layout',
        improvementArea: 'Take more frequent eye breaks',
        workspaceName: 'Projects',
      );

      expect(ref.reflections.length, countBefore + 1);
      final latest = ref.reflections.first;
      expect(latest.breakthrough, 'Solved mobile responsive UI layout');
      expect(latest.aiSynthesis.contains('Flow State'), true);
    });
  });

  group('ScheduleProvider Tests', () {
    test('Toggles schedule item and adds new event', () async {
      final act = ActivityProvider();
      final sch = ScheduleProvider()..updateActivityProvider(act);

      expect(sch.items.isNotEmpty, true);
      final item = sch.items.first;
      final initialStatus = item.isCompleted;

      await sch.toggleScheduleItem(item.id);
      expect(item.isCompleted, !initialStatus);

      final countBefore = sch.totalCount;
      await sch.addScheduleItem(
        time: '04:00 PM',
        title: 'Sprint Demo',
        subtitle: 'Review UI layout with team',
        category: ScheduleCategory.work,
      );

      expect(sch.totalCount, countBefore + 1);
    });
  });
}
