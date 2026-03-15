import 'package:preppilot/core/database/database_helper.dart';
import 'package:preppilot/features/activities/model/activity_model.dart';
import 'package:sqflite/sqflite.dart';

class ActivityRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<List<Activity>> getAllActivities() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('activities', orderBy: 'deadline ASC');
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<List<Activity>> getActivitiesByType(String type) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'deadline ASC',
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<List<Activity>> getUpcomingDeadlines(int withinDays) async {
    final db = await _dbHelper.database;
    final DateTime now = DateTime.now();
    final DateTime limit = now.add(Duration(days: withinDays));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'deadline BETWEEN ? AND ? AND progress < 100',
      whereArgs: [now.toIso8601String(), limit.toIso8601String()],
      orderBy: 'deadline ASC',
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<int> insertActivity(Activity activity) async {
    final db = await _dbHelper.database;
    return await db.insert('activities', activity.toMap());
  }

  Future<void> updateActivity(Activity activity) async {
    final db = await _dbHelper.database;
    await db.update(
      'activities',
      activity.toMap(),
      where: 'activity_id = ?',
      whereArgs: [activity.activityId],
    );
  }

  Future<void> deleteActivity(int activityId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'activities',
      where: 'activity_id = ?',
      whereArgs: [activityId],
    );
  }
}
