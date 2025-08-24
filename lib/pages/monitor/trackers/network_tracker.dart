import 'package:dio/dio.dart';
import 'base_tracker.dart';

/// Data class for network request measurements
class NetworkData {
  /// The request URL
  final String url;

  /// The HTTP method used
  final String method;

  /// The response status code
  final int? statusCode;

  /// The time taken for the request in milliseconds
  final int duration;

  /// The size of the response in bytes
  final int responseSize;

  /// Whether the request resulted in an error
  final bool hasError;

  /// The error message if any
  final String? errorMessage;

  /// Creates a new network data instance
  const NetworkData({
    required this.url,
    required this.method,
    this.statusCode,
    required this.duration,
    required this.responseSize,
    required this.hasError,
    this.errorMessage,
  });
}

/// Tracks network requests
class NetworkTracker extends BaseTracker {
  final Dio _dio = Dio();
  final List<NetworkData> _requests = [];

  /// Creates a new network tracker
  NetworkTracker() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// Get the Dio instance for making requests
  Dio get dio => _dio;

  /// Get all tracked requests
  List<NetworkData> get requests => List.unmodifiable(_requests);

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as int;
    final endTime = DateTime.now().millisecondsSinceEpoch;

    final data = NetworkData(
      url: response.requestOptions.uri.toString(),
      method: response.requestOptions.method,
      statusCode: response.statusCode,
      duration: endTime - startTime,
      responseSize: _calculateResponseSize(response.data),
      hasError: false,
    );

    _requests.add(data);
    addData(data);

    handler.next(response);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) {
    final startTime = error.requestOptions.extra['startTime'] as int;
    final endTime = DateTime.now().millisecondsSinceEpoch;

    final data = NetworkData(
      url: error.requestOptions.uri.toString(),
      method: error.requestOptions.method,
      statusCode: error.response?.statusCode,
      duration: endTime - startTime,
      responseSize: error.response != null
          ? _calculateResponseSize(error.response!.data)
          : 0,
      hasError: true,
      errorMessage: error.message,
    );

    _requests.add(data);
    addData(data);

    handler.next(error);
  }

  int _calculateResponseSize(dynamic data) {
    if (data == null) return 0;
    if (data is String) return data.length;
    if (data is List) return data.length;
    if (data is Map) return data.toString().length;
    return data.toString().length;
  }

  @override
  void onStart() {
    // Nothing to do here as tracking is handled by interceptors
  }

  @override
  void onStop() {
    // Nothing to do here as tracking is handled by interceptors
  }

  @override
  void onDispose() {
    _dio.close();
    _requests.clear();
  }
}
