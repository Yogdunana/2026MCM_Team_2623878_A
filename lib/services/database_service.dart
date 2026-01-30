import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DatabaseService {
  static Database? _database;
  final String _databaseName = 'battery_monitor.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = p.join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE battery_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        scene TEXT NOT NULL,
        batteryLevel INTEGER,
        batteryState TEXT,
        screenBrightness REAL,
        networkType TEXT,
        ipAddress TEXT,
        deviceModel TEXT,
        systemVersion TEXT
      )
    ''');
  }

  Future<void> insertData(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('battery_data', data);
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await database;
    return await db.query('battery_data', orderBy: 'timestamp');
  }

  Future<List<Map<String, dynamic>>> getDataByScene(String scene) async {
    final db = await database;
    return await db.query('battery_data', where: 'scene = ?', whereArgs: [scene]);
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('battery_data');
  }

  Future<int> getRecordCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM battery_data');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}