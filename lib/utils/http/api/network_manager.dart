import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:practice/config.dart';
import 'package:practice/utils/http/api/header_interceptor.dart';
import 'package:practice/utils/http/model/api_response.dart';
import 'package:practice/utils/logger.dart';
import 'package:practice/utils/toast_util.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

enum HttpMethod {
  get,
  post,
  delete,
  patch,
}

enum CachePolicy {
  noCache,       // Do not use cache
  cacheOnly,     // Only read the cache, do not use the network
  cacheFirst,    // First, try to read the cache. If the cache is not available, load it from the network
  networkFirst,  // Firstly, attempt to load from the network. If the network request fails, read the cache
}

const Duration duration = Duration(seconds: 30);

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._();
  static bool? isConnected;

  late final Dio _dio;

  List<ConnectivityResult> _connectionStatus = <ConnectivityResult>[ConnectivityResult.none];

  static NetworkManager get instance => _instance;

  static bool get isNotConnected =>
      _instance._connectionStatus.contains(ConnectivityResult.none);

  get dio => _dio;

  NetworkManager._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseURL,
      connectTimeout: duration,
      sendTimeout: duration,
      receiveTimeout: duration,
    ));
    _initInterceptors();
    _initAdapter();
    _initConnectivity();
  }

  static Future<ApiResponse> request<T>({
    required String url,
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    CachePolicy? cachePolicy,
    Duration? cacheExpiration,
    bool showTopSnackOnError = true,
    bool catchExceptions = true,
    CancelToken? cancelToken,
  }) async {
    final Dio dio = instance._dio;
    if (cachePolicy != null) {
      headers ??= <String, dynamic>{};
      headers['cache_policy'] = cachePolicy;
      if (cacheExpiration != null) {
        headers['cache_expiration'] = cacheExpiration.inMilliseconds.toString();
      }
    }
    try {
      final Response<dynamic> response = await dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method.name,
          headers: headers,
          extra: extra,
        ),
        cancelToken: cancelToken,
      );
      return ApiResponse(success: true, data: response.data);
    } on DioException catch (e) {
      if (catchExceptions) {
        return handleError(exception: e, showTopSnackOnError: showTopSnackOnError);
      } else {
        rethrow;
      }
    }
  }

  static Future<Response<dynamic>> fetch(RequestOptions options) {
    return _instance._dio.fetch(options);
  }

  static ApiResponse handleError({
    required DioException exception,
    bool showTopSnackOnError = true,
  }) {
    logger.e('${exception.requestOptions.method} URL:${exception.requestOptions.uri}', error: exception);
    if (exception.response != null && exception.response?.data != null) {
      dynamic originData = exception.response?.data;
      if (originData is String) originData = jsonDecode(originData);
      if (showTopSnackOnError && originData is Map<String, dynamic> && originData['success'] != true) {
        final int? statusCode = exception.response?.statusCode;
        final String? errorType = originData['error'];
        final bool subscriptionNotBilledYet = statusCode == 422 && errorType == 'one_subscription.resource_has_not_billed_yet';
        if (!subscriptionNotBilledYet) {
          showToast('${originData['error_description'] ?? originData['message'] ?? exception.message}');
        }
      }
      return ApiResponse.fromJson(exception.response?.data);
    }

    String? errorMsg;
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMsg = 'i10n.T.current.networkConnectionTimedOut';
        break;
      case DioExceptionType.cancel:
        logger.d('Request has been cancelled!');
        break;
      case DioExceptionType.badCertificate:
        errorMsg = 'i10n.T.current.networkCertificateIsInvalid';
        break;
      case DioExceptionType.connectionError:
        errorMsg = 'i10n.T.current.networkConnectionError';
        break;
      case DioExceptionType.badResponse:
        errorMsg = 'i10n.T.current.networkResponseError';
        break;
      default:
        errorMsg = 'i10n.T.current.networkRequestError';
        break;
    }
    if ((errorMsg?.isNotEmpty ?? false) && showTopSnackOnError) {
      showToast(errorMsg);
    }
    return ApiResponse(
      success: false,
      message: errorMsg,
    );
  }

  static bool validateResponse(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 200 && statusCode < 300;
  }

  void _initInterceptors() {
    _dio.interceptors.add(HeaderInterceptor());
    if (!AppConfig.isProd) {
      const bool isOpen = true;
      _dio.interceptors.add(TalkerDioLogger(
        talker: logger.talker,
        settings: TalkerDioLoggerSettings(
          printRequestData: isOpen,
          printRequestHeaders: isOpen,
          printResponseData: isOpen,
          printResponseHeaders: isOpen,
          printResponseMessage: true,
          printErrorData: isOpen,
          printErrorHeaders: isOpen,
          printErrorMessage: isOpen,
          requestFilter: (RequestOptions requestOptions) => isOpen,
          responseFilter: (Response<dynamic> response) => isOpen,
        ),
      ));
    }
  }

  void _initAdapter() {
    if (AppConfig.proxyIP?.isEmpty ?? true) return;
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final HttpClient client = HttpClient()
          ..findProxy = (Uri uri) {
            return 'PROXY ${AppConfig.proxyIP}:8888';
          }
          ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _connectionStatus = result;
    });
  }
}