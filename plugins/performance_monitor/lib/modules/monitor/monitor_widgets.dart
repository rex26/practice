import 'package:flutter/material.dart';
import 'package:performance_monitor/modules/monitor/logics/cpu_monitor.dart';
import 'package:performance_monitor/modules/monitor/logics/memory_monitor.dart';
import 'package:performance_monitor/modules/monitor/logics/network_monitor.dart';

class MonitorOverlay extends StatefulWidget {
  final bool showCpu;
  final bool showMemory;
  final bool showNetwork;

  const MonitorOverlay({
    super.key,
    this.showCpu = true,
    this.showMemory = true,
    this.showNetwork = true,
  });

  @override
  State<MonitorOverlay> createState() => _MonitorOverlayState();
}

class _MonitorOverlayState extends State<MonitorOverlay> {
  Offset _position = const Offset(20, 100);
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: _buildOverlayContent(),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            _position = details.offset;
          });
        },
        child: _buildOverlayContent(),
      ),
    );
  }

  Widget _buildOverlayContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('性能监控', style: TextStyle(color: Colors.white)),
              IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ],
          ),
          if (_isExpanded) ...[
            if (widget.showCpu) _buildCpuIndicator(),
            if (widget.showMemory) _buildMemoryIndicator(),
            if (widget.showNetwork) _buildNetworkIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildCpuIndicator() {
    return StreamBuilder<double>(
      stream: CpuMonitor().cpuUsageStream,
      builder: (context, snapshot) {
        final usage = snapshot.data ?? 0.0;
        return _buildIndicator('CPU', usage, Colors.green);
      },
    );
  }

  Widget _buildMemoryIndicator() {
    return StreamBuilder<MemoryInfo>(
      stream: MemoryMonitor().memoryStream,
      builder: (context, snapshot) {
        final usage = snapshot.data?.percentUsed ?? 0.0;
        return _buildIndicator('内存', usage, Colors.blue);
      },
    );
  }

  Widget _buildNetworkIndicator() {
    return StreamBuilder<NetworkAlert>(
      stream: NetworkMonitor().alertStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final alert = snapshot.data!;
          return Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '警告: ${alert.url} - ${alert.requestCount}次请求在${alert.timeWindowSeconds}秒内',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.only(top: 4),
          child: const Text('网络监控: 正常', style: TextStyle(color: Colors.white, fontSize: 12)),
        );
      },
    );
  }

  Widget _buildIndicator(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${(value * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(color: color),
            ),
          ),
        ],
      ),
    );
  }
}