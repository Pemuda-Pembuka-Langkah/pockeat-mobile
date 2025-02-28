// // test/pockeat/features/ai_api_scan/models/exercise_analysis_test.dart
// import 'package:flutter_test/flutter_test.dart';
// import 'package:pockeat/features/ai_api_scan/models/exercise_analysis.dart';

// void main() {
//   group('ExerciseAnalysisResult Model', () {
//     test('should create ExerciseAnalysisResult from JSON', () {
//       // Arrange
//       final json = {
//         'exercise_type': 'Running',
//         'calories_burned': 350,
//         'duration_minutes': 30,
//         'intensity_level': 'Moderate',
//         'met_value': 7.0
//       };
      
//       // Act
//       final result = ExerciseAnalysisResult.fromJson(json);
      
//       // Assert
//       expect(result.exerciseType, 'Running');
//       expect(result.caloriesBurned, 350);
//       expect(result.durationMinutes, 30);
//       expect(result.intensityLevel, 'Moderate');
//       expect(result.metValue, 7.0);
//     });
    
//     test('should handle missing optional fields', () {
//       // Arrange
//       final json = {
//         'exercise_type': 'Running',
//         'calories_burned': 350,
//         'duration_minutes': 30
//         // Missing intensity_level and met_value
//       };
      
//       // Act
//       final result = ExerciseAnalysisResult.fromJson(json);
      
//       // Assert
//       expect(result.intensityLevel, '');
//       expect(result.metValue, 0.0);
//     });
//   });
// }