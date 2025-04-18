import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

abstract class HealthMetricsRepository {
  Future<void> saveHealthMetrics(HealthMetricsModel metrics);

  Future<HealthMetricsModel?> getHealthMetrics(String userId);
}