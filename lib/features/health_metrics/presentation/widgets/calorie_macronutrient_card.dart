import 'package:flutter/material.dart';
import '../widgets/macronutrient_bar.dart';

class CalorieMacronutrientCard extends StatelessWidget {
  final double tdee;
  final Map<String, double> macros;
  final Color primaryGreen;
  final Color textDarkColor;

  const CalorieMacronutrientCard({
    super.key,
    required this.tdee,
    required this.macros,
    required this.primaryGreen,
    required this.textDarkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_fire_department, color: primaryGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Calorie Target",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${tdee.toStringAsFixed(0)} kcal",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Macronutrient Breakdown",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textDarkColor,
            ),
          ),
          const SizedBox(height: 12),
          MacronutrientBar(
            macros: macros,
            defaultColor: primaryGreen,
            textDarkColor: textDarkColor,
          ),
        ],
      ),
    );
  }
}
