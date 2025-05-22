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
          // Title and tooltip icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Panda's Health",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              _buildInfoButton(context),
            ],
          ),
          const SizedBox(height: 12),
          // Hearts row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(maxHeart, (index) {
              return _buildHeart(index < heart, index, context);
            }),
          ),
          const SizedBox(height: 10),
          // Status text below the hearts
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isCalorieOverTarget
                  ? Colors.purple.shade700
                  : heart == 0
                      ? Colors.orange.shade800
                      : Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return InkWell(
      onTap: () => _showHealthInfoDialog(context),
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          Icons.info_outline,
          color: Colors.blue.shade700,
          size: 20,
        ),
      ),
    );
  }

  void _showHealthInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 8),
              Text('Panda Health Guide'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  'How Hearts Work',
                  'Each heart represents 25% of your daily calorie goal:',
                ),
                const SizedBox(height: 8),
                _buildHeartExplanation('0-25%', '1st heart'),
                _buildHeartExplanation('25-50%', '2nd heart'),
                _buildHeartExplanation('50-75%', '3rd heart'),
                _buildHeartExplanation('75-100%', '4th heart'),
                const Divider(height: 24),
                _buildInfoSection(
                  'Keep Your Panda Happy',
                  'Log your meals regularly to keep your panda healthy and happy. Try to fill all hearts each day!',
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  'Avoid Overfeeding',
                  'If you exceed your daily calorie target, your panda will be too full and sad. The hearts will turn purple as a warning.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildHeartExplanation(String percentage, String heartLabel) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text('$percentage → $heartLabel',
              style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHeart(bool filled, int index, BuildContext context) {
    final String tooltipText = _getHeartTooltipText(index);

    return Tooltip(
      message: tooltipText,
      verticalOffset: -40,
      preferBelow: false,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          Icons.favorite,
          color: filled
              ? isCalorieOverTarget
                  ? Colors.purple
                  : Colors.red
              : Colors.grey.shade300,
          size: 32,
        ),
      ),
    );
  }

  String _getHeartTooltipText(int index) {
    // Each heart represents 25% of daily calorie target
    final percentages = {
      0: '0-25%',
      1: '25-50%',
      2: '50-75%',
      3: '75-100%',
    };

    return 'Calorie intake: ${percentages[index]} of daily goal';
  }

  String _getStatusText() {
    if (isCalorieOverTarget) {
      return '🥺 Oops! Panda is too full';
    } else {
      if (heart == 0) {
        return '🍽️ Feed your hungry panda!';
      } else if (heart == maxHeart) {
        return '✨ Perfect balance achieved!';
      } else if (heart == 1) {
        return '🍎 Just starting, keep going!';
      } else if (heart == 2) {
        return '👍 Halfway there, doing great!';
      } else {
        return '🎯 Almost there, keep it up!';
      }
    }
  }
}
