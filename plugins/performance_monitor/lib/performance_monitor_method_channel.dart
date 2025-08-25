import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'performance_monitor_platform_interface.dart';

/// An implementation of [PerformanceMonitorPlatform] that uses method channels.
class MethodChannelPerformanceMonitor extends PerformanceMonitorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('performance_monitor');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
