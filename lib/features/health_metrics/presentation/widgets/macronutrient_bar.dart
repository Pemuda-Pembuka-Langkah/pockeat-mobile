// Flutter imports:
import 'package:flutter/material.dart';

class MacronutrientBar extends StatelessWidget {
  final Map<String, double> macros;
  final Color defaultColor;
  final Color textDarkColor;
  final Map<String, Color>? customColors;

  const MacronutrientBar({
    super.key,
    required this.macros,
    required this.defaultColor,
    required this.textDarkColor,
    this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors for each macronutrient
    final Map<String, Color> macroColors = customColors ??
        {
          'Protein': const Color(0xFF5E60CE), // Purple
          'Carbs': const Color(0xFFFF6B6B), // Pink
          'Fat': const Color(0xFFFFC700), // Yellow
        };

    // Calculate total for percentage
    final total = macros.values.fold(0.0, (sum, value) => sum + value);

    return Column(
      children: macros.entries.map((e) {
        final percentage = total > 0 ? (e.value / total * 100) : 0.0;
        final color = macroColors[e.key] ?? defaultColor;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        e.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: textDarkColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${e.value.toStringAsFixed(0)} g",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textDarkColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  // Background bar
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Progress bar
                  Container(
                    height: 6,
                    width: MediaQuery.of(context).size.width *
                        percentage /
                        100 *
                        0.7, // Adjusted for padding
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
