import 'package:flutter/material.dart';
import 'package:battery_monitor/services/data_collector.dart';
import 'package:battery_monitor/services/database_service.dart';
import 'package:battery_monitor/services/export_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataCollector _dataCollector = DataCollector();
  final DatabaseService _databaseService = DatabaseService();
  final ExportService _exportService = ExportService();
  
  bool _isCollecting = false;
  String _currentScene = '选择场景';
  final List<String> _scenes = [
    '游戏', '视频播放', '语音通话', '视频通话', 
    '浏览网页', '听音乐', '待机'
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _databaseService.initializeDatabase();
    await _dataCollector.requestPermissions();
  }

  void _startCollection() {
    if (_currentScene == '选择场景') {
      _showAlert('请先选择使用场景');
      return;
    }
    
    setState(() {
      _isCollecting = true;
    });
    _dataCollector.startCollection(_currentScene);
  }

  void _stopCollection() {
    setState(() {
      _isCollecting = false;
    });
    _dataCollector.stopCollection();
  }

  Future<void> _exportData() async {
    try {
      String filePath = await _exportService.exportData();
      _showAlert('数据已导出到: $filePath');
    } catch (e) {
      _showAlert('导出失败: $e');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电池监测'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'MCM Problem A - 电池使用监测',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // 场景选择
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('选择使用场景:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _scenes.map((scene) {
                        return ChoiceChip(
                          label: Text(scene),
                          selected: _currentScene == scene,
                          onSelected: (selected) {
                            setState(() {
                              _currentScene = selected ? scene : '选择场景';
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 数据采集控制
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('数据采集', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _isCollecting ? null : _startCollection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('开始采集'),
                        ),
                        ElevatedButton(
                          onPressed: _isCollecting ? _stopCollection : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('停止采集'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isCollecting ? '正在采集数据...' : '采集已停止',
                      style: TextStyle(
                        color: _isCollecting ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 数据导出
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('数据导出', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _exportData,
                      child: const Text('导出为CSV'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}