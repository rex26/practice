import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:practice/utils/logger.dart';

class APIErrorUtils {
  static const String dataKey = 'dataKey';
  static const String errorsKey = 'errors';
  static const String messageKey = 'message';

  static String? getErrorMessage(dynamic error) {
    if (error is! DioException) {
      return null;
    }

    try {
      if (error.type == DioExceptionType.badResponse) {
        dynamic originData = error.response?.data;
        if (originData is String) {
          originData = jsonDecode(originData);
        }

        final String? errorMessage = originData[dataKey]?[dataKey]?[errorsKey];
        if (errorMessage?.isNotEmpty ?? false) {
          return errorMessage;
        }
        final String? message = originData[messageKey];
        if (message?.isNotEmpty ?? false) {
          return message;
        }
      } else if (error.type == DioExceptionType.unknown && null != error.error && error.error is SocketException) {
        return 'Please Check Your Internet Connection And Try Again';
      }
      return error.message;
    } catch (error, stackTrace) {
      logger.e('getErrorMessage', error: error, stackTrace: stackTrace);
    }

    return null;
  }
}