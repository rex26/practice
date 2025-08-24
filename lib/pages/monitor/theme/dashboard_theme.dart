import 'package:flutter/material.dart';

/// Theme configuration for the performance dashboard
class DashboardTheme {
  /// The background color of the dashboard
  final Color backgroundColor;

  /// The text color for normal text
  final Color textColor;

  /// The text color for warning messages
  final Color warningColor;

  /// The text color for error messages
  final Color errorColor;

  /// The color for chart lines
  final Color chartLineColor;

  /// The color for chart fills
  final Color chartFillColor;

  /// Creates a new dashboard theme
  const DashboardTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.warningColor,
    required this.errorColor,
    required this.chartLineColor,
    required this.chartFillColor,
  });

  /// Creates a dark theme
  factory DashboardTheme.dark() {
    return const DashboardTheme(
      backgroundColor: Color(0xFF1E1E1E),
      textColor: Colors.white,
      warningColor: Colors.orange,
      errorColor: Colors.red,
      chartLineColor: Colors.blue,
      chartFillColor: Color(0x40808080),
    );
  }

  /// Creates a light theme
  factory DashboardTheme.light() {
    return const DashboardTheme(
      backgroundColor: Colors.white,
      textColor: Colors.black,
      warningColor: Colors.orange,
      errorColor: Colors.red,
      chartLineColor: Colors.blue,
      chartFillColor: Color(0x40808080),
    );
  }

  /// Creates a copy of this theme with the given fields replaced
  DashboardTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? warningColor,
    Color? errorColor,
    Color? chartLineColor,
    Color? chartFillColor,
  }) {
    return DashboardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      chartLineColor: chartLineColor ?? this.chartLineColor,
      chartFillColor: chartFillColor ?? this.chartFillColor,
    );
  }
}
