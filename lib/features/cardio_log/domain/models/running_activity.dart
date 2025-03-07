import 'package:uuid/uuid.dart';
import '../../services/calorie_calculator.dart';
import 'cardio_activity.dart';

/// Model untuk aktivitas lari
class RunningActivity extends CardioActivity {
  final double distanceKm;

  RunningActivity({
    String? id,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required this.distanceKm,
    double? caloriesBurned,
  }) : super(
          id: id,
          date: date,
          startTime: startTime,
          endTime: endTime,
          caloriesBurned: caloriesBurned ?? 0.0,
          type: CardioType.running,
        );

  @override
  double calculateCalories() {
    return CalorieCalculator.calculateRunningCalories(
      distanceKm: distanceKm,
      duration: duration,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'duration': duration.inSeconds,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
      'type': 'running',
    };
  }

  /// Factory constructor dari Map (untuk parsing dari database)
  factory RunningActivity.fromMap(Map<String, dynamic> map) {
    return RunningActivity(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      distanceKm: map['distanceKm']?.toDouble() ?? 0.0,
      caloriesBurned: map['caloriesBurned']?.toDouble() ?? 0.0,
    );
  }
  
  /// Metode untuk membuat salinan dengan beberapa perubahan (immutability)
  RunningActivity copyWith({
    String? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceKm,
    double? caloriesBurned,
  }) {
    return RunningActivity(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
} 