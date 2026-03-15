import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static DatabaseHelper getInstance() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'preppilot.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        task_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        date TEXT,
        time TEXT,
        priority INTEGER,
        status TEXT,
        linked_type TEXT,
        linked_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE activities (
        activity_id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        name TEXT,
        platform TEXT,
        deadline TEXT,
        progress INTEGER,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE projects (
        project_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        status TEXT,
        repo_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        note_id INTEGER PRIMARY KEY AUTOINCREMENT,
        linked_type TEXT,
        linked_id INTEGER,
        text_content TEXT,
        image_uri TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE file_index (
        file_id INTEGER PRIMARY KEY AUTOINCREMENT,
        linked_type TEXT,
        linked_id INTEGER,
        label TEXT,
        local_uri TEXT,
        file_type TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
        linked_type TEXT,
        linked_id INTEGER,
        trigger_type TEXT,
        scheduled_at TEXT,
        fired INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Database upgrade logic to be implemented here
  }
}
