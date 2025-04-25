// core/utils/background_logger.dart

// Dart imports:
import 'dart:io' show File, Directory, FileMode;
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// A simple file-based logger for background tasks
/// This helps debug WorkManager and other background processes
/// where standard debugPrint or print statements may not be visible
///  coverage:ignore-start
class BackgroundLogger {
  static const String _logFileName = 'background_logs.txt';
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  
  // File IO operation queue untuk memastikan logging thread-safe dan tidak blocking UI
  static final _writeQueue = StreamController<_LogOperation>();
  static bool _queueInitialized = false;
  
  // Max file size 1MB, untuk menjaga performa
  static const int _maxLogFileSizeBytes = 1 * 1024 * 1024; // 1MB
  
  /// Apakah logging diaktifkan (hanya di debug mode)
  static bool get isEnabled => kDebugMode;
  
  /// Inisialisasi background queue untuk file operations
  static void _initQueue() {
    if (!_queueInitialized) {
      _queueInitialized = true;
      _writeQueue.stream.listen((operation) async {
        try {
          await operation.execute();
        } catch (e) {
          // Silent error in background
        }
      });
    }
  }

  /// Log a message to the background log file
  /// Add a tag to identify the source of the log (e.g., 'WORKMANAGER', 'NOTIFICATIONS')
  /// When isTest is true, logging will be skipped to avoid platform dependencies during tests
  /// Logging hanya aktif di debug mode, kecuali untuk testing
  static Future<void> log(String message, {String tag = 'BACKGROUND', bool isTest = false}) async {
    // Skip actual logging in non-debug mode atau jika isTest=true
    if (!kDebugMode || isTest) {
      return Future.value();
    }
    
    try {
      // Pastikan queue initialized
      _initQueue();
      
      // Format message dengan timestamp dan tag
      final timestamp = _dateFormat.format(DateTime.now());
      final formattedMessage = '[$timestamp] [$tag] $message\n';
      
      // Debug print message juga (untuk console)
      debugPrint('BG_LOG: [$tag] $message');
      
      // Non-blocking file write via queue
      _writeQueue.add(_LogOperation(formattedMessage));
    } catch (e) {
      // Can't do much if logging itself fails
      debugPrint('Error writing to background log: $e');
    }
  }

  /// Get all logs as a single string - untuk debug view
  static Future<String> getLogs() async {
    if (!kDebugMode) {
      return 'Logs only available in debug mode';
    }
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      final file = File('${logDir.path}/$_logFileName');

      if (!await file.exists()) {
        return 'No logs found';
      }

      return await file.readAsString();
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

}

/// Kelas internal untuk operasi logging yang diqueue
class _LogOperation {
  final String message;
  
  _LogOperation(this.message);
  
  Future<void> execute() async {
    try {
      // Get app's documents directory
      final directory = await BackgroundLogger._getLogDirectory();
      final file = File('${directory.path}/${BackgroundLogger._logFileName}');

      // Create file if needed
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      // Limit file size menggunakan konstanta
      try {
        if (await file.exists()) {
          final stats = await file.stat();
          if (stats.size > BackgroundLogger._maxLogFileSizeBytes) {
            // Jika terlalu besar, hapus konten lama dan buat header baru
            await file.writeAsString('--- Log truncated at ${DateTime.now()} ---\n', mode: FileMode.write);
          }
        }
      } catch (e) {
        // Silent error
      }

      // Append message
      await file.writeAsString(message, mode: FileMode.append);
    } catch (e) {
      // Silent error - jangan sampai logging mengganggu app
      debugPrint('Error writing to background log: $e');
    }
  }
}

/// coverage:ignore-end
