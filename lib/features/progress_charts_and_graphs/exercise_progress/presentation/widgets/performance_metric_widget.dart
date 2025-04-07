import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/presentation/widgets/metric_card_widget.dart';

// coverage:ignore-start
class PerformanceMetricsWidget extends StatelessWidget {
  final List<PerformanceMetric> metrics;

  // ignore: use_super_parameters
  const PerformanceMetricsWidget({
    Key? key,
    required this.metrics,
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
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MetricCardWidget(metric: metrics[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCardWidget(metric: metrics[1]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricCardWidget(metric: metrics[2]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCardWidget(metric: metrics[3]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// coverage:ignore-end