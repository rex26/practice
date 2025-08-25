import 'package:flutter_test/flutter_test.dart';
import 'package:performance_monitor/performance_monitor.dart';
import 'package:performance_monitor/performance_monitor_platform_interface.dart';
import 'package:performance_monitor/performance_monitor_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPerformanceMonitorPlatform
    with MockPlatformInterfaceMixin
    implements PerformanceMonitorPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PerformanceMonitorPlatform initialPlatform = PerformanceMonitorPlatform.instance;

  test('$MethodChannelPerformanceMonitor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPerformanceMonitor>());
  });

  test('getPlatformVersion', () async {
    PerformanceMonitor performanceMonitorPlugin = PerformanceMonitor();
    MockPerformanceMonitorPlatform fakePlatform = MockPerformanceMonitorPlatform();
    PerformanceMonitorPlatform.instance = fakePlatform;

    expect(await performanceMonitorPlugin.getPlatformVersion(), '42');
  });
}
