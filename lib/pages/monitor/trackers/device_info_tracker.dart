import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'base_tracker.dart';

/// Data class for device information
class DeviceData {
  /// The device model
  final String model;

  /// The operating system
  final String os;

  /// The OS version
  final String osVersion;

  /// The device manufacturer
  final String manufacturer;

  /// The amount of RAM in bytes
  final int? ramSize;

  /// Creates a new device data instance
  const DeviceData({
    required this.model,
    required this.os,
    required this.osVersion,
    required this.manufacturer,
    this.ramSize,
  });
}

/// Tracks device information
class DeviceInfoTracker extends BaseTracker {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  void onStart() {
    _getDeviceInfo();
  }

  @override
  void onStop() {
    // Nothing to do here as this is a one-time collection
  }

  Future<void> _getDeviceInfo() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      addData(DeviceData(
        model: info.model,
        os: 'Android',
        osVersion: info.version.release,
        manufacturer: info.manufacturer,
        // RAM size not available through device_info_plus on Android
      ));
    } else if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      addData(DeviceData(
        model: info.model,
        os: 'iOS',
        osVersion: info.systemVersion,
        manufacturer: 'Apple',
        // iOS doesn't provide RAM info
      ));
    } else if (Platform.isMacOS) {
      final info = await _deviceInfo.macOsInfo;
      addData(DeviceData(
        model: info.model,
        os: 'macOS',
        osVersion: info.osRelease,
        manufacturer: 'Apple',
      ));
    } else if (Platform.isWindows) {
      final info = await _deviceInfo.windowsInfo;
      addData(DeviceData(
        model: info.computerName,
        os: 'Windows',
        osVersion:
            '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
        manufacturer: 'Unknown',
      ));
    } else if (Platform.isLinux) {
      final info = await _deviceInfo.linuxInfo;
      addData(DeviceData(
        model: info.prettyName,
        os: 'Linux',
        osVersion: info.version ?? 'Unknown',
        manufacturer: 'Unknown',
      ));
    } else {
      addData(const DeviceData(
        model: 'Unknown',
        os: 'Unknown',
        osVersion: 'Unknown',
        manufacturer: 'Unknown',
      ));
    }
  }
}
