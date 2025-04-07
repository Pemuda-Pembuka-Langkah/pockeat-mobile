

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pockeat/features/api_scan/models/food_analysis.dart';


/// Extension for sharing food summary
extension FoodSharing on BuildContext {
  /// Creates and shares a food summary card
  Future<void> shareFoodSummary(FoodAnalysisResult food) async {
    bool isLoadingDialogShowing = false;

    try {
      // Step 1: Show loading indicator
      isLoadingDialogShowing = true;
      _showLoadingDialog();

      // Step 2: Set timeout to prevent UI from being stuck
      _startTimeoutTimer(onTimeout: () {
        if (isLoadingDialogShowing) {
          _dismissLoadingDialog();
          isLoadingDialogShowing = false;
          _showErrorSnackBar('Sharing took too long and was canceled');
        }
      });

      // Step 3: Rendering would be implemented here
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Close loading dialog
      if (isLoadingDialogShowing) {
        _dismissLoadingDialog();
        isLoadingDialogShowing = false;
      }

      // Step 5: Show temporary implementation message
      _showInfoSnackBar('Sharing functionality not yet implemented');
    } catch (e) {
      debugPrint('Error in shareFoodSummary: $e');

      // Clean up on error
      if (isLoadingDialogShowing) {
        _dismissLoadingDialog();
        isLoadingDialogShowing = false;
      }

      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  /// Shows a loading dialog
  void _showLoadingDialog() {
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
  }

  /// Dismisses the current dialog if possible
  void _dismissLoadingDialog() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }

  /// Starts a timeout timer
  void _startTimeoutTimer({required VoidCallback onTimeout, int seconds = 5}) {
    Future.delayed(Duration(seconds: seconds)).then((_) => onTimeout());
  }

  /// Shows an error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  /// Shows an info snackbar
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
