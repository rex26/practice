import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel systemStatsPlatform = MethodChannel('com.example.practice/system_stats');

/// Base class for all performance trackers
abstract class BaseTracker {
  bool _isTracking = false;
  final StreamController<dynamic> _controller =
      StreamController<dynamic>.broadcast();

  /// Stream of tracker data
  Stream<dynamic> get stream => _controller.stream;

  /// Whether the tracker is currently tracking
  bool get isTracking => _isTracking;

  /// Start tracking
  void start() {
    if (_isTracking) return;
    _isTracking = true;
    onStart();
  }

  /// Stop tracking
  void stop() {
    if (!_isTracking) return;
    _isTracking = false;
    onStop();
  }

  /// Dispose the tracker
  void dispose() {
    stop();
    _controller.close();
    onDispose();
  }

  /// Called when tracking starts
  void onStart();

  /// Called when tracking stops
  void onStop();

  /// Called when the tracker is disposed
  void onDispose() {}

  /// Add data to the stream
  void addData(dynamic data) {
    if (!_isTracking) return;
    _controller.add(data);
  }
}
