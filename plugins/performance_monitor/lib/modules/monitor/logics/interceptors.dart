// Dio interceptor example
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
    // Response time and other information can be recorded here
    super.onResponse(response, handler);
  }
}