// Flutter imports:
import 'package:flutter/material.dart';

class BodyPartChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryGreen;

  const BodyPartChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
