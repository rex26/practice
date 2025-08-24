
import 'package:practice/pages/monitor/models/log_level.dart';

/// Configuration class for the Performance Monitor
class MonitorConfig {
  /// Whether to show memory usage tracking
  final bool showMemory;

  /// Whether to show logs
  final bool showLogs;

  /// Whether to track app startup time
  final bool trackStartup;

  /// Whether to intercept network requests
  final bool interceptNetwork;

  /// FPS threshold below which a warning is triggered
  final int fpsWarningThreshold;

  /// Memory threshold (in bytes) above which a warning is triggered
  final int memoryWarningThreshold;

  /// Whether to enable network monitoring
  final bool enableNetworkMonitoring;

  /// Whether to enable battery monitoring
  final bool enableBatteryMonitoring;

  /// Whether to enable device info collection
  final bool enableDeviceInfo;

  /// Log level for the monitor
  final LogLevel logLevel;

  /// Whether to export logs
  final bool exportLogs;

  /// Whether to enable disk usage monitoring
  final bool enableDiskMonitoring;

  /// Disk usage warning threshold (percentage)
  final double diskWarningThreshold;

  /// Creates a new monitor configuration
  const MonitorConfig({
    this.showMemory = true,
    this.showLogs = true,
    this.trackStartup = true,
    this.interceptNetwork = true,
    this.fpsWarningThreshold = 45,
    this.memoryWarningThreshold = 500 * 1024 * 1024, // 500MB
    this.enableNetworkMonitoring = true,
    this.enableBatteryMonitoring = true,
    this.enableDeviceInfo = true,
    this.logLevel = LogLevel.info,
    this.exportLogs = false,
    this.enableDiskMonitoring = true,
    this.diskWarningThreshold = 90.0, // Warn at 90% usage
  });

  /// Creates a copy of this configuration with the given fields replaced
  MonitorConfig copyWith({
    bool? showMemory,
    bool? showLogs,
    bool? trackStartup,
    bool? interceptNetwork,
    int? fpsWarningThreshold,
    int? memoryWarningThreshold,
    bool? enableNetworkMonitoring,
    bool? enableBatteryMonitoring,
    bool? enableDeviceInfo,
    LogLevel? logLevel,
    bool? exportLogs,
    bool? enableDiskMonitoring,
    double? diskWarningThreshold,
  }) {
    return MonitorConfig(
      showMemory: showMemory ?? this.showMemory,
      showLogs: showLogs ?? this.showLogs,
      trackStartup: trackStartup ?? this.trackStartup,
      interceptNetwork: interceptNetwork ?? this.interceptNetwork,
      fpsWarningThreshold: fpsWarningThreshold ?? this.fpsWarningThreshold,
      memoryWarningThreshold:
          memoryWarningThreshold ?? this.memoryWarningThreshold,
      enableNetworkMonitoring:
          enableNetworkMonitoring ?? this.enableNetworkMonitoring,
      enableBatteryMonitoring:
          enableBatteryMonitoring ?? this.enableBatteryMonitoring,
      enableDeviceInfo: enableDeviceInfo ?? this.enableDeviceInfo,
      logLevel: logLevel ?? this.logLevel,
      exportLogs: exportLogs ?? this.exportLogs,
      enableDiskMonitoring: enableDiskMonitoring ?? this.enableDiskMonitoring,
      diskWarningThreshold: diskWarningThreshold ?? this.diskWarningThreshold,
    );
  }
}
