import 'package:flutter/material.dart';

class ToggleButtonWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Function() onTap;
  final Color primaryColor;

  const ToggleButtonWidget({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to adjust padding and font size
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjust font size based on screen size
    double fontSize = screenWidth < 360 ? 14.0 : 16.0; // Smaller font for smaller screens

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, // Dynamic horizontal padding
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: fontSize, // Dynamic font size
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}