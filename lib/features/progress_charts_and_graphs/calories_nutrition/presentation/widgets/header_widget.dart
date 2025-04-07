import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/toggle_button_widget.dart';

// coverage:ignore-start
class HeaderWidget extends StatelessWidget {
  final bool isWeeklyView;
  final Function(bool) onToggleView;
  final Color primaryColor;

  const HeaderWidget({
    Key? key,
    required this.isWeeklyView,
    required this.onToggleView,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Track your daily food intake',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              ToggleButtonWidget(
                text: 'Weekly',
                isSelected: isWeeklyView,
                onTap: () => onToggleView(true),
                selectedColor: primaryColor, // Changed from primaryColor to selectedColor
              ),
              ToggleButtonWidget(
                text: 'Monthly',
                isSelected: !isWeeklyView,
                onTap: () => onToggleView(false),
                selectedColor: primaryColor, // Changed from primaryColor to selectedColor
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end