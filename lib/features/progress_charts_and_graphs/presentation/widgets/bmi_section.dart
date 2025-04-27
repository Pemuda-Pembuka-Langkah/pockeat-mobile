import 'package:flutter/material.dart';

class BMISection extends StatelessWidget {
  final Color primaryBlue;
  final Color primaryGreen;
  final Color primaryYellow;
  final Color primaryPink;

  const BMISection({
    super.key,
    required this.primaryBlue,
    required this.primaryGreen,
    required this.primaryYellow,
    required this.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your BMI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            const Text(
              '24.3',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Your weight is ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Healthy',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [
                primaryBlue,
                primaryGreen,
                primaryYellow,
                primaryPink,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: MediaQuery.of(context).size.width * 0.4,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBMICategory(primaryBlue, 'Underweight'),
            _buildBMICategory(primaryGreen, 'Healthy'),
            _buildBMICategory(primaryYellow, 'Overweight'),
            _buildBMICategory(primaryPink, 'Obese'),
          ],
        ),
      ],
    );
  }

  Widget _buildBMICategory(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}