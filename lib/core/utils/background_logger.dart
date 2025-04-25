// core/utils/background_logger.dart

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// A simple file-based logger for background tasks
/// This helps debug WorkManager and other background processes
/// where standard debugPrint or print statements may not be visible
///  coverage:ignore-start
class BackgroundLogger {
  static const String _logFileName = 'background_logs.txt';
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  static bool? _isEnabled;

  /// Check if logging is enabled based on the environment flavor
  static bool get isEnabled {
    if (_isEnabled == null) {
      final flavor = dotenv.env['FLAVOR'] ?? 'dev';
      _isEnabled = flavor.toLowerCase() != 'production' && 
                    flavor.toLowerCase() != 'staging';
    }
    return _isEnabled!;
  }

  /// Set enabled state explicitly (useful for testing or forced override)
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Log a message to the background log file
  /// Add a tag to identify the source of the log (e.g., 'WORKMANAGER', 'NOTIFICATIONS')
  /// When isTest is true, logging will be skipped to avoid platform dependencies during tests
  /// Logging is also skipped in production and staging environments
  static Future<void> log(String message,
      {String tag = 'BACKGROUND', bool isTest = false}) async {
    // Skip actual logging in test mode or if disabled in production/staging
    if (isTest || !isEnabled) {
      return Future.value();
    }
    try {
      final timestamp = _dateFormat.format(DateTime.now());
      final formattedMessage = '[$timestamp] [$tag] $message\n';

      final directory = await _getLogDirectory();
      final file = File('${directory.path}/$_logFileName');

      // Create the file if it doesn't exist
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      // Limit log file size to prevent it from growing too large
      await _limitLogFileSize(file);

      // Append the log message
      await file.writeAsString(formattedMessage, mode: FileMode.append);
    } catch (e) {
      // Can't do much if logging itself fails
      debugPrint('Error writing to background log: $e');
    }
  }

  /// Get all logs as a single string
  static Future<String> getLogs() async {
    try {
      final directory = await _getLogDirectory();
      final file = File('${directory.path}/$_logFileName');

      if (await file.exists()) {
        return await file.readAsString();
      }
      return 'No logs found';
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  /// Check log file status and return information about it
  static Future<Map<String, dynamic>> checkLogFileStatus() async {
    try {
      final directory = await _getLogDirectory();
      final file = File('${directory.path}/$_logFileName');
      final exists = await file.exists();

      final result = <String, dynamic>{
        'exists': exists,
        'path': '${directory.path}/$_logFileName',
        'directory': directory.path,
        'directoryExists': await directory.exists(),
      };

      if (exists) {
        final stat = await file.stat();
        result['size'] = '${(stat.size / 1024).toStringAsFixed(2)} KB';
        result['lastModified'] = stat.modified.toString();

        // Get the first few lines as preview
        try {
          final content = await file.readAsString();
          final lines = content.split('\n');
          result['lineCount'] = lines.length;
          result['preview'] = lines.take(5).join('\n');
        } catch (e) {
          result['readError'] = e.toString();
        }
      }

      return result;
    } catch (e) {
      return {
        'error': e.toString(),
        'exists': false,
      };
    }
  }

  /// Clear all logs
  static Future<void> clearLogs() async {
    try {
      final directory = await _getLogDirectory();
      final file = File('${directory.path}/$_logFileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error clearing logs: $e');
    }
  }

  /// Get the directory for storing logs
  static Future<Directory> _getLogDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDocDir.path}/logs');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    return logDir;
  }

  /// Limit the log file size to prevent it from growing too large
  /// If the file exceeds 1MB, this will keep the most recent 75% of the file
  static Future<void> _limitLogFileSize(File file) async {
    const int maxSizeBytes = 1024 * 1024; // 1 MB

    final stat = await file.stat();
    if (stat.size > maxSizeBytes) {
      final content = await file.readAsString();
      final keepLength = (content.length * 0.75).toInt();
      final newContent = content.substring(content.length - keepLength);

      await file.writeAsString(
          '--- Truncated at ${_dateFormat.format(DateTime.now())} ---\n$newContent',
          mode: FileMode.write);
    }
  }
}

/// coverage:ignore-end
