import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/core/theme/theme_provider.dart';
import 'package:preppilot/shared/utils/csv_exporter.dart';
import 'package:preppilot/shared/utils/pdf_exporter.dart';
import 'package:preppilot/features/tasks/provider/task_provider.dart';
import 'package:preppilot/features/activities/provider/activity_provider.dart';

import 'package:preppilot/shared/provider/user_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _editName(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Your Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await ref.read(userProvider.notifier).updateName(newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final userName = ref.watch(userProvider);
    final tasks = ref.watch(taskNotifierProvider).value ?? [];
    final activities = ref.watch(activityNotifierProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.wb_sunny_outlined)),
                ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings_brightness)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {themeMode},
              onSelectionChanged: (newSelection) {
                ref.read(themeProvider.notifier).setTheme(newSelection.first);
              },
            ),
          ),
          
          _buildSectionHeader('Profile'),
          ListTile(
            title: const Text('Name'),
            subtitle: Text(userName),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editName(userName),
          ),

          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export all tasks (CSV)'),
            onTap: () => CsvExporter.exportTasksCSV(tasks),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export all activities (CSV)'),
            onTap: () => CsvExporter.exportActivitiesCSV(activities),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Generate achievement PDF'),
            onTap: () => PdfExporter.exportAchievementPDF(
              userName: userName,
              activities: activities,
              tasks: tasks,
            ),
          ),

          _buildSectionHeader('About'),
          const ListTile(
            title: Text('PrepPilot'),
            subtitle: Text('Version 1.0.0'),
          ),
          ListTile(
            title: const Text('Built by sangsaist'),
            subtitle: const Text('GitHub: https://github.com/sangsaist/PrepPilot'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(Uri.parse('https://github.com/sangsaist/PrepPilot')),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
