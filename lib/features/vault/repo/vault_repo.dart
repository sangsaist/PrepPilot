import 'package:preppilot/core/database/database_helper.dart';
import 'package:preppilot/features/vault/model/file_index_model.dart';
import 'package:sqflite/sqflite.dart';

class VaultRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<List<FileIndex>> getAllFiles() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('file_index', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => FileIndex.fromMap(maps[i]));
  }

  Future<List<FileIndex>> getFilesByLinkedItem(String type, int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'file_index',
      where: 'linked_type = ? AND linked_id = ?',
      whereArgs: [type, id],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => FileIndex.fromMap(maps[i]));
  }

  Future<List<FileIndex>> getFilesByType(String fileType) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'file_index',
      where: 'file_type = ?',
      whereArgs: [fileType],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => FileIndex.fromMap(maps[i]));
  }

  Future<int> insertFile(FileIndex file) async {
    final db = await _dbHelper.database;
    return await db.insert('file_index', file.toMap());
  }

  Future<void> deleteFile(int fileId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'file_index',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );
  }
}
