class PerformanceMonitorConfig {
  final bool monitorCpu;
  final bool monitorMemory;
  final bool monitorNetwork;
  final Duration sampleInterval;
  final int concurrentRequestThreshold;
  final Duration concurrentTimeWindow;

  const PerformanceMonitorConfig({
    this.monitorCpu = true,
    this.monitorMemory = true,
    this.monitorNetwork = true,
    this.sampleInterval = const Duration(seconds: 1),
    this.concurrentRequestThreshold = 3,
    this.concurrentTimeWindow = const Duration(seconds: 5),
  });
}