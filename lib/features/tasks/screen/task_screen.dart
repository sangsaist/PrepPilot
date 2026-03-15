import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/tasks/provider/task_provider.dart';
import 'package:preppilot/features/tasks/widgets/task_card.dart';
import 'package:preppilot/features/tasks/widgets/task_bottom_sheet.dart';
import 'package:preppilot/shared/widgets/empty_state.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final overdueTasks = ref.watch(overdueTasksProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final upcomingTasks = ref.watch(upcomingTasksProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(taskNotifierProvider.notifier).refreshTasks(),
        child: tasksAsync.when(
          data: (_) => _buildTaskLists(context, overdueTasks, todayTasks, upcomingTasks, ref),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => EmptyState(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            subtitle: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(taskNotifierProvider),
          ),
        ),
      ),
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
    WidgetRef ref,
  ) {
    if (overdue.isEmpty && today.isEmpty && upcoming.isEmpty) {
      return EmptyState(
        icon: Icons.check_box_outline_blank,
        title: "No tasks yet",
        subtitle: "Tap + to add your first task",
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
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
