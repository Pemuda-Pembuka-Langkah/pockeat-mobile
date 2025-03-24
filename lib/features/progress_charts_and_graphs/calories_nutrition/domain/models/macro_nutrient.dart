import 'package:flutter/material.dart';

class MacroNutrient {
  final String label;
  final int percentage;
  final String detail;
  final Color color;
  
  const MacroNutrient({
    required this.label,
    required this.percentage,
    required this.detail,
    required this.color,
  });
}