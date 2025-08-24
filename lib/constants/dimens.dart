import 'dart:math';

import 'package:flutter/material.dart';

class Dimens {
  Dimens._();

  static const double mediumWidthBreakpoint = 1000;
  static const double narrowScreenWidthThreshold = 450;
  static const double largeWidthBreakpoint = 1500;
  static const double transitionLength = 500;

  static bool isSmallWidth(BuildContext context) {
    return MediaQuery.of(context).size.width < narrowScreenWidthThreshold;
  }

  static double responsiveSize(BuildContext context, double smallSize, double largeSize) {
    return isSmallWidth(context) ? smallSize : largeSize;
  }

  static double small(BuildContext context) => responsiveSize(context, 4, 8);
  static double medium(BuildContext context) => responsiveSize(context, 8, 16);
  static double large(BuildContext context) => responsiveSize(context, 16, 32);

  static double scaleSize(BuildContext context, double size, [double? maxScaleFactor]) {
    // Get the current text scaling factor
    final double scaledSize = MediaQuery.of(context).textScaler.scale(size);

    // Calculate the maximum allowable size
    final double maxSize = (maxScaleFactor ?? 1.6) * size;

    // Return the scaling size that does not exceed the maximum size
    return min(scaledSize, maxSize);
  }
}

class Insets {
  static EdgeInsets responsiveInsets(BuildContext context, double smallSize, double largeSize) {
    final double size = Dimens.responsiveSize(context, smallSize, largeSize);
    return EdgeInsets.all(size);
  }

  static EdgeInsets small(BuildContext context) => responsiveInsets(context, 4, 8);
  static EdgeInsets medium(BuildContext context) => responsiveInsets(context, 8, 16);
  static EdgeInsets large(BuildContext context) => responsiveInsets(context, 16, 32);
}
