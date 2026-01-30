import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:battery_monitor/services/database_service.dart';

class DataCollector {
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();
  final DatabaseService _databaseService = DatabaseService();
  
  Timer? _collectionTimer;
  String _currentScene = '';
  Map<String, dynamic> _hardwareInfo = {};

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.phone,
      Permission.storage,
    ].request();
  }

  Future<void> startCollection(String scene) async {
    _currentScene = scene;
    await _collectHardwareInfo();
    
    _collectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _collectData();
    });
  }

  void stopCollection() {
    _collectionTimer?.cancel();
  }

  Future<void> _collectHardwareInfo() async {
    try {
      final deviceInfo = await _deviceInfo.iosInfo;
      _hardwareInfo = {
        'deviceModel': deviceInfo.model,
        'systemVersion': deviceInfo.systemVersion,
        'name': deviceInfo.name,
      };
    } catch (e) {
      print('Error collecting hardware info: $e');
    }
  }

  Future<void> _collectData() async {
    try {
      // 电池信息
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      
      // 屏幕亮度
      final brightness = await ScreenBrightness().current;
      
      // 网络信息
      final connectivityResult = await _connectivity.checkConnectivity();
      String networkType = '未知';
      if (connectivityResult == ConnectivityResult.wifi) {
        networkType = 'WiFi';
      } else if (connectivityResult == ConnectivityResult.mobile) {
        networkType = '移动网络';
      } else if (connectivityResult == ConnectivityResult.ethernet) {
        networkType = '以太网';
      }
      
      String? ipAddress;
      try {
        ipAddress = await _networkInfo.getWifiIP();
      } catch (e) {
        ipAddress = 'N/A';
      }
      
      // 构建数据
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'scene': _currentScene,
        'batteryLevel': batteryLevel,
        'batteryState': batteryState.toString(),
        'screenBrightness': brightness,
        'networkType': networkType,
        'ipAddress': ipAddress,
        'deviceModel': _hardwareInfo['deviceModel'] ?? 'N/A',
        'systemVersion': _hardwareInfo['systemVersion'] ?? 'N/A',
      };
      
      await _databaseService.insertData(data);
    } catch (e) {
      print('Error collecting data: $e');
    }
  }
}