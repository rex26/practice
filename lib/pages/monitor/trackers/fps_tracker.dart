import 'package:flutter/scheduler.dart';
import 'base_tracker.dart';

/// Data class for FPS measurements
class FpsData {
  /// The current FPS value
  final double fps;

  /// Whether this FPS value is below the warning threshold
  final bool isWarning;

  /// Creates a new FPS data instance
  const FpsData({required this.fps, required this.isWarning});
}

/// Tracks frames per second (FPS)
class FpsTracker extends BaseTracker {
  final int _warningThreshold;
  Ticker? _ticker;
  int _frames = 0;
  late DateTime _lastSecond;

  /// Creates a new FPS tracker
  FpsTracker({int warningThreshold = 45})
      : _warningThreshold = warningThreshold;

  @override
  void onStart() {
    _lastSecond = DateTime.now();
    _ticker = Ticker(_onTick)..start();
  }

  @override
  void onStop() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void _onTick(Duration elapsed) {
    _frames++;

    final now = DateTime.now();
    if (now.difference(_lastSecond).inMilliseconds >= 1000) {
      final fps = _frames.toDouble();
      addData(FpsData(
        fps: fps,
        isWarning: fps < _warningThreshold,
      ));

      _frames = 0;
      _lastSecond = now;
    }
  }
}
