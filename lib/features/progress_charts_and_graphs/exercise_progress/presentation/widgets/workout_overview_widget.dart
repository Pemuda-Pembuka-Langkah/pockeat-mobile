import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_stat_widget.dart';

// coverage:ignore-start
class WorkoutOverviewWidget extends StatelessWidget {
  final List<ExerciseData> exerciseData;
  final List<WorkoutStat> workoutStats;
  final String completionPercentage;
  final Color primaryGreen;
  // Add a parameter to determine if we're in weekly view
  final bool isWeeklyView;

  const WorkoutOverviewWidget({
    super.key,
    required this.exerciseData,
    required this.workoutStats,
    required this.completionPercentage,
    required this.primaryGreen,
    required this.isWeeklyView, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    // Determine the correct expected data format based on view mode
    List<ExerciseData> displayData;
    
    if (isWeeklyView) {
      // Weekly view: Show Monday-Sunday
      final List<String> expectedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      // Check if we have proper weekly data
      if (exerciseData.length == 7 && 
          exerciseData.every((data) => expectedDays.contains(data.date))) {
        // Use the data we have
        displayData = exerciseData;
      } else {
        // Use default week data
        displayData = expectedDays.map((day) => ExerciseData(day, 0)).toList();
      }
    } else {
      // Monthly view: Show Week 1-4
      final List<String> expectedWeeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      
      // Check if we have proper monthly data
      if (exerciseData.length == 4 && 
          exerciseData.every((data) => data.date.startsWith('Week'))) {
        // Use the data we have
        displayData = exerciseData;
      } else {
        // Use default month data
        displayData = expectedWeeks.map((week) => ExerciseData(week, 0)).toList();
      }
    }
    
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.running_with_errors, color: primaryGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      completionPercentage,
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
            children: workoutStats.map((stat) => 
              WorkoutStatWidget(stat: stat)
            ).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              primaryYAxis: NumericAxis(
                // Dynamically set the maximum based on data
                minimum: 0,
                maximum: _getChartMaximum(displayData),
                interval: _getYAxisInterval(displayData),
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
                format: 'point.x: point.y kcal'
              ),
              series: <CartesianSeries>[
                ColumnSeries<ExerciseData, String>(
                  color: primaryGreen,
                  width: 0.7,
                  dataSource: displayData,
                  xValueMapper: (ExerciseData data, _) => data.date,
                  yValueMapper: (ExerciseData data, _) => data.value,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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

  // Helper method to calculate a sensible maximum for the y-axis
  double _getChartMaximum(List<ExerciseData> data) {
    if (data.isEmpty) return 500;
    
    // Find the highest value
    double maxValue = 0;
    for (var item in data) {
      if (item.value > maxValue) maxValue = item.value;
    }
    
    // If all values are 0, return a default maximum
    if (maxValue == 0) return 500;
    
    // Round up to the next 100
    return ((maxValue / 100).ceil() * 100 + 100).toDouble();
  }

  // Helper method to calculate a sensible interval for the y-axis
  double _getYAxisInterval(List<ExerciseData> data) {
    double max = _getChartMaximum(data);
    
    if (max <= 100) return 20;
    if (max <= 500) return 100;
    if (max <= 1000) return 200;
    
    return (max / 5).roundToDouble();
  }
}
// coverage:ignore-end