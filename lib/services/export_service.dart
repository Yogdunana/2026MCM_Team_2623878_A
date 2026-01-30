import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:battery_monitor/services/database_service.dart';

class ExportService {
  final DatabaseService _databaseService = DatabaseService();

  Future<String> exportData() async {
    final List<Map<String, dynamic>> data = await _databaseService.getAllData();
    
    if (data.isEmpty) {
      throw Exception('No data to export');
    }

    // 转换数据为CSV格式
    final List<List<dynamic>> csvData = [];
    
    // 添加表头
    csvData.add([
      'ID', 'Timestamp', 'Scene', 'Battery Level (%)', 
      'Battery State', 'Screen Brightness', 'Network Type', 
      'IP Address', 'Device Model', 'System Version'
    ]);

    // 添加数据行
    for (var record in data) {
      csvData.add([
        record['id'],
        record['timestamp'],
        record['scene'],
        record['batteryLevel'],
        record['batteryState'],
        record['screenBrightness'],
        record['networkType'],
        record['ipAddress'],
        record['deviceModel'],
        record['systemVersion'],
      ]);
    }

    // 生成CSV字符串
    final String csvString = const ListToCsvConverter().convert(csvData);

    // 获取存储路径
    final Directory directory = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    
    // 创建导出目录
    final Directory exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    // 生成文件名
    final String timestamp = DateTime.now().toString().replaceAll(':', '-');
    final String filePath = '${exportDir.path}/battery_data_$timestamp.csv';

    // 写入文件
    final File file = File(filePath);
    await file.writeAsString(csvString);

    return filePath;
  }

  Future<String> exportDataByScene(String scene) async {
    final List<Map<String, dynamic>> data = await _databaseService.getDataByScene(scene);
    
    if (data.isEmpty) {
      throw Exception('No data for scene: $scene');
    }

    // 转换数据为CSV格式
    final List<List<dynamic>> csvData = [];
    
    // 添加表头
    csvData.add([
      'ID', 'Timestamp', 'Battery Level (%)', 
      'Battery State', 'Screen Brightness', 'Network Type', 
      'IP Address', 'Device Model', 'System Version'
    ]);

    // 添加数据行
    for (var record in data) {
      csvData.add([
        record['id'],
        record['timestamp'],
        record['batteryLevel'],
        record['batteryState'],
        record['screenBrightness'],
        record['networkType'],
        record['ipAddress'],
        record['deviceModel'],
        record['systemVersion'],
      ]);
    }

    // 生成CSV字符串
    final String csvString = const ListToCsvConverter().convert(csvData);

    // 获取存储路径
    final Directory directory = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    
    // 创建导出目录
    final Directory exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    // 生成文件名
    final String timestamp = DateTime.now().toString().replaceAll(':', '-');
    final String filePath = '${exportDir.path}/battery_data_${scene}_$timestamp.csv';

    // 写入文件
    final File file = File(filePath);
    await file.writeAsString(csvString);

    return filePath;
  }
}