import 'package:flutter/material.dart';

// coverage:ignore-start
class Meal {
  final String name;
  final int calories;
  final int totalCalories;
  final String time;
  final Color color;
  
  Meal({
    required this.name,
    required this.calories,
    required this.totalCalories,
    required this.time,
    required this.color,
  });
  
  // Add percentage getter to fix errors in meal_row_widget.dart
  double get percentage => calories / totalCalories;
}
// coverage:ignore-end