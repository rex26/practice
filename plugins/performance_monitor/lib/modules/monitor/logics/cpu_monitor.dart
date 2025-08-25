import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class CpuMonitor {
  // Singleton pattern
  static final CpuMonitor _instance = CpuMonitor._internal();
  factory CpuMonitor() => _instance;
  CpuMonitor._internal();

  Timer? _timer;
  final StreamController<double> _cpuUsageController = StreamController<double>.broadcast();
  static const MethodChannel _channel = MethodChannel('performance_monitor');

  // Get CPU usage stream
  Stream<double> get cpuUsageStream => _cpuUsageController.stream;

  void start({Duration interval = const Duration(seconds: 1)}) {
    if (_timer != null) return; // idempotent
    _timer = Timer.periodic(interval, (_) => _updateCpuUsage());
  }

  Future<void> _updateCpuUsage() async {
    // Implement CPU usage retrieval for different platforms
    double usage = 0.0;

    if (Platform.isAndroid) {
      // Use method channel to call native code to get CPU information
      usage = await _getAndroidCpuUsage();
    } else if (Platform.isIOS) {
      usage = await _getIOSCpuUsage();
    }

    _cpuUsageController.add(usage);
  }

  // Android platform implementation
  Future<double> _getAndroidCpuUsage() async {
    try {
      final v = await _channel.invokeMethod<double>('getCpuUsage');
      if (v == null) return 0.0;
      // Native return should be a decimal between 0..1
      return v.clamp(0.0, 1.0);
    } catch (_) {
      return 0.0;
    }
  }

  // iOS platform implementation
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