// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';
import 'package:pockeat/features/weight_training_log/services/workout_service.dart';

/// Model untuk item history log olahraga
///
/// Model ini didesain untuk menyatukan berbagai jenis aktivitas olahraga
/// (SmartExercise, Weightlifting, Cardio) dalam satu format yang konsisten
/// untuk ditampilkan di history log.

// coverage:ignore-start
class ExerciseLogHistoryItem {
  final String id;
  final String activityType; // Diganti dari enum menjadi string
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final num caloriesBurned;
  final String?
      sourceId; // ID dari data sumber (misalnya ID dari SmartExerciseLog)
  // Konstanta untuk tipe aktivitas umum
  static const String typeSmartExercise = 'smart_exercise';
  static const String typeWeightlifting = 'weightlifting';
  static const String typeCardio = 'cardio';
  // Bisa ditambahkan tipe lain sesuai kebutuhan

  ExerciseLogHistoryItem({
    String? id,
    required this.activityType,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.caloriesBurned,
    this.sourceId,
  }) : id = id ?? const Uuid().v4();

  /// Mendapatkan string representasi waktu yang user-friendly (contoh: "1d ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Factory constructor untuk membuat ExerciseLogHistoryItem dari SmartExerciseLog
  factory ExerciseLogHistoryItem.fromSmartExerciseLog(
      ExerciseAnalysisResult smartExerciseLog) {
    return ExerciseLogHistoryItem(
        activityType: typeSmartExercise,
        title: smartExerciseLog.exerciseType,
        subtitle:
            '${smartExerciseLog.duration} • ${smartExerciseLog.estimatedCalories} cal',
        timestamp: smartExerciseLog.timestamp,
        caloriesBurned: smartExerciseLog.estimatedCalories,
        sourceId: smartExerciseLog.id);
  }

  /// Factory constructor untuk membuat ExerciseLogHistoryItem dari WeightLifting model
  static Future<ExerciseLogHistoryItem> fromWeightliftingLog(
      WeightLifting weightLifting) async {
    // Calculate total sets, reps, and weight
    int totalSets = weightLifting.sets.length;

    // For empty sets, use zeroes with proper decimal formatting
    if (totalSets == 0) {
      return ExerciseLogHistoryItem(
        activityType: typeWeightlifting,
        title: weightLifting.name,
        subtitle: '0 minutes • 0 cal',
        timestamp: weightLifting.timestamp,
        caloriesBurned: 0,
        sourceId: weightLifting.id,
      );
    }

    // Calculate total duration in minutes
    double totalDurationInMinutes =
        weightLifting.sets.fold(0.0, (sum, set) => sum + set.duration);

    // Calculate calories burned using workout service (await the Future)
    double caloriesValue = await calculateExerciseCalories(weightLifting);
    int caloriesBurned = caloriesValue.round();

    return ExerciseLogHistoryItem(
      activityType: typeWeightlifting,
      title: weightLifting.name,
      subtitle:
          '${totalDurationInMinutes.toStringAsFixed(0)} minutes • $caloriesBurned cal',
      timestamp: weightLifting.timestamp,
      caloriesBurned: caloriesBurned,
      sourceId: weightLifting.id,
    );
  }

  /// Factory constructor untuk membuat ExerciseLogHistoryItem dari CardioLog
  factory ExerciseLogHistoryItem.fromCardioLog(CardioActivity cardioLog) {
    // Mendapatkan tipe aktivitas yang lebih user-friendly
    String activityTitle;
    switch (cardioLog.type) {
      case CardioType.running:
        activityTitle = 'Running';
        break;
      case CardioType.cycling:
        activityTitle = 'Cycling';
        break;
      case CardioType.swimming:
        activityTitle = 'Swimming';
        break;
    }

    // Format durasi dalam format yang lebih user-friendly
    final minutes = cardioLog.duration.inMinutes;
    final durationText = minutes > 0
        ? '$minutes minutes'
        : '${cardioLog.duration.inSeconds} seconds';

    return ExerciseLogHistoryItem(
      activityType: typeCardio,
      title: activityTitle,
      subtitle: '$durationText • ${cardioLog.caloriesBurned.toInt()} cal',
      timestamp: cardioLog.date,
      caloriesBurned: cardioLog.caloriesBurned.toInt(),
      sourceId: cardioLog.id,
    );
  }
}
// coverage:ignore-end
