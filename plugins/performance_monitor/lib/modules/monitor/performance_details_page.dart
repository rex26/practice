import 'package:flutter/material.dart';

class PerformanceDetailsPage extends StatefulWidget {
  const PerformanceDetailsPage({super.key});

  @override
  State<PerformanceDetailsPage> createState() => _PerformanceDetailsPageState();
}

class _PerformanceDetailsPageState extends State<PerformanceDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('性能监控详情'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'CPU'),
            Tab(text: '内存'),
            Tab(text: '网络'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCpuTab(),
          _buildMemoryTab(),
          _buildNetworkTab(),
        ],
      ),
    );
  }

  Widget _buildCpuTab() {
    // 展示CPU使用率历史图表和详情
    return const Center(child: Text('CPU监控详情'));
  }

  Widget _buildMemoryTab() {
    // 展示内存使用率历史图表和详情
    return const Center(child: Text('内存监控详情'));
  }

  Widget _buildNetworkTab() {
    // 展示网络请求历史和并发警告详情
    return const Center(child: Text('网络监控详情'));
  }
}