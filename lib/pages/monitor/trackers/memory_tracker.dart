import 'dart:async';

// import 'package:flutter/foundation.dart';
import 'base_tracker.dart';

/// Data class for memory measurements
class MemoryData {
  /// The current CPU usage percentage (0-100)
  final double usage;

  /// The current heap usage in bytes
  final int heapUsage;

  /// Whether a garbage collection occurred
  final bool hadGC;

  /// Creates a new memory data instance
  const MemoryData(this.usage, {this.heapUsage = 0, this.hadGC = false});
}

/// Tracks memory usage and garbage collection
class MemoryTracker extends BaseTracker {
  Timer? _timer;

  @override
  void onStart() {
    _timer = Timer.periodic(const Duration(seconds: 1), _checkMemory);
  }

  @override
  void onStop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkMemory(Timer timer) async {
    final double usage = await systemStatsPlatform.invokeMethod<double>('getMemoryUsage') ?? 0;

    addData(MemoryData(usage));
  }
}
