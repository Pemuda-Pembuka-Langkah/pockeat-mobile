// Dart imports:
//coverage:ignore-file
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
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_summary_card.dart';



extension FoodSharing on BuildContext {
  /// Saves image bytes to a temporary file
  Future<File> _saveImageToTempFile(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/food_summary_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// Creates and shares a food summary card
  Future<void> shareFoodSummary(FoodAnalysisResult food) async {
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
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Set a timeout to prevent getting stuck on loading
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

      // Create the food summary card and show it in an overlay
      final overlayState = Overlay.of(this);
      final summaryCard = FoodSummaryCard(
        food: food,
        cardKey: cardKey,
      );

      // Add the card to the overlay so it can be rendered
      final entry = OverlayEntry(
        builder: (context) => Positioned(
          left: 20, // Position slightly offscreen but still renders
          top: 20,
          child: Opacity(
            opacity: 0.05, // Very low opacity but still renders
            child: Material(
              color: Colors.transparent,
              child: summaryCard,
            ),
          ),
        ),
      );

      overlayState.insert(entry);

      try {
        // Wait for the widget to be rendered
        await Future.delayed(const Duration(milliseconds: 600));

        // Capture the rendered widget
        final boundary = cardKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

        if (boundary == null) {
          debugPrint('Error: Boundary not found');
          // Clean up
          entry.remove();
          if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
            Navigator.of(this).pop();
            isLoadingDialogShowing = false;
          }

          ScaffoldMessenger.of(this).showSnackBar(
            const SnackBar(
                content: Text(
                    'Failed to generate food summary - boundary not found')),
          );
          return;
        }

        final image = await boundary.toImage(pixelRatio: 1.5);
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
          ScaffoldMessenger.of(this).showSnackBar(
            const SnackBar(
                content: Text('Failed to generate food summary image')),
          );
          return;
        }

        // Save the image to a temporary file
        final imageFile = await _saveImageToTempFile(imageBytes);

        // Share the image
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: 'Check out my food entry: ${food.foodName}',
          subject: 'PockEat - Food Summary',
        );
      } catch (e) {
        debugPrint('Error in capturing/sharing image: $e');
        // Clean up
        entry.remove();
        if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
          Navigator.of(this).pop();
          isLoadingDialogShowing = false;
        }
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(
              content: Text('Failed to capture food summary: ${e.toString()}')),
        );
      }
    } catch (e) {
      debugPrint('Error in shareFoodSummary: $e');
      // Close the loading dialog if it's still open
      if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
        Navigator.of(this).pop();
      }

      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text('Error sharing food summary: ${e.toString()}')),
      );
    }
  }
}
