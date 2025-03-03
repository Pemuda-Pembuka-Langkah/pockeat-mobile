import 'package:pockeat/features/weight_training_log/domain/models/exercise.dart';

const double defaultWeight = 75;
const double k1 = 0.0001;
const double k2 = 0.002;

double calculateExerciseVolume(Exercise exercise) {
  double totalVolume = 0.0;
  for (var set in exercise.sets) {
    if (set.reps > 0) {
      totalVolume += set.weight * set.reps;
    }
  }
  return totalVolume;
}

double calculateTotalVolume(List<Exercise> exercises) {
  double total = 0.0;
  for (var exercise in exercises) {
    total += calculateExerciseVolume(exercise);
  }
  return total;
}

double calculateEstimatedCalories(List<Exercise> exercises) {
  double totalCalories = 0.0;
  for (var exercise in exercises) {
    totalCalories += calculateExerciseCalories(exercise);
  }
  return totalCalories;
}

double calculateExerciseCalories(Exercise exercise) {
  double totalDurationInHours = 0.0;
  double totalWeight = 0.0;
  double totalReps = 0.0;

  for (var set in exercise.sets) {
    totalDurationInHours += set.duration / 60;
    totalWeight += set.weight * set.reps;
    totalReps += set.reps;
  }

  return exercise.metValue * defaultWeight * (totalDurationInHours + k1 * totalWeight + k2 * totalReps);
}

int calculateTotalSets(List<Exercise> exercises) {
  int totalSets = 0;
  for (var exercise in exercises) {
    totalSets += exercise.sets.length;
  }
  return totalSets;
}

int calculateTotalReps(List<Exercise> exercises) {
  int totalReps = 0;
  for (var exercise in exercises) {
    for (var set in exercise.sets) {
      totalReps += set.reps;
    }
  }
  return totalReps;
}

double calculateTotalDuration(List<Exercise> exercises) {
  double totalDuration = 0.0;
  for (var exercise in exercises) {
    for (var set in exercise.sets) {
      totalDuration += set.duration;
    }
  }
  return totalDuration;
}