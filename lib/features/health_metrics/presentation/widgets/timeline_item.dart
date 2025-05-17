import 'package:flutter/material.dart';

class TimelineItem extends StatelessWidget {
  final String day;
  final String message;
  final IconData icon;
  final Color color;
  final bool isFirst;
  final bool isLast;
  final Color textDarkColor;
  final Color textLightColor;

  const TimelineItem({
    super.key,
    required this.day,
    required this.message,
    required this.icon,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
    required this.textDarkColor,
    required this.textLightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline with dot and line
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: Colors.grey.withOpacity(0.2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDarkColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: textLightColor,
                  height: 1.4,
                ),
              ),
              SizedBox(height: isLast ? 0 : 32),
            ],
          ),
        ),
      ],
    );
  }
}
