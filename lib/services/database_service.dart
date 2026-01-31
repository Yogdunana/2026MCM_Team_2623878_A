import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // 获取数据库路径
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'battery_monitor.db');

    // 创建或打开数据库
    Database database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );

    return database;
  }

  Future<void> _createDatabase(Database db, int version) async {
    // 创建电池数据表
    await db.execute('''
      CREATE TABLE battery_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        battery_level INTEGER,
        is_charging INTEGER,
        device_model TEXT,
        os_version TEXT,
        app_version TEXT,
        scene TEXT,
        network_type TEXT,
        screen_brightness INTEGER,
        running_processes INTEGER,
        usage_duration INTEGER
      )
    ''');
  }

  Future<void> insertBatteryData(Map<String, dynamic> data) async {
    Database db = await database;
    await db.insert('battery_data', data);
  }

  Future<List<Map<String, dynamic>>> getAllBatteryData() async {
    Database db = await database;
    return await db.query('battery_data');
  }

  Future<List<Map<String, dynamic>>> getBatteryDataByScene(String scene) async {
    Database db = await database;
    return await db.query('battery_data', where: 'scene = ?', whereArgs: [scene]);
  }

  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('battery_data');
  }

  Future<int> getDataCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM battery_data')) ?? 0;
  }
}
