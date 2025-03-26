import 'package:flutter/material.dart';

class Meal {
  final String name;
  final int calories;
  final int totalCalories;
  final String time;
  final Color color;
  
  const Meal({
    required this.name,
    required this.calories,
    required this.totalCalories,
    required this.time,
    required this.color,
  });
  
  double get percentage => calories / totalCalories;
}