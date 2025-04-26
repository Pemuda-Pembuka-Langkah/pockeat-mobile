// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:syncfusion_flutter_charts/charts.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/nutrition_stat_widget.dart';

// coverage:ignore-start
class ProgressOverviewWidget extends StatelessWidget {
  final List<CalorieData> calorieData;
  final List<NutritionStat> nutritionStats;
  final Color primaryGreen;
  final Color primaryPink;
  final bool isLoading;

  // ignore: use_super_parameters
  const ProgressOverviewWidget({
    Key? key,
    required this.calorieData,
    required this.nutritionStats,
    required this.primaryGreen,
    required this.primaryPink,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You\'re doing great!',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: primaryGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '0% of goal',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: nutritionStats
                .map((stat) => NutritionStatWidget(stat: stat))
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SfCartesianChart(
                    margin: EdgeInsets.zero,
                    // Remove legend completely
                    legend: const Legend(isVisible: false),
                    primaryXAxis: const CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0),
                      labelStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: _getChartMaximum(),
                      interval: _getYAxisInterval(),
                      majorGridLines: const MajorGridLines(
                        width: 0.5,
                        color: Colors.black12,
                        dashArray: [5, 5],
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(
                        enable: true,
                        header: '',
                        format: 'point.x: point.y kcal'),
                    series: <CartesianSeries>[
                      ColumnSeries<CalorieData, String>(
                        color: primaryPink,
                        width: 0.7,
                        dataSource: calorieData,
                        xValueMapper: (CalorieData data, _) => data.label,
                        yValueMapper: (CalorieData data, _) => data.calories,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        // Add data labels for better readability
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelAlignment: ChartDataLabelAlignment.top,
                          textStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate maximum Y value for the chart
  double _getChartMaximum() {
    if (calorieData.isEmpty) return 3000;

    double maxY = 0;
    for (var data in calorieData) {
      if (data.calories > maxY) {
        maxY = data.calories;
      }
    }

    // Add 20% padding and round to nearest 500
    return (((maxY * 1.2) / 500).ceil() * 500).toDouble();
  }

  // Helper method to calculate Y-axis interval
  double _getYAxisInterval() {
    final max = _getChartMaximum();
    return max <= 1500 ? 250 : 500;
  }
}
// coverage:ignore-end
