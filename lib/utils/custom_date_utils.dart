import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:practice/utils/logger.dart';

class CustomDateUtils {
  static const String paramFormat = 'yyyy-MM-dd';
  static const String paramTimeFormat = 'yyyy/MM/dd';
  static const String paramTimeFormatH = 'yyyy/MM/dd HH';
  static const String paramTimeFormatHMS = 'yyyy/MM/dd HH:mm:ss';
  static const String formatDMHMS = 'MM-dd HH:mm';
  static const String formatHMS = 'HH:mm:ss';
  static const int oneDay = 24 * 60 * 60 * 1000;
  static Future<String?> getLocalTimezone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } catch (e, s) {
      logger.e('Could not get the local timezone', error: e, stackTrace: s);
    }
    return null;
  }
}