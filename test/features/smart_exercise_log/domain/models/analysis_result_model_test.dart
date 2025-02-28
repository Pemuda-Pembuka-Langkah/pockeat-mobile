import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

void main() {
  group('AnalysisResult', () {
    test('should create a valid model from constructor', () {
      // Arrange
      final timestamp = DateTime.now();

      // Act
      final model = ExerciseAnalysisResult(
        exerciseType: 'HIIT Workout',
        duration: '30 menit',
        intensity: 'Tinggi',
        estimatedCalories: 320,
        summary: 'Latihan intensitas tinggi dengan interval pendek',
        timestamp: timestamp,
        originalInput: 'Lari HIIT 30 menit',
      );

      // Assert
      expect(model.id, isNotNull);
      expect(model.id.length, greaterThan(0));
      expect(model.exerciseType, 'HIIT Workout');
      expect(model.duration, '30 menit');
      expect(model.intensity, 'Tinggi');
      expect(model.estimatedCalories, 320);
      expect(model.summary, 'Latihan intensitas tinggi dengan interval pendek');
      expect(model.timestamp, timestamp);
      expect(model.originalInput, 'Lari HIIT 30 menit');
      expect(model.isComplete, true);
    });

    test('should create model with provided ID', () {
      // Arrange
      final providedId = 'test-id-123';

      // Act
      final model = ExerciseAnalysisResult(
        id: providedId,
        exerciseType: 'HIIT Workout',
        duration: '30 menit',
        intensity: 'Tinggi',
        estimatedCalories: 320,
        timestamp: DateTime.now(),
        originalInput: 'Lari HIIT 30 menit',
      );

      // Assert
      expect(model.id, providedId);
    });

    test('should create model from map correctly', () {
      // Arrange
      final map = {
        'type': 'Yoga Session',
        'duration': '45 menit',
        'intensity': 'Sedang',
        'estimatedCalories': 150,
        'summary': 'Latihan yoga yang menenangkan',
      };
      final originalInput = 'Yoga 45 menit santai';

      // Act
      final model = ExerciseAnalysisResult.fromMap(map, originalInput);

      // Assert
      expect(model.id, isNotNull);
      expect(model.exerciseType, 'Yoga Session');
      expect(model.duration, '45 menit');
      expect(model.intensity, 'Sedang');
      expect(model.estimatedCalories, 150);
      expect(model.summary, 'Latihan yoga yang menenangkan');
      expect(model.originalInput, 'Yoga 45 menit santai');
      expect(model.isComplete, true);
    });

    test('should create model from map with provided ID', () {
      // Arrange
      final map = {
        'type': 'Yoga Session',
        'duration': '45 menit',
        'intensity': 'Sedang',
        'estimatedCalories': 150,
      };
      final originalInput = 'Yoga 45 menit santai';
      final providedId = 'custom-id-456';

      // Act
      final model =
          ExerciseAnalysisResult.fromMap(map, originalInput, id: providedId);

      // Assert
      expect(model.id, providedId);
    });

    test('should handle missing fields in map', () {
      // Arrange
      final map = {
        'type': 'Running',
        // duration missing
        'intensity': 'Sedang',
        'estimatedCalories': 200,
      };
      final originalInput = 'Lari dengan intensitas sedang';

      // Act
      final model = ExerciseAnalysisResult.fromMap(map, originalInput);

      // Assert
      expect(model.exerciseType, 'Running');
      expect(model.duration, 'Tidak ditentukan');
      expect(model.intensity, 'Sedang');
      expect(model.estimatedCalories, 200);
      expect(model.summary, null);
      expect(model.originalInput, 'Lari dengan intensitas sedang');
    });

    test('should create model from database map correctly', () {
      // Arrange
      final currentTime = DateTime.now();
      final timestamp = currentTime.millisecondsSinceEpoch;
      final map = {
        'exerciseType': 'Swimming',
        'duration': '60 menit',
        'intensity': 'Rendah',
        'estimatedCalories': 400,
        'summary': 'Berenang santai',
        'timestamp': timestamp,
        'originalInput': 'Berenang 1 jam santai',
      };
      final id = 'db-id-789';

      // Act
      final model = ExerciseAnalysisResult.fromDbMap(map, id);

      // Assert
      expect(model.id, id);
      expect(model.exerciseType, 'Swimming');
      expect(model.duration, '60 menit');
      expect(model.intensity, 'Rendah');
      expect(model.estimatedCalories, 400);
      expect(model.summary, 'Berenang santai');
      expect(model.timestamp.millisecondsSinceEpoch, timestamp);
      expect(model.originalInput, 'Berenang 1 jam santai');
    });

    test('should convert to map correctly', () {
      // Arrange
      final timestamp = DateTime.now();
      final model = ExerciseAnalysisResult(
        id: 'test-id-123',
        exerciseType: 'Swimming',
        duration: '60 menit',
        intensity: 'Rendah',
        estimatedCalories: 400,
        summary: 'Berenang santai',
        timestamp: timestamp,
        originalInput: 'Berenang 1 jam santai',
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(map['exerciseType'], 'Swimming');
      expect(map['duration'], '60 menit');
      expect(map['intensity'], 'Rendah');
      expect(map['estimatedCalories'], 400);
      expect(map['summary'], 'Berenang santai');
      expect(map['timestamp'], timestamp.millisecondsSinceEpoch);
      expect(map['originalInput'], 'Berenang 1 jam santai');
      expect(map['isComplete'], true);
      // ID should not be included in the map
      expect(map.containsKey('id'), false);
    });

    test('isComplete should be false when missingInfo is not empty', () {
      // Arrange
      final model = ExerciseAnalysisResult(
        exerciseType: 'Unknown Workout',
        duration: 'Tidak ditentukan',
        intensity: 'Tidak ditentukan',
        estimatedCalories: 0,
        timestamp: DateTime.now(),
        originalInput: 'Olahraga tadi pagi',
        missingInfo: ['type', 'duration', 'intensity'],
      );

      // Assert
      expect(model.isComplete, false);
    });

    test('copyWith should create a new instance with updated values', () {
      // Arrange
      final original = ExerciseAnalysisResult(
        id: 'original-id',
        exerciseType: 'Running',
        duration: '30 menit',
        intensity: 'Sedang',
        estimatedCalories: 300,
        timestamp: DateTime.now(),
        originalInput: 'Lari 30 menit',
      );

      // Act
      final updated = original.copyWith(
        exerciseType: 'Sprint',
        intensity: 'Tinggi',
        estimatedCalories: 400,
      );

      // Assert
      expect(updated.id, 'original-id'); // Unchanged
      expect(updated.exerciseType, 'Sprint'); // Changed
      expect(updated.duration, '30 menit'); // Unchanged
      expect(updated.intensity, 'Tinggi'); // Changed
      expect(updated.estimatedCalories, 400); // Changed
      expect(updated.timestamp, original.timestamp); // Unchanged
      expect(updated.originalInput, 'Lari 30 menit'); // Unchanged
    });
  });
}
