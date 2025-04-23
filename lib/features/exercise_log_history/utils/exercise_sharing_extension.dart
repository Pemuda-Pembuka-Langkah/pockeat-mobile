import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_summary_card.dart';

//coverage:ignore-file

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
                  'Preparing to share...',
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
      Future.delayed(const Duration(seconds: 10)).then((_) {
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
          left: 20, // Place slightly off-screen but still rendered
          top: 20,
          child: Opacity(
            opacity: 0.05, // Almost invisible, but still rendered
            child: Material(
              color: Colors.transparent,
              child: summaryCard,
            ),
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

        // Capture the image
        final image = await boundary.toImage(pixelRatio: 2.0);
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

        // Save the image to a temporary file
        final imageFile = await _saveImageToTempFile(imageBytes);

        // Share the image
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: 'Check out my exercise!',
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
}
