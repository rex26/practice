import 'dart:async';

import 'base_tracker.dart';

/// Data class for CPU measurements
class CpuData {
  /// The current CPU usage percentage (0-100)
  final double usage;

  /// The number of cores
  final int cores;

  /// Creates a new CPU data instance
  const CpuData({required this.usage, required this.cores});
}

/// Tracks CPU usage
class CpuTracker extends BaseTracker {
  Timer? _timer;

  @override
  void onStart() {
    _timer = Timer.periodic(const Duration(seconds: 1), _checkCpu);
  }

  @override
  void onStop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkCpu(Timer timer) async {
    final double usage = await systemStatsPlatform.invokeMethod<double>('getCpuUsage') ?? 0;
    final int cores = _getCpuCores();

    addData(CpuData(
      usage: usage,
      cores: cores,
    ));
  }

  int _getCpuCores() {
    // Return a reasonable number of cores for testing
    return 8;
  }
}
