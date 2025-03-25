import 'weight_lifting.dart';

/// Factory class untuk membuat objek Exercise dari berbagai sumber data
class WeightLiftingFactory {
  /// Membuat Exercise dari Map (umumnya dari database)
  static WeightLifting fromMap(Map<String, dynamic> map) {
    return WeightLifting.fromJson(map);
  }
  
  /// Membuat Exercise dari form data yang dikumpulkan dari UI
  static WeightLifting fromFormData({
    required String name,
    required String bodyPart,
    required double metValue,
    required String userId,
    List<Map<String, dynamic>>? setsData,
  }) {
    List<WeightLiftingSet> sets = [];
    
    if (setsData != null && setsData.isNotEmpty) {
      for (var setData in setsData) {
        // Only create ExerciseSet if all required values are present and valid
        if (setData['weight'] != null && 
            setData['reps'] != null && 
            setData['duration'] != null) {
          
          final weight = setData['weight'];
          final reps = setData['reps'];
          final duration = setData['duration'];
          
          // Skip if any value is not positive
          if (weight <= 0 || reps <= 0 || duration <= 0) continue;
          
          sets.add(WeightLiftingSet(
            weight: weight,
            reps: reps,
            duration: duration,
          ));
        }
      }
    }
    
    return WeightLifting(
      name: name,
      bodyPart: bodyPart,
      metValue: metValue,
      userId: userId,
      sets: sets,
    );
  }
}