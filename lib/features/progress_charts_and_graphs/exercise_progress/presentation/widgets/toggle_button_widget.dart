// Flutter imports:
import 'package:flutter/material.dart';

// coverage:ignore-start
class ToggleButtonWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Function() onTap;
  final Color primaryColor;

  // ignore: use_super_parameters
  const ToggleButtonWidget({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
// coverage:ignore-end
