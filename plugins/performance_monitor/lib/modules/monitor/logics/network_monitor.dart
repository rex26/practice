import 'dart:async';

import 'package:dio/dio.dart';
import 'package:performance_monitor/modules/monitor/logics/interceptors.dart';

class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;
  NetworkMonitor._internal();

  final Map<String, List<RequestRecord>> _requestMap = {};
  final StreamController<NetworkAlert> _alertController = StreamController<NetworkAlert>.broadcast();

  Stream<NetworkAlert> get alertStream => _alertController.stream;

  /// We need to store the interceptor for external access
  late final PerformanceInterceptor dioInterceptor;

  /// Initialize monitoring
  void initialize(Dio dio) {
    // Create a Dio interceptor for injection into the app's Dio instances
    dioInterceptor = PerformanceInterceptor(this);
    dio.interceptors.add(dioInterceptor);
  }

  /// Record a request
  void recordRequest(String url, DateTime startTime) {
    if (!_requestMap.containsKey(url)) {
      _requestMap[url] = [];
    }
    _requestMap[url]?.add(RequestRecord(startTime: startTime));

    // Detect concurrent requests
    _detectConcurrentRequests(url);
  }

  /// Detect concurrent requests
  void _detectConcurrentRequests(String url) {
    final List<RequestRecord>? requests = _requestMap[url];

    // Clean up old request records
    _cleanupOldRequests(url);

    // Check the number of requests within a short time period
    final List<RequestRecord> recentRequests = requests?.where((r) {
      return r.startTime.isAfter(DateTime.now().subtract(const Duration(seconds: 5)));
    }).toList() ?? [];

    // If there are multiple requests to the same URL in a short time, trigger an alert
    if (recentRequests.length >= 3) {
      _alertController.add(NetworkAlert(
        url: url,
        requestCount: recentRequests.length,
        timeWindowSeconds: 5,
      ));
    }
  }

  void _cleanupOldRequests(String url) {
    // Remove request records from more than 30 seconds ago
    _requestMap[url] = _requestMap[url]?.where((r) {
      return r.startTime.isAfter(DateTime.now().subtract(const Duration(seconds: 30)));
    }).toList() ?? [];
  }

  void dispose() {
    _alertController.close();
  }
}

class RequestRecord {
  final DateTime startTime;

  RequestRecord({required this.startTime});
}

class NetworkAlert {
  final String url;
  final int requestCount;
  final int timeWindowSeconds;

  NetworkAlert({
    required this.url,
    required this.requestCount,
    required this.timeWindowSeconds,
  });
}