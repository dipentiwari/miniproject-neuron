import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/documents_provider.dart';
import 'providers/connections_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/workspace_provider.dart';
import 'providers/reflection_provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/connections_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/knowledge_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reflection_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF111421),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NeuronApp());
}

class NeuronApp extends StatelessWidget {
  const NeuronApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProxyProvider<ActivityProvider, TasksProvider>(
          create: (_) => TasksProvider(),
          update: (_, act, tasks) =>
              (tasks ?? TasksProvider())..updateActivityProvider(act),
        ),
        ChangeNotifierProxyProvider<ActivityProvider, DocumentsProvider>(
          create: (_) => DocumentsProvider(),
          update: (_, act, docs) =>
              (docs ?? DocumentsProvider())..updateActivityProvider(act),
        ),
        ChangeNotifierProxyProvider<ActivityProvider, ConnectionsProvider>(
          create: (_) => ConnectionsProvider(),
          update: (_, act, conn) =>
              (conn ?? ConnectionsProvider())..updateActivityProvider(act),
        ),
        ChangeNotifierProxyProvider<ActivityProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, act, chat) =>
              (chat ?? ChatProvider())..updateActivityProvider(act),
        ),
        ChangeNotifierProxyProvider<ActivityProvider, SettingsProvider>(
          create: (_) => SettingsProvider(),
          update: (_, act, set) =>
              (set ?? SettingsProvider())..updateActivityProvider(act),
        ),
        ChangeNotifierProxyProvider<ActivityProvider, WorkspaceProvider>(
          create: (_) => WorkspaceProvider(),
          update: (_, act, ws) =>
              (ws ?? WorkspaceProvider())..updateActivityProvider(act),
        ),
        ChangeNotifierProxyProvider<ActivityProvider, ReflectionProvider>(
          create: (_) => ReflectionProvider(),
          update: (_, act, ref) =>
              (ref ?? ReflectionProvider())..updateActivityProvider(act),
        ),
        ChangeNotifierProxyProvider<ActivityProvider, ScheduleProvider>(
          create: (_) => ScheduleProvider(),
          update: (_, act, sch) =>
              (sch ?? ScheduleProvider())..updateActivityProvider(act),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            title: 'NEURON — Second Brain',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProv.themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const MainNavigationScreen(),
              '/connections': (_) => const ConnectionsScreen(),
              '/timeline': (_) => const TimelineScreen(),
              '/chat': (_) => const ChatScreen(),
              '/knowledge': (_) => const KnowledgeScreen(),
              '/tasks': (_) => const TasksScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/reflection': (_) => const ReflectionScreen(),
            },
          );
        },
      ),
    );
  }
}
