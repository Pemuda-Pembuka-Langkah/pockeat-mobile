import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/exercise_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/workout_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/workout_stat_widget.dart';

class WorkoutOverviewWidget extends StatelessWidget {
  final List<ExerciseData> exerciseData;
  final List<WorkoutStat> workoutStats;
  final String completionPercentage;
  final Color primaryGreen;

  const WorkoutOverviewWidget({
    Key? key,
    required this.exerciseData,
    required this.workoutStats,
    required this.completionPercentage,
    required this.primaryGreen,
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
                    'Training Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Keep pushing harder!',
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
              primaryXAxis: const CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              primaryYAxis: const NumericAxis(
                minimum: 0,
                maximum: 500,
                interval: 100,
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: Colors.black12,
                  dashArray: [5, 5],
                ),
                labelStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              series: <CartesianSeries>[
                ColumnSeries<ExerciseData, String>(
                  color: primaryGreen,
                  width: 0.7,
                  dataSource: exerciseData,
                  xValueMapper: (ExerciseData data, _) => data.day,
                  yValueMapper: (ExerciseData data, _) => data.calories,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}