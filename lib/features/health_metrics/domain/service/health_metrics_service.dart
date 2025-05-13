// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import '../../../health_metrics/domain/models/health_metrics_model.dart';
import '../../../health_metrics/domain/repositories/health_metrics_repository.dart';
import '../../../health_metrics/domain/repositories/health_metrics_repository_impl.dart';

/// Service to fetch health metrics for calorie calculations in cardio activities
class HealthMetricsService {
  final HealthMetricsRepository _repository;
  final FirebaseAuth _auth;

  HealthMetricsService({
    HealthMetricsRepository? repository,
    FirebaseAuth? auth,
  })  : _repository = repository ?? HealthMetricsRepositoryImpl(),
        _auth = auth ?? FirebaseAuth.instance;

  /// Fetches health metrics for the current user
  ///
  /// Returns the user's health metrics or creates a default one if not found
  Future<HealthMetricsModel> getUserHealthMetrics() async {
    final user = _auth.currentUser;
    if (user == null) {
      return _getDefaultHealthMetrics('anonymous');
    }

    try {
      final metrics = await _repository.getHealthMetrics(user.uid);

      if (metrics != null) {
        return metrics;
      }

      // Return default health metrics if not found
      return _getDefaultHealthMetrics(user.uid);
    } catch (e) {
      // If there's an error fetching from repository, use default values
      return _getDefaultHealthMetrics(user.uid);
    }
  }

  /// Creates default health metrics for users who haven't completed onboarding
  HealthMetricsModel _getDefaultHealthMetrics(String userId) {
    return HealthMetricsModel(
      userId: userId,
      height: 175.0, // cm
      weight: 70.0, // kg
      age: 30,
      gender: 'Male',
      activityLevel: 'moderate',
      fitnessGoal: 'maintain',
      bmi: 22.9,
      bmiCategory: 'Normal weight',
      desiredWeight: 70.0,
    );
  }
}
