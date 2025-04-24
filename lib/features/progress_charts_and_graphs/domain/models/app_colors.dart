// Flutter imports:
import 'package:flutter/material.dart';

class AppColors {
  final Color primaryYellow;
  final Color primaryPink;
  final Color primaryGreen;

  AppColors({
    required this.primaryYellow,
    required this.primaryPink,
    required this.primaryGreen,
  });

  factory AppColors.defaultColors() {
    return AppColors(
      primaryYellow: const Color(0xFFFFE893),
      primaryPink: const Color(0xFFFF6B6B),
      primaryGreen: const Color(0xFF4ECDC4),
    );
  }
}
