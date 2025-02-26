import 'package:flutter_test/flutter_test.dart';


void main() {
  group('AnalysisResult', () {
    test('should create a valid model from constructor', () {
      // Arrange
      final timestamp = DateTime.now();
      
      // Act
      final model = AnalysisResult(
        exerciseType: 'HIIT Workout',
        duration: '30 menit',
        intensity: 'Tinggi',
        estimatedCalories: 320,
        summary: 'Latihan intensitas tinggi dengan interval pendek',
        timestamp: timestamp,
        originalInput: 'Lari HIIT 30 menit',
      );
      
      // Assert
      expect(model.exerciseType, 'HIIT Workout');
      expect(model.duration, '30 menit');
      expect(model.intensity, 'Tinggi');
      expect(model.estimatedCalories, 320);
      expect(model.summary, 'Latihan intensitas tinggi dengan interval pendek');
      expect(model.timestamp, timestamp);
      expect(model.originalInput, 'Lari HIIT 30 menit');
      expect(model.isComplete, true);
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
      final model = AnalysisResult.fromMap(map, originalInput);
      
      // Assert
      expect(model.exerciseType, 'Yoga Session');
      expect(model.duration, '45 menit');
      expect(model.intensity, 'Sedang');
      expect(model.estimatedCalories, 150);
      expect(model.summary, 'Latihan yoga yang menenangkan');
      expect(model.originalInput, 'Yoga 45 menit santai');
      expect(model.isComplete, true);
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
      final model = AnalysisResult.fromMap(map, originalInput);
      
      // Assert
      expect(model.exerciseType, 'Running');
      expect(model.duration, 'Tidak ditentukan');
      expect(model.intensity, 'Sedang');
      expect(model.estimatedCalories, 200);
      expect(model.summary, null);
      expect(model.originalInput, 'Lari dengan intensitas sedang');
    });

    test('should convert to map correctly', () {
      // Arrange
      final timestamp = DateTime.now();
      final model = AnalysisResult(
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
    });


    test('isComplete should be false when missingInfo is not empty', () {
      // Arrange
      final model = AnalysisResult(
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
  });
}