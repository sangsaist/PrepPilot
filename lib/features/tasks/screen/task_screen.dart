import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/tasks/provider/task_provider.dart';
import 'package:preppilot/features/tasks/widgets/task_card.dart';
import 'package:preppilot/features/tasks/widgets/task_bottom_sheet.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueTasks = ref.watch(overdueTasksProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final upcomingTasks = ref.watch(upcomingTasksProvider);
    final isLoading = ref.watch(taskNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: isLoading && overdueTasks.isEmpty && todayTasks.isEmpty && upcomingTasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildTaskLists(context, overdueTasks, todayTasks, upcomingTasks),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const TaskBottomSheet(),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskLists(
    BuildContext context,
    List<Task> overdue,
    List<Task> today,
    List<Task> upcoming,
  ) {
    if (overdue.isEmpty && today.isEmpty && upcoming.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_outlined, size: 64, color: AppTheme.secondaryText.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No tasks found. Tap + to add one!',
              style: TextStyle(color: AppTheme.secondaryText),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overdue.isNotEmpty) ...[
          _buildSectionHeader('Overdue', Colors.red),
          ...overdue.map((t) => TaskCard(task: t)),
          const SizedBox(height: 16),
        ],
        if (today.isNotEmpty) ...[
          _buildSectionHeader('Today', AppTheme.primaryColor),
          ...today.map((t) => TaskCard(task: t)),
          const SizedBox(height: 16),
        ],
        if (upcoming.isNotEmpty) ...[
          _buildSectionHeader('Upcoming', AppTheme.secondaryText),
          ...upcoming.map((t) => TaskCard(task: t)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
