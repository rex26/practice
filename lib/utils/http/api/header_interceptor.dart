import 'package:dio/dio.dart';
import 'package:practice/constants/app_strings.dart';
import 'package:practice/constants/constants.dart';
import 'package:practice/utils/custom_date_utils.dart';
import 'package:practice/utils/device_info_utils.dart';
import 'package:practice/utils/logger.dart';

///
/// Description:
/// Author: ArcherHan
/// Date: 2021-11-03 14:32:00
/// LastEditors: ArcherHan
/// LastEditTime: 2021-11-03 14:32:00
///

class HeaderInterceptor extends InterceptorsWrapper {
  String? airhostDevSession;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String languageCode = Constants.currentLanguageCode.startsWith('en') ? 'en' : Constants.currentLanguageCode;
    if (languageCode.contains('_')) {
      // the backend can only match -
      languageCode = languageCode.replaceFirst('_', '-');
    }
    options.headers[AppStrings.headerAcceptLanguage] = languageCode;
    options.headers[AppStrings.headerAccept] = 'application/json';
    options.headers[AppStrings.headerUA] = await DeviceInfoUtils.getUserAgent();
    options.headers[AppStrings.headerTimezone] = await CustomDateUtils.getLocalTimezone();

    if (options.headers.containsKey(AppStrings.headerNeedCookie)) {
      if (airhostDevSession?.isNotEmpty ?? false) {
        options.headers['cookie'] = airhostDevSession;
        options.headers.remove(AppStrings.headerNeedCookie);
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.headers.containsKey(AppStrings.headerSetCookie)) {
      try {
        final String? cookieValue = response.headers[AppStrings.headerSetCookie]?.first.split(';').first;
        if (cookieValue != null) {
          airhostDevSession = cookieValue;
        }
      } catch (e) {
        logger.e('Error parsing session cookie', error: e);
      }
    }
    super.onResponse(response, handler);
  }
}
