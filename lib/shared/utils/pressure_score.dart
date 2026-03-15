import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';

int calcPressureScore(List<Task> tasks, List<Activity> activities) {
  int score = 0;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  for (final task in tasks) {
    if (task.status == 'completed') continue;
    
    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
    final diff = taskDate.difference(today).inDays;
    
    if (diff < 0) {
      score += 3; // Overdue
    } else if (diff == 0) {
      score += 2; // Due today
    } else if (diff <= 7) {
      score += 1; // Due this week
    }
  }

  for (final activity in activities) {
    if (activity.progress >= 100) continue;
    
    final deadlineDate = DateTime(activity.deadline.year, activity.deadline.month, activity.deadline.day);
    final diff = deadlineDate.difference(today).inDays;
    
    if (diff < 0) {
      score += 3;
    } else if (diff <= 2) {
      score += 2;
    } else if (diff <= 7) {
      score += 1;
    }
  }

  return score.clamp(0, 100);
}
