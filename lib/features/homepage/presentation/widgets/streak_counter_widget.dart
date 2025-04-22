// lib/features/homepage/presentation/widgets/streak_counter_widget.dart
import 'package:flutter/material.dart';

class StreakCounterWidget extends StatelessWidget {
  final int streakDays;

  const StreakCounterWidget({
    super.key,
    required this.streakDays,
  });

  Widget _buildStreakIcon() {
    if (streakDays == 0) {
      return Icon(
        Icons.local_fire_department,
        color: Colors.grey.shade400,
        size: 32,
      );
    } else if (streakDays < 7) {
      return const Icon(
        Icons.local_fire_department,
        color: Colors.orange,
        size: 32,
      );
    } else {
      return const Icon(
        Icons.whatshot,
        color: Colors.deepOrange,
        size: 32,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStreakIcon(),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Streak',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$streakDays',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'days',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}