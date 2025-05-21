// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

// coverage:ignore-start
// Default values to use as fallback if health metrics can't be retrieved
const double defaultWeight = 75;
const double k1 = 0.0001;
const double k2 = 0.002;

// User health metrics cache to avoid repeated database queries
Map<String, dynamic> _userHealthMetricsCache = {};

double calculateExerciseVolume(WeightLifting exercise) {
  return exercise.sets.fold(0.0, (sum, set) {
    return set.reps > 0 ? sum + (set.weight * set.reps) : sum;
  });
}

double calculateTotalVolume(List<WeightLifting> exercises) {
  return exercises.fold(
      0.0, (sum, exercise) => sum + calculateExerciseVolume(exercise));
}

Future<double> calculateEstimatedCalories(List<WeightLifting> exercises) async {
  double totalCalories = 0.0;

  // Get current user
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Get user's health metrics (weight, age, height, gender) from Firebase
    await _loadUserHealthMetrics(user.uid);
  }

  // Calculate calories for each exercise using the user's metrics
  for (final exercise in exercises) {
    totalCalories += await calculateExerciseCalories(exercise);
  }

  return totalCalories;
}

Future<double> calculateExerciseCalories(WeightLifting exercise) async {
  // Get current user
  final user = FirebaseAuth.instance.currentUser;

  // Default weight if user metrics can't be loaded
  double userWeight = defaultWeight;

  if (user != null) {
    // Load health metrics if not already cached
    if (_userHealthMetricsCache.isEmpty) {
      await _loadUserHealthMetrics(user.uid);
    }

    // Use user's actual weight from cache
    userWeight = _userHealthMetricsCache['weight'] ?? defaultWeight;
  }
  double totalDurationInHours =
      exercise.sets.fold(0.0, (sum, set) => sum + set.duration) / 60;
  double totalWeight =
      exercise.sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  double totalReps = exercise.sets.fold(0.0, (sum, set) => sum + set.reps);

  // Account for activity level when calculating calories
  double activityMultiplier = 1.0;
  if (_userHealthMetricsCache.containsKey('activityLevel')) {
    switch (_userHealthMetricsCache['activityLevel']) {
      case 'sedentary':
        activityMultiplier =
            0.8; // Sedentary people burn fewer calories during exercise
        break;
      case 'lightlyActive':
        activityMultiplier = 0.9;
        break;
      case 'moderatelyActive':
        activityMultiplier = 1.0; // Baseline
        break;
      case 'veryActive':
        activityMultiplier = 1.1;
        break;
      case 'extraActive':
        activityMultiplier =
            1.2; // Very active people have better exercise efficiency
        break;
    }
  }

  // Age adjustment factor - younger people tend to burn calories more efficiently
  double ageAdjustment = 1.0;
  if (_userHealthMetricsCache.containsKey('age')) {
    int age = _userHealthMetricsCache['age'] ?? 30;
    if (age < 25) {
      ageAdjustment = 1.1; // Younger people burn more calories
    } else if (age > 50) {
      ageAdjustment = 0.9; // Older people burn fewer calories
    }
  }

  // Gender adjustment factor
  double genderAdjustment = 1.0;
  if (_userHealthMetricsCache.containsKey('gender')) {
    String gender = _userHealthMetricsCache['gender'] ?? 'male';
    if (gender.toLowerCase() == 'female') {
      genderAdjustment = 0.9; // Adjust for female metabolic differences
    }
  }

  // Calculate calories with the enhanced formula
  return exercise.metValue *
      userWeight *
      (totalDurationInHours + k1 * totalWeight + k2 * totalReps) *
      activityMultiplier *
      ageAdjustment *
      genderAdjustment;
}

// Helper function to load user health metrics from Firebase
Future<void> _loadUserHealthMetrics(String userId) async {
  try {
    // Query the health_metrics collection for the current user
    final healthSnapshot = await FirebaseFirestore.instance
        .collection('health_metrics')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (healthSnapshot.docs.isNotEmpty) {
      // Cache the user's health metrics
      _userHealthMetricsCache = healthSnapshot.docs.first.data();
    }
  } catch (e) {
    print('Error loading health metrics: $e');
    // If there's an error, we'll use default values
  }
}

// Clear the cache when needed (e.g., when user updates their profile)
void clearUserHealthMetricsCache() {
  _userHealthMetricsCache.clear();
}

int calculateTotalSets(List<WeightLifting> exercises) {
  return exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
}

int calculateTotalReps(List<WeightLifting> exercises) {
  return exercises.fold(
      0,
      (sum, exercise) =>
          sum + exercise.sets.fold(0, (setSum, set) => setSum + set.reps));
}

double calculateTotalDuration(List<WeightLifting> exercises) {
  return exercises.fold(
      0.0,
      (sum, exercise) =>
          sum +
          exercise.sets.fold(0.0, (setSum, set) => setSum + set.duration));
}
// coverage:ignore-end
