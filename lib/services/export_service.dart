import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:battery_monitor/services/database_service.dart';

class ExportService {
  final DatabaseService _databaseService = DatabaseService();

  Future<String> exportData() async {
    try {
      // 获取所有电池数据
      List<Map<String, dynamic>> batteryData = await _databaseService.getAllBatteryData();
      
      if (batteryData.isEmpty) {
        throw Exception('没有可导出的数据');
      }
      
      // 创建CSV内容
      String csvContent = _generateCSVContent(batteryData);
      
      // 获取导出路径
      String filePath = await _saveCSVFile(csvContent);
      
      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  String _generateCSVContent(List<Map<String, dynamic>> data) {
    // CSV表头
    String header = '时间戳,电池电量,是否充电,设备型号,操作系统版本,应用版本,使用场景,网络类型,屏幕亮度,运行进程数,使用时长\n';
    
    // CSV数据行
    String rows = '';
    for (var item in data) {
      rows += '${item['timestamp']},'
          '${item['battery_level']},'
          '${item['is_charging'] == 1 ? '是' : '否'},'
          '${item['device_model']},'
          '${item['os_version']},'
          '${item['app_version']},'
          '${item['scene']},'
          '${item['network_type']},'
          '${item['screen_brightness']},'
          '${item['running_processes']},'
          '${item['usage_duration']}\n';
    }
    
    return header + rows;
  }

  Future<String> _saveCSVFile(String content) async {
    // 获取文档目录
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }
    
    // 确保目录存在
    if (!await directory!.exists()) {
      await directory.create(recursive: true);
    }
    
    // 生成文件名
    String fileName = 'battery_monitor_${DateTime.now().toString().replaceAll(' ', '_').replaceAll(':', '-')}.csv';
    String filePath = '${directory.path}/$fileName';
    
    // 写入文件
    File file = File(filePath);
    await file.writeAsString(content, encoding: utf8);
    
    return filePath;
  }
}
