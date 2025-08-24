import 'dart:async';
// import 'package:flutter/foundation.dart';
import 'base_tracker.dart';

/// Data class for memory measurements
class MemoryData {
  /// The current heap usage in bytes
  final int heapUsage;

  /// Whether a garbage collection occurred
  final bool hadGC;

  /// Creates a new memory data instance
  const MemoryData({required this.heapUsage, this.hadGC = false});
}

/// Tracks memory usage and garbage collection
class MemoryTracker extends BaseTracker {
  Timer? _timer;
  int? _lastHeapSize;

  @override
  void onStart() {
    _timer = Timer.periodic(const Duration(seconds: 1), _checkMemory);
  }

  @override
  void onStop() {
    _timer?.cancel();
    _timer = null;
  }

  void _checkMemory(Timer timer) {
    final currentHeap = _getHeapUsage();
    final hadGC = _lastHeapSize != null && currentHeap < _lastHeapSize!;

    addData(MemoryData(
      heapUsage: currentHeap,
      hadGC: hadGC,
    ));

    _lastHeapSize = currentHeap;
  }

  int _getHeapUsage() {
    // This is a simplified version. In a real implementation,
    // you would use platform-specific methods to get accurate memory usage
    return 0;
  }
}
