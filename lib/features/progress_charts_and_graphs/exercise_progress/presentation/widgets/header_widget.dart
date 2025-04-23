import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/toggle_button_widget.dart';

// coverage:ignore-start
class HeaderWidget extends StatelessWidget {
  final bool isWeeklyView;
  final Function(bool) onToggleView;
  final Color primaryGreen;

  // ignore: use_super_parameters
  const HeaderWidget({
    Key? key,
    required this.isWeeklyView,
    required this.onToggleView,
    required this.primaryGreen,
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
              'Exercise Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Track your fitness journey',
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
                primaryColor: primaryGreen,
              ),
              ToggleButtonWidget(
                text: 'Monthly',
                isSelected: !isWeeklyView,
                onTap: () => onToggleView(false),
                primaryColor: primaryGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end
