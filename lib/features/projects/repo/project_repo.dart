import 'package:preppilot/core/database/database_helper.dart';
import 'package:preppilot/features/projects/model/project_model.dart';
import 'package:sqflite/sqflite.dart';

class ProjectRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<List<Project>> getAllProjects() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('projects');
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  Future<List<Project>> getProjectsByStatus(String status) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  Future<int> insertProject(Project project) async {
    final db = await _dbHelper.database;
    return await db.insert('projects', project.toMap());
  }

  Future<void> updateProject(Project project) async {
    final db = await _dbHelper.database;
    await db.update(
      'projects',
      project.toMap(),
      where: 'project_id = ?',
      whereArgs: [project.projectId],
    );
  }

  Future<void> deleteProject(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'projects',
      where: 'project_id = ?',
      whereArgs: [id],
    );
    // Also delete linked tasks logic if needed, but Step 9 implies we just link them.
    // Usually we don't delete tasks unless specified.
  }
}
