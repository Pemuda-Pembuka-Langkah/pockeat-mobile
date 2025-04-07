import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/analytics_insight/domain/models/metric_item.dart';

class PerformanceMetricsWidget extends StatelessWidget {
  final List<MetricItem> metrics;

  const PerformanceMetricsWidget({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              metrics.length * 2 - 1,
              (index) {
                if (index.isEven) {
                  final metricIndex = index ~/ 2;
                  return Expanded(
                    child: _buildMetricItem(metrics[metricIndex]),
                  );
                } else {
                  return Container(height: 40, width: 1, color: Colors.black12);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(MetricItem metric) {
    return Column(
      children: [
        Text(
          metric.label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          metric.value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: metric.color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          metric.subtext,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}