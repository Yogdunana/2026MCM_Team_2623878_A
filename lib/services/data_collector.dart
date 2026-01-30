import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_monitor/services/database_service.dart';

class DataCollector {
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();
  final DatabaseService _databaseService = DatabaseService();
  
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  StreamSubscription<int>? _batteryLevelSubscription;
  Timer? _dataCollectionTimer;
  String _currentScene = '';
  DateTime _collectionStartTime = DateTime.now();

  Future<void> requestPermissions() async {
    // 请求必要的权限
    // 对于电池信息，通常不需要特殊权限
  }

  void startCollection(String scene) {
    _currentScene = scene;
    _collectionStartTime = DateTime.now();
    
    // 立即采集一次数据
    _collectData();
    
    // 设置定时采集，每30秒一次
    _dataCollectionTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _collectData();
    });

    // 监听电池状态变化
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      _collectData();
    });
  }

  void stopCollection() {
    _dataCollectionTimer?.cancel();
    _batteryStateSubscription?.cancel();
    _batteryLevelSubscription?.cancel();
  }

  Future<void> _collectData() async {
    try {
      // 采集电池信息
      int batteryLevel = await _battery.batteryLevel;
      BatteryState batteryState = await _battery.batteryState;
      bool isCharging = batteryState == BatteryState.charging || batteryState == BatteryState.full;
      
      // 采集系统信息
      String deviceModel = await _getDeviceModel();
      String osVersion = await _getOsVersion();
      
      // 采集网络状态
      ConnectivityResult connectivityResult = await _connectivity.checkConnectivity();
      String networkType = _getNetworkType(connectivityResult);
      
      // 采集应用信息
      int screenBrightness = await _getScreenBrightness();
      int runningProcesses = await _getRunningProcesses();
      
      // 计算使用时长
      int usageDuration = DateTime.now().difference(_collectionStartTime).inMinutes;
      
      // 存储数据
      await _databaseService.insertBatteryData({
        'timestamp': DateTime.now().toIso8601String(),
        'battery_level': batteryLevel,
        'is_charging': isCharging ? 1 : 0,
        'device_model': deviceModel,
        'os_version': osVersion,
        'app_version': '1.0.0',
        'scene': _currentScene,
        'network_type': networkType,
        'screen_brightness': screenBrightness,
        'running_processes': runningProcesses,
        'usage_duration': usageDuration,
      });
    } catch (e) {
      // 使用debugPrint代替print，在生产模式下会被禁用
      debugPrint('采集数据失败: $e');
    }
  }

  Future<String> _getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model;
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<String> _getOsVersion() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.release;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.systemVersion;
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getNetworkType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'None';
      default:
        return 'Unknown';
    }
  }

  Future<int> _getScreenBrightness() async {
    try {
      // 注意：获取屏幕亮度可能需要权限
      // 这里返回一个模拟值
      return 50;
    } catch (e) {
      return 50;
    }
  }

  Future<int> _getRunningProcesses() async {
    try {
      // 注意：获取运行进程数可能需要权限
      // 这里返回一个模拟值
      return 20;
    } catch (e) {
      return 20;
    }
  }
}
