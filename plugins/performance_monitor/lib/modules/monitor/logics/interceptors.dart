// Dio拦截器示例
import 'package:dio/dio.dart';
import 'package:performance_monitor/modules/monitor/logics/network_monitor.dart';

class PerformanceInterceptor extends Interceptor {
  final NetworkMonitor _monitor;

  PerformanceInterceptor(this._monitor);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _monitor.recordRequest(options.uri.toString(), DateTime.now());
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 可以在这里记录响应时间等信息
    super.onResponse(response, handler);
  }
}