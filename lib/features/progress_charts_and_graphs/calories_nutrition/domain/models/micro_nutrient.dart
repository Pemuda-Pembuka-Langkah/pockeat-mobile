import 'package:flutter/material.dart';

class MicroNutrient {
  final String nutrient;
  final String current;
  final String target;
  final double progress;
  final Color color;
  
  const MicroNutrient({
    required this.nutrient,
    required this.current,
    required this.target,
    required this.progress,
    required this.color,
  });
}