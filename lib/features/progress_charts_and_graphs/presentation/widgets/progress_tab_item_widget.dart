import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';

class ProgressTabItemWidget extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  const ProgressTabItemWidget({
    super.key,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? colors.primaryPink : Colors.black54,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}