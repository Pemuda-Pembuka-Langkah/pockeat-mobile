import 'package:flutter/material.dart';

class ExerciseChipWidget extends StatelessWidget {
  final String exerciseName;
  final VoidCallback onTap;
  final Color primaryGreen;

  const ExerciseChipWidget({
    super.key,
    required this.exerciseName,
    required this.onTap,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryGreen.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, size: 16, color: primaryGreen),
            const SizedBox(width: 4),
            Text(
              exerciseName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.add, size: 16, color: primaryGreen),
          ],
        ),
      ),
    );
  }
}
