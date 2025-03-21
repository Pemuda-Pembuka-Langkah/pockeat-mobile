import 'package:flutter/material.dart';

class CorrectionButton extends StatelessWidget {
  final bool isLoading;
  final Color primaryYellow;
  final Color primaryPink;
  final VoidCallback onPressed;

  const CorrectionButton({
    super.key,
    required this.isLoading,
    required this.primaryYellow,
    required this.primaryPink,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(
          Icons.edit_outlined,
          color: primaryPink,
        ),
        label: Text(
          "Correct Analysis",
          style: TextStyle(
            color: primaryPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow.withOpacity(0.3),
          foregroundColor: primaryPink,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: primaryPink.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}