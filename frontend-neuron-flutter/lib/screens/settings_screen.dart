import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../core/theme/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/neuron_card.dart';
import '../widgets/app_dialogs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _apiUrlController;
  late TextEditingController _apiKeyController;

  bool _isTestingBackend = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nameController = TextEditingController(text: settings.userName);
    _fullNameController = TextEditingController(text: settings.userFullName);
    _emailController = TextEditingController(text: settings.userEmail);
    _apiUrlController = TextEditingController(text: settings.apiUrl);
    _apiKeyController = TextEditingController(text: settings.apiKey);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeProv = context.watch<ThemeProvider>();
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
          'Settings & Preferences',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Profile Card
          NeuronCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text(
                      'User Profile',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Short Name / Nickname'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      settings.updateProfile(
                        name: _nameController.text,
                        fullName: _fullNameController.text,
                        email: _emailController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Appearance & Theme Mode
          NeuronCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.palette_outlined, size: 20, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text(
                      'Appearance',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Theme Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemePreference>(
                    segments: const [
                      ButtonSegment(
                        value: ThemePreference.dark,
                        icon: Icon(Icons.dark_mode, size: 16),
                        label: Text('Dark'),
                      ),
                      ButtonSegment(
                        value: ThemePreference.light,
                        icon: Icon(Icons.light_mode, size: 16),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemePreference.system,
                        icon: Icon(Icons.brightness_auto, size: 16),
                        label: Text('Auto'),
                      ),
                    ],
                    selected: {themeProv.preference},
                    onSelectionChanged: (val) {
                      themeProv.setPreference(val.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI & Language Settings
          NeuronCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_outlined, size: 20, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text(
                      'AI Intelligence Preferences',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('Response Style', style: TextStyle(fontSize: 14)),
                    ),
                    DropdownButton<String>(
                      value: settings.aiResponseStyle,
                      dropdownColor: AppTheme.card(context),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Concise', child: Text('Concise')),
                        DropdownMenuItem(value: 'Detailed', child: Text('Detailed')),
                        DropdownMenuItem(value: 'Creative', child: Text('Creative')),
                        DropdownMenuItem(value: 'Technical', child: Text('Technical')),
                      ],
                      onChanged: (val) {
                        if (val != null) settings.setAiResponseStyle(val);
                      },
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('Language', style: TextStyle(fontSize: 14)),
                    ),
                    DropdownButton<String>(
                      value: settings.language,
                      dropdownColor: AppTheme.card(context),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'English', child: Text('English')),
                        DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                        DropdownMenuItem(value: 'French', child: Text('French')),
                        DropdownMenuItem(value: 'German', child: Text('German')),
                        DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                      ],
                      onChanged: (val) {
                        if (val != null) settings.setLanguage(val);
                      },
                    ),
                  ],
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Save Chat History Locally', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Keep conversation logs across sessions', style: TextStyle(fontSize: 12)),
                  value: settings.saveChatHistory,
                  onChanged: (val) => settings.setSaveChatHistory(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Synchronization & Notifications
          NeuronCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sync, size: 20, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text(
                      'Sync & Notifications',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-Sync Knowledge Base', style: TextStyle(fontSize: 14)),
                  value: settings.autoSync,
                  onChanged: (val) => settings.setAutoSync(val),
                ),
                if (settings.autoSync) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Sync Interval', style: TextStyle(fontSize: 14)),
                      ),
                      DropdownButton<String>(
                        value: settings.syncFrequency,
                        dropdownColor: AppTheme.card(context),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'Every 15 minutes', child: Text('15 Mins')),
                          DropdownMenuItem(value: 'Hourly', child: Text('Hourly')),
                          DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                        ],
                        onChanged: (val) {
                          if (val != null) settings.setSyncFrequency(val);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Push Notifications', style: TextStyle(fontSize: 14)),
                  value: settings.pushNotifications,
                  onChanged: (val) => settings.setPushNotifications(val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Task & Due Date Reminders', style: TextStyle(fontSize: 14)),
                  value: settings.taskReminders,
                  onChanged: (val) => settings.setTaskReminders(val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily Morning Knowledge Digest', style: TextStyle(fontSize: 14)),
                  value: settings.dailyDigest,
                  onChanged: (val) => settings.setDailyDigest(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Backend REST API Configuration (FastAPI)
          NeuronCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dns_outlined, size: 20, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text(
                      'FastAPI & LangChain Backend',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'On Android Studio emulator, "10.0.2.2" maps directly to localhost on your PC host machine.',
                  style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(context), height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Backend Base URL',
                    hintText: 'http://10.0.2.2:8000',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _apiKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API Authorization Key (Optional)',
                    hintText: 'Bearer token or API Secret',
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isTestingBackend
                          ? null
                          : () async {
                              setState(() => _isTestingBackend = true);
                              settings.updateApiConfig(
                                url: _apiUrlController.text,
                                key: _apiKeyController.text,
                              );
                              final result = await settings.testBackendConnection();
                              setState(() => _isTestingBackend = false);

                              if (!context.mounted) return;
                              if (result.isSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Connected to FastAPI! Health: ${result.data}'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result.error ?? 'Could not reach backend.'),
                                    backgroundColor: AppColors.error,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                      icon: _isTestingBackend
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_check, size: 16),
                      label: const Text('Test Connection'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        settings.updateApiConfig(
                          url: _apiUrlController.text,
                          key: _apiKeyController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backend configuration saved')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save URL'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Management: Export & Clear
          NeuronCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storage_outlined, size: 20, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text(
                      'Data Management',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.primaryLight),
                  title: const Text('Export Local Data (JSON)', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Backup all tasks, docs, chat sessions, and settings', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () async {
                    final jsonStr = await settings.exportLocalDataJson();
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Exported Local Data', style: TextStyle(fontSize: 16)),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: SelectableText(
                              jsonStr,
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton.icon(
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy to Clipboard'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: jsonStr));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('JSON data copied to clipboard!')),
                              );
                            },
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever, color: AppColors.error),
                  title: const Text('Clear All Local Data', style: TextStyle(fontSize: 14, color: AppColors.error)),
                  subtitle: const Text('Reset database, documents, tasks, and cache to default', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.error),
                  onTap: () {
                    AppDialogs.showConfirmDialog(
                      context,
                      title: 'Reset Local Database?',
                      message:
                          'Are you sure you want to clear all tasks, documents, chat messages, and settings? This operation cannot be reversed.',
                      confirmLabel: 'Clear All Data',
                      isDestructive: true,
                      onConfirm: () async {
                        await settings.clearAllData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All local data has been reset to defaults.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App Information & Open Source Licenses
          NeuronCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.psychology, size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${AppConstants.appTagline} • v${AppConstants.appVersion}',
                            style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.policy_outlined, size: 20),
                  title: const Text('Open Source Licenses', style: TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: AppConstants.appName,
                      applicationVersion: AppConstants.appVersion,
                      applicationLegalese: 'Copyright © 2026 Dipen Patel. All rights reserved.',
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout, size: 20, color: AppColors.warning),
                  title: const Text('Sign Out', style: TextStyle(fontSize: 13, color: AppColors.warning)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.warning),
                  onTap: () {
                    AppDialogs.showConfirmDialog(
                      context,
                      title: 'Sign Out?',
                      message: 'Are you sure you want to sign out of NEURON?',
                      confirmLabel: 'Sign Out',
                      isDestructive: false,
                      onConfirm: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed out successfully')),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    ),
  ),
),
);
  }
}
