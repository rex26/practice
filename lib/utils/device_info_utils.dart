import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:practice/config.dart';
import 'package:practice/constants/dimens.dart';

///
/// Description:
/// Author: ArcherHan
/// Date: 2022-03-17 16:18:14
/// LastEditors: ArcherHan
/// LastEditTime: 2022-03-17 16:18:14
///
class DeviceInfoUtils {
  static String getDeviceType(BuildContext context) {
    final MediaQueryData? windowData = _newData(context);
    final double shortestSide = windowData?.size.shortestSide ?? 0;
    return shortestSide <= Dimens.narrowScreenWidthThreshold ? 'phone' : 'tablet';
  }

  static MediaQueryData? _newData(BuildContext context) {
    final MediaQueryData? mq = MediaQuery.maybeOf(context);
    return mq ?? MediaQueryData.fromView(View.of(context));
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == 'tablet';
  }

  static bool isPhone(BuildContext context) {
    return getDeviceType(context) == 'phone';
  }

  static Future<String> getUserAgent() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appName = packageInfo.appName;
    String version = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;
    String deviceModel = 'Unknown';
    String brand = 'Unknown';
    String osVersion = 'Unknown';
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      brand = androidInfo.brand;
      osVersion = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final String suffix = AppConfig.isProd ? '-Prod' : '';
      version = '$version$suffix';
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      brand = 'Apple';
      deviceModel = iosInfo.utsname.machine;
      osVersion = 'iOS ${iosInfo.systemVersion}';
    } else {
      brand = 'Unknown';
      deviceModel = 'Unknown';
      osVersion = 'Unknown';
    }

    return '$appName / $version($buildNumber) / $brand / $deviceModel / $osVersion';
  }

  static Future<AndroidDeviceInfo?> getAndroidInfo() async {
    if (!Platform.isAndroid) return null;
    return DeviceInfoPlugin().androidInfo;
  }
}
