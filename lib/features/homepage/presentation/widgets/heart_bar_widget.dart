// lib/features/homepage/presentation/widgets/heart_bar_widget.dart

// Flutter imports:
import 'package:flutter/material.dart';

class HeartBarWidget extends StatelessWidget {
  final int heart;
  static const int maxHeart = 4;
  final bool isCalorieOverTarget;

  const HeartBarWidget({
    super.key,
    required this.heart,
    required this.isCalorieOverTarget,
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
            children: List.generate(maxHeart, (index) {
              return _buildHeart(index < heart);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeart(bool filled) {
    return Icon(
      Icons.favorite,
      color: filled
          ? isCalorieOverTarget
              ? Colors.purple
              : Colors.red
          : Colors.grey.shade300,
      size: 32,
    );
  }
}
