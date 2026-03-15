import 'package:preppilot/core/database/database_helper.dart';
import 'package:preppilot/features/tasks/model/task_model.dart';
import 'package:sqflite/sqflite.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'date ASC, time ASC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final String dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: "date LIKE ?",
      whereArgs: ['$dateString%'],
      orderBy: 'time ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByLinkedItem(String type, int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'linked_type = ? AND linked_id = ?',
      whereArgs: [type, id],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    final db = await _dbHelper.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'task_id = ?',
      whereArgs: [task.taskId],
    );
  }

  Future<void> deleteTask(int taskId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'tasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  Future<List<Task>> getOverdueTasks() async {
    final db = await _dbHelper.database;
    final String now = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: "date < ? AND status != ?",
      whereArgs: [now, 'completed'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksDueThisWeek() async {
    final db = await _dbHelper.database;
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startOfWeek.toIso8601String(), endOfWeek.toIso8601String()],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }
}
