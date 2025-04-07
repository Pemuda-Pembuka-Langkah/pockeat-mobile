import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/exercise_progress/domain/models/performance_metric.dart';

// coverage:ignore-start
class MetricCardWidget extends StatelessWidget {
  final PerformanceMetric metric;

  const MetricCardWidget({
    Key? key,
    required this.metric,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = Color(metric.colorValue);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(metric.icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                metric.label,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            metric.subtext,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
// coverage:ignore-end