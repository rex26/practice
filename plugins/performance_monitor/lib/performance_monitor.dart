
import 'package:flutter/material.dart';
import 'package:performance_monitor/modules/monitor/logics/cpu_monitor.dart';
import 'package:performance_monitor/modules/monitor/logics/memory_monitor.dart';
import 'package:performance_monitor/modules/monitor/logics/network_monitor.dart';
import 'package:performance_monitor/modules/monitor/monitor_models.dart';
import 'package:performance_monitor/modules/monitor/monitor_widgets.dart';
import 'package:performance_monitor/modules/monitor/performance_details_page.dart';

import 'performance_monitor_platform_interface.dart';

// 主入口类
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  late CpuMonitor _cpuMonitor;
  late MemoryMonitor _memoryMonitor;
  late NetworkMonitor _networkMonitor;
  bool _isInitialized = false;
  OverlayEntry? _overlayEntry;

  Future<String?> getPlatformVersion() {
    return PerformanceMonitorPlatform.instance.getPlatformVersion();
  }

  // 初始化监控器
  void initialize({
    required BuildContext context,
    PerformanceMonitorConfig config = const PerformanceMonitorConfig(),
  }) {
    if (_isInitialized) return;

    _cpuMonitor = CpuMonitor();
    _memoryMonitor = MemoryMonitor();
    _networkMonitor = NetworkMonitor();

    if (config.monitorCpu) {
      _cpuMonitor.start(interval: config.sampleInterval);
    }

    if (config.monitorMemory) {
      _memoryMonitor.start(interval: config.sampleInterval);
    }

    if (config.monitorNetwork) {
      _networkMonitor.initialize();
    }

    // 添加悬浮窗
    _showOverlay(context, config);

    _isInitialized = true;
  }

  void _showOverlay(BuildContext context, PerformanceMonitorConfig config) {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => MonitorOverlay(
        showCpu: config.monitorCpu,
        showMemory: config.monitorMemory,
        showNetwork: config.monitorNetwork,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  // 显示详情页
  void showDetailsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PerformanceDetailsPage()),
    );
  }

  // 停止并释放资源
  void dispose() {
    _cpuMonitor.dispose();
    _memoryMonitor.dispose();
    _networkMonitor.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isInitialized = false;
  }
}