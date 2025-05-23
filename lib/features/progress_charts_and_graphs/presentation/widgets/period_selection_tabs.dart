// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_tab_widget.dart';

class PeriodSelectionTabs extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodSelected;
  final Color primaryColor;

  const PeriodSelectionTabs({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          PeriodTabWidget(
            title: 'Daily',
            isSelected: selectedPeriod == '1 Week',
            selectedColor: primaryColor,
            onTap: () => onPeriodSelected('1 Week'),
          ),
          PeriodTabWidget(
            title: 'Weekly',
            isSelected: selectedPeriod == '1 Month',
            selectedColor: primaryColor,
            onTap: () => onPeriodSelected('1 Month'),
          ),
        ],
      ),
    );
  }
}
