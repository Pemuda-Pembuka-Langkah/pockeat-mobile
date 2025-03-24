import '../../services/calorie_calculator.dart';
import 'cardio_activity.dart';

/// Model untuk aktivitas lari
class RunningActivity extends CardioActivity {
  final double distanceKm;

  RunningActivity({
    super.id,
    required super.userId,
    required super.date,
    required super.startTime,
    required super.endTime,
    required this.distanceKm,
    double? caloriesBurned,
  }) : super(
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
      'userId': userId,
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
      userId: map['userId'],
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
      userId: userId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
} 