import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:performance_monitor/performance_monitor.dart';
import 'package:practice/services/json_placeholder_service.dart';
import 'package:practice/utils/http/api/network_manager.dart';
import 'package:practice/utils/toast_util.dart';

class DeviceMonitorPage extends StatefulWidget {
  const DeviceMonitorPage({super.key});

  @override
  State<DeviceMonitorPage> createState() => _DeviceMonitorPageState();
}

class _DeviceMonitorPageState extends State<DeviceMonitorPage> {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String _deviceModel = '';
  String _deviceOs = '';

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _startMonitoring();
  }

  @override
  void dispose() {
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

  // 开始监控，使用插件提供的监控流
  void _startMonitoring() {
    // 初始化插件悬浮窗（仅在调试/开发环境建议启用）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceMonitor().initialize(
        context: context,
        dio: NetworkManager.instance.dio,
      );
    });
  }

  // 本页不再直接通过MethodChannel获取数据

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备性能监控'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceInfoCard(),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                showLoading();
                for (int i = 0; i < 5; ++i) {
                  await JsonPlaceholderService.getUsers();
                }
                dismissLoading();
              },
              child: const Text('获取用户列表'),
            ),
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
            const SizedBox(height: 16),
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
              value: 0,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getCpuColor(0 * 100),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(0 * 100).toStringAsFixed(1)}%',
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
              value: 0,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getMemoryColor(0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(0 * 100).toStringAsFixed(1)}%',
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
