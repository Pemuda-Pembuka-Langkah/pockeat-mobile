// lib/features/homepage/presentation/widgets/heart_bar_widget.dart

// Flutter imports:
import 'package:flutter/material.dart';

class HeartBarWidget extends StatelessWidget {
  final double progress;
  final int currentCalories;
  final int goalCalories;

  const HeartBarWidget({
    super.key,
    required this.progress,
    required this.currentCalories,
    required this.goalCalories,
  });

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeart(progress >= 0.25),
              const SizedBox(width: 8),
              _buildHeart(progress >= 0.5),
              const SizedBox(width: 8),
              _buildHeart(progress >= 0.75),
              const SizedBox(width: 8),
              _buildHeart(progress >= 1.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeart(bool filled) {
    return Icon(
      Icons.favorite,
      color: filled ? Colors.red : Colors.grey.shade300,
      size: 32,
    );
  }
}
