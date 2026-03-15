import 'package:preppilot/features/notifications/service/notification_service.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';

class NotificationRules {
  static final _service = NotificationService();

  static void onTaskCreatedOrUpdated(Task task) {
    if (task.taskId != null) {
      _service.scheduleDeadlineReminder(task.taskId!, task.title, task.date);
    }
  }

  static void onTaskDeleted(int taskId) {
    _service.cancelReminder(taskId);
  }

  static void onActivityCreatedOrUpdated(Activity activity) {
    if (activity.activityId != null) {
      _service.scheduleDeadlineReminder(activity.activityId! + 5000, activity.name, activity.deadline);
      
      if (activity.progress == 100) {
        _service.scheduleResumeReminder(activity.activityId! + 5000, activity.name);
      }
    }
  }

  static void onActivityDeleted(int activityId) {
    _service.cancelReminder(activityId + 5000);
  }
}
