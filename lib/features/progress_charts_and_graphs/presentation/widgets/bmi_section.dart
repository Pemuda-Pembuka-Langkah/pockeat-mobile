// Flutter imports:
import 'package:flutter/material.dart';

class BMISection extends StatelessWidget {
  final Color primaryBlue;
  final Color primaryGreen;
  final Color primaryYellow;
  final Color primaryPink;
  final String bmiValue;
  final bool isLoading;

  const BMISection({
    super.key,
    required this.primaryBlue,
    required this.primaryGreen,
    required this.primaryYellow,
    required this.primaryPink,
    required this.bmiValue,
    required this.isLoading,
  });

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Healthy';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Underweight':
        return primaryBlue;
      case 'Healthy':
        return primaryGreen;
      case 'Overweight':
        return primaryYellow;
      case 'Obese':
        return primaryPink;
      default:
        return primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayText = isLoading ? "Loading..." : bmiValue;
    String bmiCategory = "Healthy"; // Default
    Color categoryColor = primaryGreen; // Default

    if (!isLoading && bmiValue != "N/A" && bmiValue != "Error") {
      try {
        double bmiDouble = double.parse(bmiValue);
        bmiCategory = _getBMICategory(bmiDouble);
        categoryColor = _getCategoryColor(bmiCategory);
      } catch (e) {
        // Handle parsing error
      }
    }

    double sliderPosition = 0.4; // Default position (healthy)

    if (!isLoading && bmiValue != "N/A" && bmiValue != "Error") {
      try {
        double bmiDouble = double.parse(bmiValue);
        if (bmiDouble < 18.5) {
          sliderPosition = 0.2; // Underweight
        } else if (bmiDouble >= 18.5 && bmiDouble < 25) {
          sliderPosition = 0.4; // Healthy
        } else if (bmiDouble >= 25 && bmiDouble < 30) {
          sliderPosition = 0.6; // Overweight
        } else {
          sliderPosition = 0.8; // Obese
        }
      } catch (e) {
        // Handle parsing error
      }
    }

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
            Text(
              displayText,
              style: const TextStyle(
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
                color: categoryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bmiCategory,
                style: const TextStyle(
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
                left: MediaQuery.of(context).size.width * sliderPosition,
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
