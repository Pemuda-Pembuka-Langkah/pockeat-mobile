import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

const double defaultWeight = 75;
const double k1 = 0.0001;
const double k2 = 0.002;

double calculateExerciseVolume(WeightLifting exercise) {
  return exercise.sets.fold(0.0, (sum, set) {
    return set.reps > 0 ? sum + (set.weight * set.reps) : sum;
  });
}

double calculateTotalVolume(List<WeightLifting> exercises) {
  return exercises.fold(
      0.0, (sum, exercise) => sum + calculateExerciseVolume(exercise));
}

double calculateEstimatedCalories(List<WeightLifting> exercises) {
  return exercises.fold(
      0.0, (sum, exercise) => sum + calculateExerciseCalories(exercise));
}

double calculateExerciseCalories(WeightLifting exercise) {
  double totalDurationInHours =
      exercise.sets.fold(0.0, (sum, set) => sum + set.duration) / 60;
  double totalWeight =
      exercise.sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  double totalReps = exercise.sets.fold(0.0, (sum, set) => sum + set.reps);
  return exercise.metValue *
      defaultWeight *
      (totalDurationInHours + k1 * totalWeight + k2 * totalReps);
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
