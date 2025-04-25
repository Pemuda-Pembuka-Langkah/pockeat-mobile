// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/core/utils/background_logger.dart';

// coverage:ignore-start

/// A debug screen to view background task logs
class DebugLogsScreen extends StatefulWidget {
  const DebugLogsScreen({super.key});

  @override
  _DebugLogsScreenState createState() => _DebugLogsScreenState();
}

class _DebugLogsScreenState extends State<DebugLogsScreen> {
  String _logs = 'Loading logs...';
  Map<String, dynamic> _fileStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check file status first
      final status = await BackgroundLogger.checkLogFileStatus();

      // Then get all logs
      final logs = await BackgroundLogger.getLogs();

      setState(() {
        _fileStatus = status;
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _logs = 'Error loading logs: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearLogs() async {
    try {
      await BackgroundLogger.clearLogs();
      // Write a test log to show it's working
      await BackgroundLogger.log('Logs cleared and test log written',
          tag: 'DEBUG');
      await _loadLogs();
    } catch (e) {
      setState(() {
        _logs = 'Error clearing logs: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log File Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    const Text(
                      'Log Contents:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _logs,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add a test log entry
          await BackgroundLogger.log('Test log entry from debug screen',
              tag: 'TEST');
          _loadLogs();
        },
        tooltip: 'Add test log',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusCard() {
    final exists = _fileStatus['exists'] ?? false;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('File exists', exists ? '✅ Yes' : '❌ No'),
            if (_fileStatus['path'] != null)
              _buildStatusRow('Path', _fileStatus['path']),
            if (_fileStatus['directoryExists'] != null)
              _buildStatusRow('Directory exists',
                  _fileStatus['directoryExists'] ? '✅ Yes' : '❌ No'),
            if (_fileStatus['size'] != null)
              _buildStatusRow('Size', _fileStatus['size']),
            if (_fileStatus['lastModified'] != null)
              _buildStatusRow('Last modified', _fileStatus['lastModified']),
            if (_fileStatus['lineCount'] != null)
              _buildStatusRow(
                  'Line count', _fileStatus['lineCount'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

// coverage:ignore-end
