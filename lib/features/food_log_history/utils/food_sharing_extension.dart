import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_summary_card.dart';
import 'package:share_plus/share_plus.dart';

extension FoodSharing on BuildContext {
  /// Saves image bytes to a temporary file
  Future<File> _saveImageToTempFile(Uint8List imageBytes) async {
    // TODO: Implement saving image to temporary file
    throw UnimplementedError('_saveImageToTempFile not yet implemented');
  }

  /// Creates and shares a food summary card
  Future<void> shareFoodSummary(FoodAnalysisResult food) async {
    // Flag to track loading dialog state
    bool isLoadingDialogShowing = false;

    try {
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
      Future.delayed(const Duration(seconds: 5)).then((_) {
        if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
          Navigator.of(this).pop();
          isLoadingDialogShowing = false;
          ScaffoldMessenger.of(this).showSnackBar(
            const SnackBar(
                content: Text('Sharing took too long and was canceled')),
          );
        }
      });

      // TODO: Implement the food summary card rendering
      await Future.delayed(const Duration(milliseconds: 500));

      // Close the loading dialog
      if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
        Navigator.of(this).pop();
        isLoadingDialogShowing = false;
      }

      // Display not implemented message
      ScaffoldMessenger.of(this).showSnackBar(
        const SnackBar(
            content: Text('Sharing functionality not yet implemented')),
      );
    } catch (e) {
      debugPrint('Error in shareFoodSummary: $e');

      // Close the loading dialog if it's still open
      if (isLoadingDialogShowing && Navigator.of(this).canPop()) {
        Navigator.of(this).pop();
        isLoadingDialogShowing = false;
      }

      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
