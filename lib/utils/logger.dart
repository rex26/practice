import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:share_plus/share_plus.dart';

final AHLogger logger = AHLogger();

class AHLogger {
  Talker talker = Talker(
    settings: TalkerSettings(
      maxHistoryItems: 10000,
      timeFormat: TimeFormat.yearMonthDayAndTime,
      useConsoleLogs: true,
      enabled: true,
    ),
  );

  /// Log a message at level [Level.trace].
  void v(dynamic message, {dynamic error, StackTrace? stackTrace, String? tag}) {
    talker.verbose('${tag ?? ''}:$message', error, stackTrace);
  }

  /// Log a message at level [Level.debug].
  void d(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
    bool isSendToFirebase = false,
  }) {
    talker.debug('${tag ?? ''}:$message', error, stackTrace);
  }

  /// Log a message at level [Level.info].
  void i(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
    bool isSendToFirebase = false,
  }) {
    talker.info('${tag ?? ''}:$message', error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
    bool isSendToFirebase = false,
  }) {
    talker.warning('${tag ?? ''}:$message', error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
    bool isSendToFirebase = false,
  }) {
    talker.error('${tag ?? ''}: $message', error, stackTrace);
  }

  /// Log a message at level [Level.fatal].
  void fatal(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
    bool isSendToFirebase = false,
  }) {
    talker.critical('${tag ?? ''}:$message', error, stackTrace);
  }
}

class FileLogManager {
  factory FileLogManager() => _instance;

  FileLogManager._privateConstructor() {
    unawaited(init());
  }

  static const int maxFileSize = 10 * 1024 * 1024;
  static const int maxFileCount = 5;
  static const int batchSize = 50;
  static final FileLogManager _instance = FileLogManager._privateConstructor();
  final Queue<String> _logQueue = Queue<String>();
  late Directory logDirectory;
  String currentLogFile = 'log_1.txt';
  Timer? _logTimer;

  /// Initialize the log directory
  Future<void> init() async {
    if (_logTimer?.isActive ?? false) return;
    logDirectory = await getApplicationDocumentsDirectory();
    _startLogProcessing();
  }

  /// Get the current log file path
  String _getLogFilePath() => '${logDirectory.path}/$currentLogFile';

  /// Start the log processing task
  void _startLogProcessing() {
    _logTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (_logQueue.isNotEmpty) {
        await _processLogQueue();
      }
    });
  }

  /// Stop the log processing task
  void dispose() => _logTimer?.cancel();

  /// Add log message to the queue
  void addLogToQueue(String message) {
    _logQueue.add(message);
  }

  // /Process and write logs from the queue in batches
  Future<void> _processLogQueue() async {
    final File logFile = File(_getLogFilePath());

    if (_logQueue.isNotEmpty) {
      final List<String> batch = <String>[];

      // Collecting a batch of logs
      while (batch.length < batchSize && _logQueue.isNotEmpty) {
        batch.add(_logQueue.removeFirst());
      }

      // Writing batch to log file
      final IOSink sink = logFile.openWrite(mode: FileMode.append);
      for (final String log in batch) {
        sink.writeln(log);
      }
      await sink.close();

      await _checkLogRotation();
    }
  }

  /// Check if log file size exceeds the maximum limit and rotate logs if necessary
  Future<void> _checkLogRotation() async {
    final File logFile = File(_getLogFilePath());

    if (await logFile.exists()) {
      final int fileSize = await logFile.length();

      if (fileSize >= maxFileSize) {
        await _rotateLogs();
      }
    }
  }

  /// Rotate the log files, removing the oldest and shifting other logs
  Future<void> _rotateLogs() async {
    final File oldestLogFile = File('${logDirectory.path}/log_$maxFileCount.txt');
    if (await oldestLogFile.exists()) {
      await oldestLogFile.delete();
    }

    for (int i = maxFileCount - 1; i >= 1; i--) {
      final File oldFile = File('${logDirectory.path}/log_$i.txt');
      final File newFile = File('${logDirectory.path}/log_${i + 1}.txt');

      if (await oldFile.exists()) {
        await oldFile.rename(newFile.path);
      }
    }

    currentLogFile = 'log_1.txt';
  }

  /// Method to retrieve all non-empty log files
  Future<List<File>> _getNonEmptyLogFiles() async {
    final List<File> nonEmptyFiles = <File>[];

    for (int i = 1; i <= maxFileCount; i++) {
      final File logFile = File('${logDirectory.path}/log_$i.txt');
      if (await logFile.exists()) {
        final int fileSize = await logFile.length();
        if (fileSize > 0) {
          nonEmptyFiles.add(logFile);
        }
      }
    }

    return nonEmptyFiles;
  }

  /// Share all non-empty log files using share_plus
  Future<void> shareLogs() async {
    final List<File> nonEmptyFiles = await _getNonEmptyLogFiles();
    if (nonEmptyFiles.isNotEmpty) {
      final List<XFile> filePaths = nonEmptyFiles.map((File file) {
        return XFile(file.path);
      }).toList();
      await Share.shareXFiles(filePaths, text: 'Here are the log files.');
    }
  }
}
