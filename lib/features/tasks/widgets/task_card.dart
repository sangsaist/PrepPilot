import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/tasks/provider/task_provider.dart';
import 'package:preppilot/features/tasks/widgets/task_bottom_sheet.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('task_${task.taskId}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (task.taskId != null) {
          ref.read(taskNotifierProvider.notifier).deleteTask(task.taskId!);
        }
      },
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => TaskBottomSheet(task: task),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: AppTheme.secondaryText),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.date),
                            style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                          ),
                          const SizedBox(width: 12),
                          _buildPriorityChip(),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusToggle(ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color chipColor;
    String label;
    switch (task.priority) {
      case 3:
        chipColor = Colors.red.shade100;
        label = 'High';
        break;
      case 2:
        chipColor = Colors.amber.shade100;
        label = 'Medium';
        break;
      default:
        chipColor = Colors.green.shade100;
        label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: label == 'High' ? Colors.red : (label == 'Medium' ? Colors.amber.shade900 : Colors.green.shade900),
        ),
      ),
    );
  }

  Widget _buildStatusToggle(WidgetRef ref) {
    IconData icon;
    Color color;
    switch (task.status) {
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'in_progress':
        icon = Icons.play_circle_outline;
        color = AppTheme.primaryColor;
        break;
      default:
        icon = Icons.radio_button_unchecked;
        color = AppTheme.secondaryText;
    }

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () {
        String nextStatus;
        if (task.status == 'pending') {
          nextStatus = 'in_progress';
        } else if (task.status == 'in_progress') {
          nextStatus = 'completed';
        } else {
          nextStatus = 'pending';
        }
        ref.read(taskNotifierProvider.notifier).updateTask(task.copyWith(status: nextStatus));
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
