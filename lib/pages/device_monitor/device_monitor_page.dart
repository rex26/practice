import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceMonitorPage extends StatefulWidget {
  const DeviceMonitorPage({super.key});

  @override
  State<DeviceMonitorPage> createState() => _DeviceMonitorPageState();
}

class _DeviceMonitorPageState extends State<DeviceMonitorPage> {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const platform = MethodChannel('com.example.practice/system_stats');

  // 性能数据
  double _cpuUsage = 0.0;
  double _memoryUsage = 0.0;
  String _deviceModel = '';
  String _deviceOs = '';

  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _startMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 获取设备基本信息
  Future<void> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        _deviceOs = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceModel = iosInfo.model;
        _deviceOs = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      }
    } catch (e) {
      debugPrint('获取设备信息失败: $e');
    }
  }

  // 开始周期性监控
  void _startMonitoring() {
    // 立即执行一次
    _updatePerformanceData();
    
    // 每秒更新一次数据
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePerformanceData();
    });
  }

  // 更新性能数据
  Future<void> _updatePerformanceData() async {
    try {
      // 调用平台特定代码获取CPU和内存使用率
      final cpuUsage = await platform.invokeMethod<double>('getCpuUsage');
      final memoryUsage = await platform.invokeMethod('getMemoryUsage');
      
      if (mounted) {
        setState(() {
          if (cpuUsage != null) {
            _cpuUsage = cpuUsage;
          }
          
          if (memoryUsage != null) {
            // 解决类型转换问题
            _memoryUsage = memoryUsage;
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('获取性能数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备性能监控'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeviceInfoCard(),
                  const SizedBox(height: 20),
                  _buildCpuCard(),
                  const SizedBox(height: 20),
                  _buildMemoryCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '设备信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text('型号: $_deviceModel'),
            const SizedBox(height: 8),
            Text('系统: $_deviceOs'),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCpuCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CPU使用率',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            LinearProgressIndicator(
              value: _cpuUsage,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getCpuColor(_cpuUsage * 100),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_cpuUsage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '内存使用率',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            LinearProgressIndicator(
              value: _memoryUsage,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getMemoryColor(_memoryUsage),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_memoryUsage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 根据CPU使用率返回对应的颜色
  Color _getCpuColor(double usage) {
    if (usage < 50) {
      return Colors.green;
    } else if (usage < 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // 根据内存使用率返回对应的颜色
  Color _getMemoryColor(double usage) {
    if (usage < 0.5) {
      return Colors.green;
    } else if (usage < 0.8) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
