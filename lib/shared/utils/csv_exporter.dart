import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';

class CsvExporter {
  static Future<void> exportTasksCSV(List<Task> tasks) async {
    String csv = "Title,Date,Priority,Status,Linked Type\n";
    for (var t in tasks) {
      csv += "${t.title},${t.date.toIso8601String().split('T')[0]},${t.priority},${t.status},${t.linkedType ?? ''}\n";
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tasks_export.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'Exported Tasks');
  }

  static Future<void> exportActivitiesCSV(List<Activity> activities) async {
    String csv = "Name,Type,Platform,Deadline,Progress\n";
    for (var a in activities) {
      csv += "${a.name},${a.type},${a.platform},${a.deadline.toIso8601String().split('T')[0]},${a.progress}%\n";
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/activities_export.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'Exported Activities');
  }
}
