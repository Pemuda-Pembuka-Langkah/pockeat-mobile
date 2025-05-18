// Flutter imports:
import 'package:flutter/material.dart';

class CircularLoadingIndicator extends StatelessWidget {
  final double percentage;
  final double size;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final TextStyle? percentageTextStyle;

  const CircularLoadingIndicator({
    super.key,
    required this.percentage,
    this.size = 150,
    required this.progressColor,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 10,
    this.percentageTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular progress
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),

        // Percentage inside circle
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${percentage.toInt()}%",
              style: percentageTextStyle ??
                  const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
