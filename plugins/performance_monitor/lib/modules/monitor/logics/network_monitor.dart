import 'dart:async';

class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;
  NetworkMonitor._internal();

  final Map<String, List<RequestRecord>> _requestMap = {};
  final StreamController<NetworkAlert> _alertController = StreamController<NetworkAlert>.broadcast();

  Stream<NetworkAlert> get alertStream => _alertController.stream;

  // 初始化并注入HTTP客户端
  void initialize() {
    // 拦截dio请求
    _setupDioInterceptor();
    // 拦截http请求
    _setupHttpOverrides();
  }

  void _setupDioInterceptor() {
    // 创建Dio拦截器，添加到应用的Dio实例
  }

  void _setupHttpOverrides() {
    // 重写HttpOverrides以捕获标准http请求
  }

  // 记录请求
  void recordRequest(String url, DateTime startTime) {
    if (!_requestMap.containsKey(url)) {
      _requestMap[url] = [];
    }
    _requestMap[url]!.add(RequestRecord(startTime: startTime));

    // 检测并发请求
    _detectConcurrentRequests(url);
  }

  // 检测并发请求
  void _detectConcurrentRequests(String url) {
    final requests = _requestMap[url]!;

    // 清理旧请求记录
    _cleanupOldRequests(url);

    // 检查短时间内的请求数量
    final recentRequests = requests.where((r) =>
        r.startTime.isAfter(DateTime.now().subtract(const Duration(seconds: 5)))
    ).toList();

    // 如果同一URL在短时间内有多次请求，触发警报
    if (recentRequests.length >= 3) {
      _alertController.add(NetworkAlert(
        url: url,
        requestCount: recentRequests.length,
        timeWindowSeconds: 5,
      ));
    }
  }

  void _cleanupOldRequests(String url) {
    // 移除30秒前的请求记录
    _requestMap[url] = _requestMap[url]!.where((r) =>
        r.startTime.isAfter(DateTime.now().subtract(const Duration(seconds: 30)))
    ).toList();
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