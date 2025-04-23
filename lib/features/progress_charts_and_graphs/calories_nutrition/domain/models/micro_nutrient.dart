import 'package:flutter/material.dart';

// coverage:ignore-start
class MicroNutrient {
  final String nutrient;
  final String current;
  final String target;
  final double progress;
  final Color color;

  MicroNutrient({
    required this.nutrient,
    required this.current,
    required this.target,
    required this.progress,
    required this.color,
  });
}
// coverage:ignore-end
