import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_summary_card.dart';

/// Extension for sharing exercise summaries
extension ExerciseSharing on BuildContext {
  /// Creates and shares an exercise summary card
  Future<void> shareExerciseSummary(
      dynamic exercise, String activityType) async {
    bool isLoadingDialogShowing = false;

    try {
      // Step 1: Show loading indicator
      isLoadingDialogShowing = true;
      _showLoadingDialog();

      // Step 2: Set timeout to prevent getting stuck
      _setTimeoutTimer(onTimeout: () {
        if (isLoadingDialogShowing) {
          _dismissLoadingDialog();
          isLoadingDialogShowing = false;
          _showErrorSnackBar('Sharing took too long and was canceled');
        }
      });

      // Step 3: For this phase, we're just simulating a delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Close dialog
      if (isLoadingDialogShowing) {
        _dismissLoadingDialog();
        isLoadingDialogShowing = false;
      }

      // Step 5: Show message (implementation will be expanded in future)
      _showInfoSnackBar('Exercise sharing not implemented yet');
    } catch (e) {
      debugPrint('Error in shareExerciseSummary: $e');

      // Handle error cleanup
      if (isLoadingDialogShowing) {
        _dismissLoadingDialog();
      }

      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  /// Shows a loading dialog with a progress indicator
  void _showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Dismisses the current dialog if possible
  void _dismissLoadingDialog() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }

  /// Sets a timeout timer to prevent UI getting stuck
  void _setTimeoutTimer({required VoidCallback onTimeout, int seconds = 10}) {
    Future.delayed(Duration(seconds: seconds)).then((_) => onTimeout());
  }

  /// Shows an informational snackbar
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Shows an error snackbar with red background
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  /// Saves image bytes to a temporary file
  Future<File> _saveImageToTempFile(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/exercise_summary_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);
    return file;
  }
}
