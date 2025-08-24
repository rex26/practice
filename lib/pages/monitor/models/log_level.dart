/// Log levels for the performance monitor
enum LogLevel {
  /// Verbose logging - includes all logs
  verbose,

  /// Debug logging - includes debug and above
  debug,

  /// Info logging - includes info and above
  info,

  /// Warning logging - includes warnings and errors
  warning,

  /// Error logging - only includes errors
  error,

  /// No logging
  none;

  /// Whether this log level includes another log level
  bool includes(LogLevel other) {
    return index <= other.index;
  }
}
