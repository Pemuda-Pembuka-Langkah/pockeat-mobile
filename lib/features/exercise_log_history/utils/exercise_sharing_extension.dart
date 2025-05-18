// Dart imports:
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_summary_card.dart';

extension ExerciseSharing on BuildContext {
  /// Saves image bytes to a temporary file
  Future<File> _saveImageToTempFile(Uint8List imageBytes) async {
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
      // Create a GlobalKey to identify the RepaintBoundary
      final cardKey = GlobalKey();

      // Show loading indicator
      isLoadingDialogShowing = true;
      showDialog(
        context: this,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Preparing exercise summary to share...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Set a timeout to prevent getting stuck loading
      Future.delayed(const Duration(seconds: 15)).then((_) {
        if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
          Navigator.of(this).pop();
          isLoadingDialogShowing = false;
          ScaffoldMessenger.of(this).showSnackBar(
            const SnackBar(
                content: Text('Sharing took too long and was canceled')),
          );
        }
      });

      // Create the exercise summary card
      final summaryCard = ExerciseSummaryCard(
        cardKey: cardKey,
        exercise: exercise,
        activityType: activityType,
      );

      // Add the card to an overlay so it can be rendered
      final overlayState = Overlay.of(this);
      final entry = OverlayEntry(
        builder: (context) => Positioned(
          left: -2000, // Place offscreen but still rendered
          top: 100,
          child: Material(
            color: Colors.transparent,
            child: summaryCard,
          ),
        ),
      );

      overlayState.insert(entry);

      try {
        // Wait for widget to be rendered
        await Future.delayed(const Duration(milliseconds: 1000));

        // Capture the rendered widget
        final boundary = cardKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

        if (boundary == null) {
          debugPrint('Error: Boundary not found when sharing exercise');
          // Clean up
          entry.remove();
          if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
            Navigator.of(this).pop();
            isLoadingDialogShowing = false;
          }

          ScaffoldMessenger.of(this).showSnackBar(
            const SnackBar(
                content:
                    Text('Failed to generate exercise summary - try again')),
          );
          return;
        }

        // Ensure proper rendering for Instagram Stories
        await Future.delayed(const Duration(milliseconds: 100));
        final image = await boundary.toImage(pixelRatio: 4.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final imageBytes = byteData?.buffer.asUint8List();

        // Remove the overlay entry
        entry.remove();

        // Close the loading dialog
        if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
          Navigator.of(this).pop();
          isLoadingDialogShowing = false;
        }

        if (imageBytes == null) {
          debugPrint('Error: Image bytes are null when sharing exercise');
          ScaffoldMessenger.of(this).showSnackBar(
            const SnackBar(
                content: Text('Failed to capture exercise image - try again')),
          );
          return;
        }

        // Save the image to a temporary file with proper dimensions for Instagram Stories
        final imageFile = await _saveImageToTempFile(imageBytes);

        // Share the image with improved text
        final exerciseType = _getExerciseTypeText(activityType, exercise);
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: 'Check out my $exerciseType workout with PockEat!',
          subject: 'PockEat - Exercise Summary',
        );
      } catch (e) {
        debugPrint('Error capturing/sharing exercise image: $e');
        // Clean up
        entry.remove();
        if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
          Navigator.of(this).pop();
          isLoadingDialogShowing = false;
        }
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(content: Text('Failed to share exercise: ${e.toString()}')),
        );
      }
    } catch (e) {
      debugPrint('Error in shareExerciseSummary: $e');
      // Close the loading dialog if it's still open
      if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
        Navigator.of(this).pop();
      }

      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text('Error sharing exercise: ${e.toString()}')),
      );
    }
  }

  // Helper to get exercise type text for sharing message
  String _getExerciseTypeText(String activityType, dynamic exercise) {
    try {
      switch (activityType) {
        case 'cardio':
          if (exercise.runtimeType.toString().contains('Running')) {
            return 'running';
          } else if (exercise.runtimeType.toString().contains('Cycling')) {
            return 'cycling';
          } else if (exercise.runtimeType.toString().contains('Swimming')) {
            return 'swimming';
          }
          return 'cardio';
        case 'weightlifting':
          return 'weight training';
        case 'smart_exercise':
          return 'workout';
        default:
          return 'exercise';
      }
    } catch (_) {
      return 'exercise';
    }
  }
}
