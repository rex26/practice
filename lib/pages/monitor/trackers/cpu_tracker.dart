import 'dart:async';
import 'dart:math';
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
  final Random _random = Random();
  double _lastUsage = 0;

  @override
  void onStart() {
    _timer = Timer.periodic(const Duration(seconds: 1), _checkCpu);
  }

  @override
  void onStop() {
    _timer?.cancel();
    _timer = null;
  }

  void _checkCpu(Timer timer) {
    final usage = _getCpuUsage();
    final cores = _getCpuCores();

    addData(CpuData(
      usage: usage,
      cores: cores,
    ));
  }

  double _getCpuUsage() {
    // Simulate CPU usage with some randomness but smooth transitions
    const maxChange = 10.0;
    final change = _random.nextDouble() * maxChange * 2 - maxChange;
    _lastUsage = (_lastUsage + change).clamp(0.0, 100.0);
    return _lastUsage;
  }

  int _getCpuCores() {
    // Return a reasonable number of cores for testing
    return 8;
  }
}
