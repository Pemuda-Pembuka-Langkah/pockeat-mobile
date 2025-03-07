import 'package:uuid/uuid.dart';
import 'package:pockeat/features/cardio_log/domain/models/cardio_activity.dart';

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
  final String? sourceId; // ID dari data sumber (misalnya ID dari SmartExerciseLog)
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
  factory ExerciseLogHistoryItem.fromSmartExerciseLog(dynamic smartExerciseLog) {
    return ExerciseLogHistoryItem(
      activityType: TYPE_SMART_EXERCISE,
      title: smartExerciseLog.exerciseType,
      subtitle: '${smartExerciseLog.duration} • ${smartExerciseLog.intensity}',
      timestamp: smartExerciseLog.timestamp,
      caloriesBurned: smartExerciseLog.estimatedCalories,
      sourceId: smartExerciseLog.id
    );
  }

  /// Factory constructor untuk membuat ExerciseLogHistoryItem dari WeightliftingLog (placeholder)
  factory ExerciseLogHistoryItem.fromWeightliftingLog(dynamic weightliftingLog) {
    // Implementasi akan ditambahkan saat WeightliftingLog tersedia
    return ExerciseLogHistoryItem(
      activityType: TYPE_WEIGHTLIFTING,
      title: weightliftingLog.exerciseName ?? 'Weightlifting Session',
      subtitle: '${weightliftingLog.sets ?? 0} sets • ${weightliftingLog.reps ?? 0} reps • ${weightliftingLog.weight ?? "0 kg"}',
      timestamp: weightliftingLog.timestamp,
      caloriesBurned: weightliftingLog.caloriesBurned ?? 0,
      sourceId: weightliftingLog.id,
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
    final durationText = minutes > 0 ? '$minutes min' : '${cardioLog.duration.inSeconds} sec';
    
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
