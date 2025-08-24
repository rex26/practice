import 'package:battery_plus/battery_plus.dart';
import 'base_tracker.dart';

/// Data class for battery measurements
class BatteryData {
  /// The current battery level (0-100)
  final int level;

  /// The current battery state
  final BatteryState state;

  /// Whether the device is charging
  bool get isCharging => state == BatteryState.charging;

  /// Creates a new battery data instance
  const BatteryData({required this.level, required this.state});
}

/// Tracks battery status
class BatteryTracker extends BaseTracker {
  final Battery _battery = Battery();
  Stream<BatteryState>? _stateStream;

  @override
  void onStart() {
    _stateStream = _battery.onBatteryStateChanged;
    _stateStream?.listen(_onBatteryStateChanged);

    // Get initial values
    _updateBatteryInfo();
  }

  @override
  void onStop() {
    _stateStream = null;
  }

  Future<void> _updateBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;

    addData(BatteryData(
      level: level,
      state: state,
    ));
  }

  void _onBatteryStateChanged(BatteryState state) {
    _updateBatteryInfo();
  }
}
