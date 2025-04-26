import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_tab_widget.dart';

class WeekSelectionTabs extends StatelessWidget {
  final String selectedWeek;
  final Function(String) onWeekSelected;
  final Color primaryColor;

  const WeekSelectionTabs({
    super.key,
    required this.selectedWeek,
    required this.onWeekSelected,
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
            title: 'This week',
            isSelected: selectedWeek == 'This week',
            selectedColor: primaryColor,
            onTap: () => onWeekSelected('This week'),
          ),
          PeriodTabWidget(
            title: 'Last week',
            isSelected: selectedWeek == 'Last week',
            selectedColor: primaryColor,
            onTap: () => onWeekSelected('Last week'),
          ),
          PeriodTabWidget(
            title: '2 wks. ago',
            isSelected: selectedWeek == '2 wks. ago',
            selectedColor: primaryColor,
            onTap: () => onWeekSelected('2 wks. ago'),
          ),
          PeriodTabWidget(
            title: '3 wks. ago',
            isSelected: selectedWeek == '3 wks. ago',
            selectedColor: primaryColor,
            onTap: () => onWeekSelected('3 wks. ago'),
          ),
        ],
      ),
    );
  }
}