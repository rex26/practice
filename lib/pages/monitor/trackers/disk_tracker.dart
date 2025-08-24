import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'base_tracker.dart';

/// Data class for disk usage measurements
class DiskData {
  /// Total storage space in bytes
  final int totalSpace;

  /// Free storage space in bytes
  final int freeSpace;

  /// Used storage space in bytes
  final int usedSpace;

  /// App storage usage in bytes
  final int appStorage;

  /// Creates a new disk data instance
  const DiskData({
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
    required this.appStorage,
  });

  /// Gets the percentage of used storage
  double get usagePercentage => (usedSpace / totalSpace) * 100;
}

/// Tracks disk usage and storage metrics
class DiskTracker extends BaseTracker {
  Timer? _timer;

  @override
  void onStart() {
    _timer = Timer.periodic(const Duration(seconds: 5), _checkDiskUsage);
    // Initial check
    _checkDiskUsage(null);
  }

  @override
  void onStop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkDiskUsage(Timer? timer) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final appDirStats = await appDir.stat();

      // Get storage metrics (this is a simplified version)
      // In a real implementation, you would use platform-specific methods
      // to get accurate storage information
      const totalSpace = 64 * 1024 * 1024 * 1024; // 64 GB
      const usedSpace = totalSpace ~/ 2; // Simulated 50% usage
      const freeSpace = totalSpace - usedSpace;

      addData(DiskData(
        totalSpace: totalSpace,
        freeSpace: freeSpace,
        usedSpace: usedSpace,
        appStorage: appDirStats.size,
      ));
    } catch (e) {
      // Handle error
      // print('Error getting disk usage: $e');
    }
  }
}
