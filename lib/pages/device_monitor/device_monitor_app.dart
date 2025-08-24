import 'package:flutter/material.dart';
import 'package:practice/pages/device_monitor/device_monitor_page.dart';

class DeviceMonitorApp extends StatelessWidget {
  const DeviceMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '设备性能监控',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DeviceMonitorPage(),
    );
  }
}

void deviceMonitorMain() {
  runApp(const DeviceMonitorApp());
}
