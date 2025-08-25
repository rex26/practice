import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class CpuMonitor {
  Timer? _timer;
  final StreamController<double> _cpuUsageController = StreamController<double>.broadcast();
  static const MethodChannel _channel = MethodChannel('performance_monitor');

  // 获取CPU使用率流
  Stream<double> get cpuUsageStream => _cpuUsageController.stream;

  void start({Duration interval = const Duration(seconds: 1)}) {
    _timer = Timer.periodic(interval, (_) => _updateCpuUsage());
  }

  Future<void> _updateCpuUsage() async {
    // 在不同平台实现CPU使用率获取
    double usage = 0.0;

    if (Platform.isAndroid) {
      // 使用method channel调用原生代码获取CPU信息
      usage = await _getAndroidCpuUsage();
    } else if (Platform.isIOS) {
      usage = await _getIOSCpuUsage();
    }

    _cpuUsageController.add(usage);
  }

  // Android平台实现
  Future<double> _getAndroidCpuUsage() async {
    try {
      final v = await _channel.invokeMethod<double>('getCpuUsage');
      if (v == null) return 0.0;
      // 原生返回应为0..1之间的小数
      return v.clamp(0.0, 1.0);
    } catch (_) {
      return 0.0;
    }
  }

  // iOS平台实现
  Future<double> _getIOSCpuUsage() async {
    try {
      final v = await _channel.invokeMethod<double>('getCpuUsage');
      if (v == null) return 0.0;
      return v.clamp(0.0, 1.0);
    } catch (_) {
      return 0.0;
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _cpuUsageController.close();
  }
}