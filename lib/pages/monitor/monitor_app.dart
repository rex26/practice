
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:practice/pages/monitor/config/monitor_config.dart';
import 'package:practice/pages/monitor/performance_monitor.dart';
import 'package:practice/pages/monitor/theme/dashboard_theme.dart';
import 'package:practice/pages/monitor/trackers/base_tracker.dart';
import 'dart:io';

import 'package:practice/pages/monitor/widgets/monitor_widget.dart';

void monitorMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the performance monitor
  await PerformanceMonitor.instance.initialize(
    config: const MonitorConfig(
      showMemory: true,
      showLogs: true,
      trackStartup: true,
      interceptNetwork: true,
      fpsWarningThreshold: 45,
      enableNetworkMonitoring: true,
      enableBatteryMonitoring: true,
      enableDeviceInfo: true,
      enableDiskMonitoring: true,
      diskWarningThreshold: 85.0, // Warn at 85% disk usage
    ),
  );

  runApp(const MonitorApp());
}

class MonitorApp extends StatelessWidget {
  const MonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Performance Pulse Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const Positioned(
              right: 16,
              bottom: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: MonitorWidget(
                  theme: DashboardTheme(
                    backgroundColor: Color(0xFF1E1E1E),
                    textColor: Colors.white,
                    warningColor: Colors.orange,
                    errorColor: Colors.red,
                    chartLineColor: Colors.blue,
                    chartFillColor: Color(0x40808080),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Dio _dio = Dio();
  bool _isLoading = false;
  String _diskStatus = '';

  // Simulate heavy computation
  void _performHeavyTask() {
    setState(() => _isLoading = true);

    // Create a large list and sort it
    final list = List.generate(1000000, (i) => 1000000 - i);
    list.sort();

    setState(() => _isLoading = false);
  }

  // Make a network request
  Future<void> _makeNetworkRequest() async {
    try {
      await _dio.get('https://jsonplaceholder.typicode.com/posts');
    } catch (e) {
      debugPrint('Network error: $e');
    }
  }

  // Test disk operations
  Future<void> _testDiskOperations() async {
    setState(() => _isLoading = true);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final testFile = File('${appDir.path}/test_file.txt');

      // Generate a large string
      final largeString =
      List.generate(1024 * 1024, (i) => 'A').join(); // 1MB string

      // Write to file
      await testFile.writeAsString(largeString);

      // Read file stats
      final fileStats = await testFile.stat();
      setState(() {
        _diskStatus =
        'File size: ${(fileStats.size / 1024).toStringAsFixed(2)} KB';
      });

      // Clean up
      await testFile.delete();
    } catch (e) {
      setState(() {
        _diskStatus = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 性能数据
  double _cpuUsage = 0.0;
  double _memoryUsage = 0.0;
  Timer? _timer;

  // 开始周期性监控
  void _startMonitoring() {
    // 立即执行一次
    _updatePerformanceData();

    // 每秒更新一次数据
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePerformanceData();
    });
  }

  // 更新性能数据
  Future<void> _updatePerformanceData() async {
    try {
      // 调用平台特定代码获取CPU和内存使用率
      final cpuUsage = await systemStatsPlatform.invokeMethod<double>('getCpuUsage');
      final memoryUsage = await systemStatsPlatform.invokeMethod('getMemoryUsage');

      if (mounted) {
        setState(() {
          if (cpuUsage != null) {
            _cpuUsage = cpuUsage;
          }

          if (memoryUsage != null) {
            // 解决类型转换问题
            _memoryUsage = memoryUsage;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('获取性能数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Performance Pulse Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _performHeavyTask,
                child: const Text('Perform Heavy Task'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makeNetworkRequest,
              child: const Text('Make Network Request'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testDiskOperations,
              child: const Text('Test Disk Operations'),
            ),
            if (_diskStatus.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_diskStatus),
            ],

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildCpuCard(),
                  const SizedBox(height: 20),
                  _buildMemoryCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCpuCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CPU使用率',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            LinearProgressIndicator(
              value: _cpuUsage,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getCpuColor(_cpuUsage * 100),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_cpuUsage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '内存使用率',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            LinearProgressIndicator(
              value: _memoryUsage,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getMemoryColor(_memoryUsage),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_memoryUsage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 根据CPU使用率返回对应的颜色
  Color _getCpuColor(double usage) {
    if (usage < 50) {
      return Colors.green;
    } else if (usage < 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // 根据内存使用率返回对应的颜色
  Color _getMemoryColor(double usage) {
    if (usage < 0.5) {
      return Colors.green;
    } else if (usage < 0.8) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}