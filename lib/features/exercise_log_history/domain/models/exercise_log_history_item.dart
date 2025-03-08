import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';
import 'package:uuid/uuid.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

/// Model untuk item history log olahraga
///
/// Model ini didesain untuk menyatukan berbagai jenis aktivitas olahraga
/// (SmartExercise, Weightlifting, Cardio) dalam satu format yang konsisten
/// untuk ditampilkan di history log.
class ExerciseLogHistoryItem {
  final String id;
  final String activityType; // Diganti dari enum menjadi string
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final int caloriesBurned;
  final String?
      sourceId; // ID dari data sumber (misalnya ID dari SmartExerciseLog)
  // Konstanta untuk tipe aktivitas umum
  static const String TYPE_SMART_EXERCISE = 'smart_exercise';
  static const String TYPE_WEIGHTLIFTING = 'weightlifting';
  static const String TYPE_CARDIO = 'cardio';
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
        activityType: TYPE_SMART_EXERCISE,
        title: smartExerciseLog.exerciseType,
        subtitle:
            '${smartExerciseLog.duration} • ${smartExerciseLog.intensity}',
        timestamp: smartExerciseLog.timestamp,
        caloriesBurned: smartExerciseLog.estimatedCalories,
        sourceId: smartExerciseLog.id);
  }

  /// Factory constructor untuk membuat ExerciseLogHistoryItem dari WeightLifting model
  factory ExerciseLogHistoryItem.fromWeightliftingLog(WeightLifting weightLifting) {
    // Calculate total sets, reps, and weight
    int totalSets = weightLifting.sets.length;
    
    // For empty sets, use zeroes with proper decimal formatting
    if (totalSets == 0) {
      return ExerciseLogHistoryItem(
        activityType: TYPE_WEIGHTLIFTING,
        title: weightLifting.name,
        subtitle: '0 sets • 0 reps • 0.0 kg',
        timestamp: DateTime.now(), // Since timestamp isn't in the model, use current time
        caloriesBurned: 0,
        sourceId: weightLifting.id,
      );
    }
    
    // Calculate total reps and average weight for multiple sets
    int totalReps = weightLifting.sets.fold(0, (sum, set) => sum + set.reps);
    double avgWeight = weightLifting.sets.fold(0.0, (sum, set) => sum + set.weight) / totalSets;
    
    // Calculate calories burned based on MET value, duration, and weight
    // Formula: Calories = MET value × weight (kg) × duration (hours)
    double totalDuration = weightLifting.sets.fold(0.0, (sum, set) => sum + set.duration);
    double durationInHours = totalDuration / 60; // Assuming duration is in minutes
    double standardWeight = 70.0; // Default weight assumption
    int caloriesBurned = (weightLifting.metValue * standardWeight * durationInHours).round();
    
    return ExerciseLogHistoryItem(
      activityType: TYPE_WEIGHTLIFTING,
      title: weightLifting.name,
      subtitle: '$totalSets sets • $totalReps reps • ${avgWeight.toStringAsFixed(1)} kg',
      timestamp: DateTime.now(), // Since timestamp isn't in the model, use current time
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
      default:
        activityTitle = 'Cardio Session';
    }

    // Format durasi dalam format yang lebih user-friendly
    final minutes = cardioLog.duration.inMinutes;
    final durationText =
        minutes > 0 ? '$minutes min' : '${cardioLog.duration.inSeconds} sec';

    // Get distance if available (using dynamic access since it might be in different implementations)
    String distanceText = '';
    try {
      final distance = cardioLog.toMap()['distance'];
      if (distance != null) {
        distanceText = ' • ${distance.toString()} km';
      }
    } catch (_) {
      // If distance is not available, just ignore it
    }

    return ExerciseLogHistoryItem(
      activityType: TYPE_CARDIO,
      title: activityTitle,
      subtitle: '$durationText$distanceText',
      timestamp: cardioLog.date,
      caloriesBurned: cardioLog.caloriesBurned.toInt(),
      sourceId: cardioLog.id,
    );
  }

  /// Factory dari Map (untuk parsing response dari database)
  factory ExerciseLogHistoryItem.fromMap(Map<String, dynamic> map, String id) {
    return ExerciseLogHistoryItem(
      id: id,
      activityType: map['activityType'] ?? TYPE_SMART_EXERCISE,
      title: map['title'] ?? 'Unknown Exercise',
      subtitle: map['subtitle'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      caloriesBurned: map['caloriesBurned'] ?? 0,
      sourceId: map['sourceId'],
    );
  }

  /// Konversi ke Map (untuk penyimpanan)
  Map<String, dynamic> toMap() {
    return {
      'activityType': activityType,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'caloriesBurned': caloriesBurned,
      'sourceId': sourceId,
    };
  }
}
