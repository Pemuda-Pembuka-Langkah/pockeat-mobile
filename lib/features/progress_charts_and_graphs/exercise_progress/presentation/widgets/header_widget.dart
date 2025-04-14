import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/toggle_button_widget.dart';

class HeaderWidget extends StatelessWidget {
  final bool isWeeklyView;
  final Function(bool) onToggleView;
  final Color primaryGreen;

  const HeaderWidget({
    Key? key,
    required this.isWeeklyView,
    required this.onToggleView,
    required this.primaryGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to adjust font size and spacing
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjust font size based on screen size
    double fontSize = screenWidth < 360 ? 18.0 : 24.0; // Smaller font for smaller screens

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Exercise Progress',
            style: TextStyle(
              fontSize: fontSize, // Dynamic font size
              fontWeight: FontWeight.bold,
            ),
          ),
          ToggleButtonWidget(
            text: isWeeklyView ? 'Weekly' : 'Monthly',
            isSelected: isWeeklyView,
            onTap: () => onToggleView(!isWeeklyView),
            primaryColor: primaryGreen,
          ),
        ],
      ),
    );
  }
}