import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_summary_card.dart';

extension ExerciseSharing on BuildContext {
  /// Saves image bytes to a temporary file
  Future<File> _saveImageToTempFile(Uint8List imageBytes) async {
    // For GREEN phase: Minimal implementation that works
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/exercise_summary_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// Creates and shares an exercise summary card
  Future<void> shareExerciseSummary(
      dynamic exercise, String activityType) async {
    bool isLoadingDialogShowing = false;

    try {
      // Show loading indicator
      isLoadingDialogShowing = true;
      showDialog(
        context: this,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Minimal delay for testing
      await Future.delayed(const Duration(milliseconds: 500));

      // In the GREEN phase, we're just showing the message without actual implementation
      if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
        Navigator.of(this).pop();
        isLoadingDialogShowing = false;
      }

      // For GREEN phase implementation, just show a message
      ScaffoldMessenger.of(this).showSnackBar(
        const SnackBar(content: Text('Exercise sharing not implemented yet')),
      );
    } catch (e) {
      debugPrint('Error in shareExerciseSummary: $e');

      // Close loading dialog if open
      if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
        Navigator.of(this).pop();
      }

      // Show error message
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
