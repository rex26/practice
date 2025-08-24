// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:practice/pages/monitor/performance_monitor.dart';
import 'package:practice/pages/monitor/theme/dashboard_theme.dart';
import 'package:practice/pages/monitor/trackers/memory_tracker.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

/// A widget that displays performance metrics
class MonitorWidget extends StatefulWidget {

  /// The theme for the dashboard
  final DashboardTheme theme;

  /// Creates a new performance dashboard
  const MonitorWidget({
    super.key,
    this.theme = const DashboardTheme(
      backgroundColor: Color(0xFF1E1E1E),
      textColor: Colors.white,
      warningColor: Colors.orange,
      errorColor: Colors.red,
      chartLineColor: Colors.blue,
      chartFillColor: Color(0x40808080),
    ),
  });

  @override
  State<MonitorWidget> createState() => _MonitorWidgetState();
}

class _MonitorWidgetState extends State<MonitorWidget> {
  final List<FlSpot> _cpuData = [const FlSpot(0, 0)];
  final List<FlSpot> _memoryData = [const FlSpot(0, 0)];
  double _currentCpu = 0;
  double _currentMemory = 0;
  static const int _maxDataPoints = 30;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    PerformanceMonitor.instance.cpuStream.listen((data) {
      if (!mounted) return;
      setState(() {
        _currentCpu = data.usage;
        _addDataPoint(_cpuData, data.usage);
      });
    });

    PerformanceMonitor.instance.memoryStream.listen((MemoryData data) {
      if (!mounted) return;
      setState(() {
        _currentMemory = data.usage;
        _addDataPoint(_memoryData, data.usage);
      });
    });
  }

  void _addDataPoint(List<FlSpot> dataList, double value) {
    if (dataList.length >= _maxDataPoints) {
      dataList.removeAt(0);
      for (int i = 0; i < dataList.length; i++) {
        dataList[i] = FlSpot(i.toDouble(), dataList[i].y);
      }
    }
    dataList.add(FlSpot(dataList.length.toDouble(), value));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildDataWidgets('CPU', _currentCpu * 100, _cpuData),
          ..._buildDataWidgets('Memory', _currentMemory * 100, _memoryData),
        ],
      ),
    );
  }

  List<Widget> _buildDataWidgets(String title, double currentData, List<FlSpot> data) {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.memory,
            color: currentData > 80
                ? widget.theme.warningColor
                : widget.theme.textColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$title: ${currentData.toStringAsFixed(1)}%',
            style: TextStyle(
              color: currentData > 80
                  ? widget.theme.warningColor
                  : widget.theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      _buildDataChart(data),
    ];
  }


  Widget _buildDataChart(List<FlSpot> data) {
    return SizedBox(
      width: 160,
      height: 40,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              color: widget.theme.chartLineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: widget.theme.chartFillColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
