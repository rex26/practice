import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'performance_monitor_method_channel.dart';

abstract class PerformanceMonitorPlatform extends PlatformInterface {
  /// Constructs a PerformanceMonitorPlatform.
  PerformanceMonitorPlatform() : super(token: _token);

  static final Object _token = Object();

  static PerformanceMonitorPlatform _instance = MethodChannelPerformanceMonitor();

  /// The default instance of [PerformanceMonitorPlatform] to use.
  ///
  /// Defaults to [MethodChannelPerformanceMonitor].
  static PerformanceMonitorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PerformanceMonitorPlatform] when
  /// they register themselves.
  static set instance(PerformanceMonitorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
