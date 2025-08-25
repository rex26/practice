import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class MemoryMonitor {
  // Singleton pattern
  static final MemoryMonitor _instance = MemoryMonitor._internal();
  factory MemoryMonitor() => _instance;
  MemoryMonitor._internal();

  Timer? _timer;
  final StreamController<MemoryInfo> _memoryController = StreamController<MemoryInfo>.broadcast();
  static const MethodChannel _channel = MethodChannel('performance_monitor');

  Stream<MemoryInfo> get memoryStream => _memoryController.stream;

  void start({Duration interval = const Duration(seconds: 1)}) {
    if (_timer != null) return; // idempotent
    _timer = Timer.periodic(interval, (_) => _updateMemoryUsage());
  }

  Future<void> _updateMemoryUsage() async {
    MemoryInfo info;

    if (Platform.isAndroid) {
      info = await _getAndroidMemoryInfo();
    } else if (Platform.isIOS) {
      info = await _getIOSMemoryInfo();
    } else {
      info = MemoryInfo(totalMb: 0, usedMb: 0, percentUsed: 0);
    }

    _memoryController.add(info);
  }

  Future<MemoryInfo> _getAndroidMemoryInfo() async {
    try {
      final v = await _channel.invokeMethod<double>('getMemoryUsage');
      final percent = (v ?? 0.0).clamp(0.0, 1.0);
      return MemoryInfo(totalMb: 0, usedMb: 0, percentUsed: percent);
    } catch (_) {
      return MemoryInfo(totalMb: 0, usedMb: 0, percentUsed: 0.0);
    }
  }

  Future<MemoryInfo> _getIOSMemoryInfo() async {
    try {
      final v = await _channel.invokeMethod<double>('getMemoryUsage');
      final percent = (v ?? 0.0).clamp(0.0, 1.0);
      return MemoryInfo(totalMb: 0, usedMb: 0, percentUsed: percent);
    } catch (_) {
      return MemoryInfo(totalMb: 0, usedMb: 0, percentUsed: 0.0);
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _memoryController.close();
  }
}

class MemoryInfo {
  final double totalMb;
  final double usedMb;
  final double percentUsed;

  MemoryInfo({required this.totalMb, required this.usedMb, required this.percentUsed});
}