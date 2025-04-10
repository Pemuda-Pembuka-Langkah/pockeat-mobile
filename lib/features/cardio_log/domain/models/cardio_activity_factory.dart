import 'cardio_activity.dart';
import 'running_activity.dart';
import 'cycling_activity.dart';
import 'swimming_activity.dart';

/// Factory class untuk membuat objek CardioActivity dari berbagai sumber data
class CardioActivityFactory {
  /// Membuat CardioActivity dari Map (umumnya dari database)
  static CardioActivity fromMap(Map<String, dynamic> map) {
    final String activityType = map['type'] ?? '';
    
    switch (activityType) {
      case 'running':
        return RunningActivity.fromMap(map);
      
      case 'cycling':
        return CyclingActivity.fromMap(map);
      
      case 'swimming':
        return SwimmingActivity.fromMap(map);
      
      default:
        throw ArgumentError('Unknown cardio activity type: $activityType');
    }
  }
  
  /// Membuat CardioActivity dari form data yang dikumpulkan dari UI
  static CardioActivity fromFormData({
    required String userId,
    required CardioType type,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic> formData = const {},
  }) {
    switch (type) {
      case CardioType.running:
        return RunningActivity(
          userId: userId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          distanceKm: formData['distanceKm'] ?? 0.0,
        );
      
      case CardioType.cycling:
        return CyclingActivity(
          userId: userId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          distanceKm: formData['distanceKm'] ?? 0.0,
          cyclingType: _parseCyclingType(formData['cyclingType']),
        );
      
      case CardioType.swimming:
        return SwimmingActivity(
          userId: userId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          laps: formData['laps'] ?? 0,
          poolLength: formData['poolLength'] ?? 0.0,
          stroke: formData['stroke'] ?? 'Freestyle (Front Crawl)',
        );
    }
  }
  
  /// Helper method untuk mengkonversi string ke CyclingType
  static CyclingType _parseCyclingType(String? typeString) {
    switch (typeString) {
      case 'mountain':
        return CyclingType.mountain;
      case 'commute':
        return CyclingType.commute;
      case 'stationary':
        return CyclingType.stationary;
      default:
        return CyclingType.mountain;
    }
  }
} 