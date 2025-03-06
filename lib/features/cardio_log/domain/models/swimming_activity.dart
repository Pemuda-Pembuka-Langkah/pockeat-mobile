import 'package:uuid/uuid.dart';
import '../../services/calorie_calculator.dart';
import 'cardio_activity.dart';

/// Model untuk aktivitas renang
class SwimmingActivity extends CardioActivity {
  final int laps;
  final double poolLength;
  final String stroke;

  SwimmingActivity({
    String? id,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required this.laps,
    required this.poolLength,
    required this.stroke,
    double? caloriesBurned,
  }) : super(
          id: id,
          date: date,
          startTime: startTime,
          endTime: endTime,
          caloriesBurned: caloriesBurned ?? 0.0,
          type: CardioType.swimming,
        );

  /// Menghitung total jarak yang ditempuh dalam meter
  double get totalDistance => laps * poolLength;

  @override
  double calculateCalories() {
    return CalorieCalculator.calculateSwimmingCalories(
      laps: laps,
      poolLength: poolLength,
      stroke: stroke,
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
      'laps': laps,
      'poolLength': poolLength,
      'stroke': stroke,
      'totalDistance': totalDistance,
      'caloriesBurned': caloriesBurned,
      'type': 'swimming',
    };
  }

  /// Factory constructor dari Map (untuk parsing dari database)
  factory SwimmingActivity.fromMap(Map<String, dynamic> map) {
    return SwimmingActivity(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      laps: map['laps'] ?? 0,
      poolLength: map['poolLength']?.toDouble() ?? 0.0,
      stroke: map['stroke'] ?? 'Freestyle (Front Crawl)',
      caloriesBurned: map['caloriesBurned']?.toDouble() ?? 0.0,
    );
  }
  
  /// Metode untuk membuat salinan dengan beberapa perubahan (immutability)
  SwimmingActivity copyWith({
    String? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? laps,
    double? poolLength,
    String? stroke,
    double? caloriesBurned,
  }) {
    return SwimmingActivity(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      laps: laps ?? this.laps,
      poolLength: poolLength ?? this.poolLength,
      stroke: stroke ?? this.stroke,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
} 