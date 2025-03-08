import 'exercise.dart';

/// Factory class untuk membuat objek Exercise dari berbagai sumber data
class ExerciseFactory {
  /// Membuat Exercise dari Map (umumnya dari database)
  static Exercise fromMap(Map<String, dynamic> map) {
    return Exercise.fromJson(map);
  }
  
  /// Membuat Exercise dari form data yang dikumpulkan dari UI
  static Exercise fromFormData({
    required String name,
    required String bodyPart,
    required double metValue,
    List<Map<String, dynamic>>? setsData,
  }) {
    List<ExerciseSet> sets = [];
    
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
          
          sets.add(ExerciseSet(
            weight: weight,
            reps: reps,
            duration: duration,
          ));
        }
      }
    }
    
    return Exercise(
      name: name,
      bodyPart: bodyPart,
      metValue: metValue,
      sets: sets,
    );
  }
}