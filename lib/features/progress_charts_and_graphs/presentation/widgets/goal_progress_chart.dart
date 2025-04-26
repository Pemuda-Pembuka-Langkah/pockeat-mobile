import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/weight_data.dart';

class GoalProgressChart extends StatelessWidget {
  final List<WeightData> displayData;
  final Color primaryGreen;

  const GoalProgressChart({
    super.key,
    required this.displayData,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Goal Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '2.5% of goal',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: 73,
              maximum: 79,
              interval: 1,
              majorGridLines: MajorGridLines(
                width: 1,
                color: Colors.grey[300],
              ),
              axisLine: const AxisLine(width: 0),
            ),
            series: <CartesianSeries>[
              LineSeries<WeightData, String>(
                dataSource: displayData,
                xValueMapper: (WeightData data, _) => data.week,
                yValueMapper: (WeightData data, _) => data.weight > 0 ? data.weight : null,
                color: Colors.black,
                width: 2,
                emptyPointSettings: EmptyPointSettings(
                  mode: EmptyPointMode.gap,
                ),
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.circle,
                  height: 8,
                  width: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}