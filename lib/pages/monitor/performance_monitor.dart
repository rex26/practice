// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:practice/pages/monitor/config/monitor_config.dart';
import 'package:practice/pages/monitor/models/log_level.dart';
import 'package:practice/pages/monitor/trackers/battery_tracker.dart';
import 'package:practice/pages/monitor/trackers/cpu_tracker.dart';
import 'package:practice/pages/monitor/trackers/device_info_tracker.dart';
import 'package:practice/pages/monitor/trackers/disk_tracker.dart';
import 'package:practice/pages/monitor/trackers/fps_tracker.dart';
import 'package:practice/pages/monitor/trackers/memory_tracker.dart';
import 'package:practice/pages/monitor/trackers/network_tracker.dart';

/// The main performance monitoring class
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();

  /// The singleton instance of the performance monitor
  static PerformanceMonitor get instance => _instance;

  late MonitorConfig _config;
  bool _isInitialized = false;

  // Trackers
  late FpsTracker _fpsTracker;
  late MemoryTracker _memoryTracker;
  late CpuTracker _cpuTracker;
  late NetworkTracker _networkTracker;
  late BatteryTracker _batteryTracker;
  late DeviceInfoTracker _deviceInfoTracker;
  late DiskTracker _diskTracker;

  // Stream getters
  Stream<FpsData> get fpsStream => _fpsTracker.stream.cast<FpsData>();
  Stream<CpuData> get cpuStream => _cpuTracker.stream.cast<CpuData>();
  Stream<MemoryData> get memoryStream =>
      _memoryTracker.stream.cast<MemoryData>();
  Stream<NetworkData> get networkStream =>
      _networkTracker.stream.cast<NetworkData>();
  Stream<BatteryData> get batteryStream =>
      _batteryTracker.stream.cast<BatteryData>();
  Stream<DeviceData> get deviceStream =>
      _deviceInfoTracker.stream.cast<DeviceData>();
  Stream<DiskData> get diskStream => _diskTracker.stream.cast<DiskData>();

  PerformanceMonitor._internal();

  /// Initialize the performance monitor with the given configuration
  Future<void> initialize({MonitorConfig? config}) async {
    if (_isInitialized) {
      debugPrint('PerformanceMonitor is already initialized');
      return;
    }

    _config = config ?? const MonitorConfig();
    _isInitialized = true;

    // Initialize trackers
    _initializeTrackers();
    _startTrackers();

    debugPrint('PerformanceMonitor initialized');
  }

  void _initializeTrackers() {
    _memoryTracker = MemoryTracker();
    _fpsTracker = FpsTracker(warningThreshold: _config.fpsWarningThreshold);
    _networkTracker = NetworkTracker();
    _batteryTracker = BatteryTracker();
    _deviceInfoTracker = DeviceInfoTracker();
    _cpuTracker = CpuTracker();
    _diskTracker = DiskTracker();
  }

  void _startTrackers() {
    if (_config.showMemory) {
      _memoryTracker.start();
    }

    _fpsTracker.start();
    _cpuTracker.start();

    if (_config.enableNetworkMonitoring) {
      _networkTracker.start();
    }

    if (_config.enableBatteryMonitoring) {
      _batteryTracker.start();
    }

    if (_config.enableDeviceInfo) {
      _deviceInfoTracker.start();
    }

    if (_config.enableDiskMonitoring) {
      _diskTracker.start();
    }
  }

  /// Get the current configuration
  MonitorConfig get config => _config;

  /// Log a message at the specified level
  void log(String message, {LogLevel level = LogLevel.info}) {
    if (!_config.showLogs || !_config.logLevel.includes(level)) return;

    switch (level) {
      case LogLevel.verbose:
        debugPrint('🔍 VERBOSE: $message');
      case LogLevel.debug:
        debugPrint('🐛 DEBUG: $message');
      case LogLevel.info:
        debugPrint('ℹ️ INFO: $message');
      case LogLevel.warning:
        debugPrint('⚠️ WARNING: $message');
      case LogLevel.error:
        debugPrint('❌ ERROR: $message');
      case LogLevel.none:
        break;
    }
  }

  /// Start tracking app startup time
  void trackStartup() {
    if (!_config.trackStartup) return;
    // Implementation will be added
  }

  /// Dispose the performance monitor and its trackers
  void dispose() {
    _isInitialized = false;
    _memoryTracker.dispose();
    _fpsTracker.dispose();
    _cpuTracker.dispose();
    _networkTracker.dispose();
    _batteryTracker.dispose();
    _deviceInfoTracker.dispose();
    _diskTracker.dispose();
  }
}
