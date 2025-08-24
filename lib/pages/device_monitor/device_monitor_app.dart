import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:practice/pages/device_monitor/device_monitor_page.dart';
import 'package:practice/utils/navigator_util.dart';

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
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[
        BotToastNavigatorObserver(),
        NavigationHistoryObserver.singleInstance,
      ],
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 2),
          ),
          child: BotToastInit().call(context, child),
        );
      },
    );
  }
}

void deviceMonitorMain() {
  runApp(const DeviceMonitorApp());
}
