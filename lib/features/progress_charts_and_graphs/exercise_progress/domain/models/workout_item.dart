import 'package:flutter/material.dart';

// coverage:ignore-start
class WorkoutItem {
  final String title;
  final String type;
  final String stats;
  final String time;
  final int colorValue;
  final IconData icon; // Add this new field

  WorkoutItem({
    required this.title,
    required this.type,
    required this.stats,
    required this.time,
    required this.colorValue,
    this.icon = Icons.fitness_center, // Default icon
  });
}
// coverage:ignore-end
