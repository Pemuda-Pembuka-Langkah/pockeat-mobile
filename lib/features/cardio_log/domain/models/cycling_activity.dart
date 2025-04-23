import '../../services/calorie_calculator.dart';
import 'cardio_activity.dart';

/// Enum untuk tipe aktivitas bersepeda
enum CyclingType { mountain, commute, stationary }

/// Model untuk aktivitas bersepeda
class CyclingActivity extends CardioActivity {
  final double distanceKm;
  final CyclingType cyclingType;

  CyclingActivity({
    super.id,
    required super.userId,
    required super.date,
    required super.startTime,
    required super.endTime,
    required this.distanceKm,
    required this.cyclingType,
    double? caloriesBurned,
  }) : super(
          caloriesBurned: caloriesBurned ?? 0.0,
          type: CardioType.cycling,
        );

  /// Mengkonversi CyclingType ke string untuk perhitungan kalori
  String get cyclingTypeString => cyclingType.toString().split('.').last;

  @override
  double calculateCalories() {
    return CalorieCalculator.calculateCyclingCalories(
      distanceKm: distanceKm,
      duration: duration,
      cyclingType: cyclingTypeString,
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
      'cyclingType': cyclingTypeString,
      'caloriesBurned': caloriesBurned,
      'type': 'cycling',
    };
  }

  /// Factory constructor dari Map (untuk parsing dari database)
  factory CyclingActivity.fromMap(Map<String, dynamic> map) {
    // Konversi string cyclingType ke enum
    CyclingType parsedType;
    switch (map['cyclingType']) {
      case 'mountain':
        parsedType = CyclingType.mountain;
        break;
      case 'commute':
        parsedType = CyclingType.commute;
        break;
      case 'stationary':
        parsedType = CyclingType.stationary;
        break;
      default:
        parsedType = CyclingType.mountain; // Default value
    }

    return CyclingActivity(
      id: map['id'],
      userId: map['userId'] ?? 'unknown-user-id',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      distanceKm: map['distanceKm']?.toDouble() ?? 0.0,
      cyclingType: parsedType,
      caloriesBurned: map['caloriesBurned']?.toDouble() ?? 0.0,
    );
  }

  /// Metode untuk membuat salinan dengan beberapa perubahan (immutability)
  CyclingActivity copyWith({
    String? id,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceKm,
    CyclingType? cyclingType,
    double? caloriesBurned,
  }) {
    return CyclingActivity(
      id: id ?? this.id,
      userId: userId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceKm: distanceKm ?? this.distanceKm,
      cyclingType: cyclingType ?? this.cyclingType,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
}
