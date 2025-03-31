import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

void main() {
  group('ExerciseAnalysisResult', () {
    test('should create a valid model from constructor', () {
      // Arrange
      final timestamp = DateTime.now();

      // Act
      final model = ExerciseAnalysisResult(
        exerciseType: 'HIIT Workout',
        duration: '30 minutes',
        intensity: 'High',
        estimatedCalories: 320,
        metValue: 8.5,
        summary: 'High-intensity training with short intervals',
        timestamp: timestamp,
        originalInput: 'HIIT run 30 minutes',
        userId: 'test-user-123',
      );

      // Assert
      expect(model.id, isNotNull);
      expect(model.id.length, greaterThan(0));
      expect(model.exerciseType, 'HIIT Workout');
      expect(model.duration, '30 minutes');
      expect(model.intensity, 'High');
      expect(model.estimatedCalories, 320);
      expect(model.metValue, 8.5);
      expect(model.summary, 'High-intensity training with short intervals');
      expect(model.timestamp, timestamp);
      expect(model.originalInput, 'HIIT run 30 minutes');
      expect(model.isComplete, true);
    });

    test('should create model with provided ID', () {
      // Arrange
      final providedId = 'test-id-123';

      // Act
      final model = ExerciseAnalysisResult(
        id: providedId,
        exerciseType: 'HIIT Workout',
        duration: '30 minutes',
        intensity: 'High',
        estimatedCalories: 320,
        metValue: 8.5,
        timestamp: DateTime.now(),
        originalInput: 'HIIT run 30 minutes',
        userId: 'test-user-123',
      );

      // Assert
      expect(model.id, providedId);
      expect(model.metValue, 8.5);
    });

    test('should use default value for metValue when not provided', () {
      // Act
      final model = ExerciseAnalysisResult(
        exerciseType: 'Jogging',
        duration: '20 minutes',
        intensity: 'Medium',
        estimatedCalories: 200,
        timestamp: DateTime.now(),
        originalInput: 'Jogging 20 minutes',
        userId: 'test-user-123',
      );

      // Assert
      expect(model.metValue, 0.0);
    });

    test('should create model from database map correctly', () {
      // Arrange
      final currentTime = DateTime.now();
      final timestamp = currentTime.millisecondsSinceEpoch;
      final map = {
        'exerciseType': 'Swimming',
        'duration': '60 minutes',
        'intensity': 'Low',
        'estimatedCalories': 400,
        'metValue': 6.0,
        'summary': 'Easy swimming',
        'timestamp': timestamp,
        'originalInput': 'Swimming 1 hour easy',
      };
      final id = 'db-id-789';

      // Act
      final model = ExerciseAnalysisResult.fromDbMap(map, id);

      // Assert
      expect(model.id, id);
      expect(model.exerciseType, 'Swimming');
      expect(model.duration, '60 minutes');
      expect(model.intensity, 'Low');
      expect(model.estimatedCalories, 400);
      expect(model.metValue, 6.0);
      expect(model.summary, 'Easy swimming');
      expect(model.timestamp.millisecondsSinceEpoch, timestamp);
      expect(model.originalInput, 'Swimming 1 hour easy');
    });

    test('should handle missing metValue in database map', () {
      // Arrange
      final map = {
        'exerciseType': 'Swimming',
        'duration': '60 minutes',
        'intensity': 'Low',
        'estimatedCalories': 400,
        // metValue missing
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'originalInput': 'Swimming 1 hour easy',
      };
      final id = 'db-id-789';

      // Act
      final model = ExerciseAnalysisResult.fromDbMap(map, id);

      // Assert
      expect(model.metValue, 0.0); // Should use default value
    });

    test('should handle missing fields in database map with default values', () {
      // Arrange
      final map = {
        // Missing most fields to test defaults
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final id = 'default-test-id';

      // Act
      final model = ExerciseAnalysisResult.fromDbMap(map, id);

      // Assert
      expect(model.id, id);
      expect(model.exerciseType, 'Unknown');
      expect(model.duration, 'Tidak ditentukan'); // Note: still uses Indonesian in the model
      expect(model.intensity, 'Tidak ditentukan'); // Note: still uses Indonesian in the model
      expect(model.estimatedCalories, 0);
      expect(model.metValue, 0.0);
      expect(model.summary, null);
      expect(model.originalInput, '');
    });
    
    test('should handle null timestamp in database map by using current time', () {
      // Arrange
      final before = DateTime.now();
      final map = {
        'exerciseType': 'Running',
        'duration': '45 minutes',
        // timestamp is null or missing
      };
      final id = 'timestamp-test-id';

      // Act
      final model = ExerciseAnalysisResult.fromDbMap(map, id);
      final after = DateTime.now();

      // Assert
      expect(model.timestamp.isAfter(before) || model.timestamp.isAtSameMomentAs(before), true);
      expect(model.timestamp.isBefore(after) || model.timestamp.isAtSameMomentAs(after), true);
    });

    test('should convert to map correctly with metValue', () {
      // Arrange
      final timestamp = DateTime.now();
      final model = ExerciseAnalysisResult(
        id: 'test-id-123',
        exerciseType: 'Swimming',
        duration: '60 minutes',
        intensity: 'Low',
        estimatedCalories: 400,
        metValue: 6.0,
        summary: 'Easy swimming',
        timestamp: timestamp,
        originalInput: 'Swimming 1 hour easy',
        userId: 'test-user-123',
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(map['exerciseType'], 'Swimming');
      expect(map['duration'], '60 minutes');
      expect(map['intensity'], 'Low');
      expect(map['estimatedCalories'], 400);
      expect(map['metValue'], 6.0);
      expect(map['summary'], 'Easy swimming');
      expect(map['timestamp'], timestamp.millisecondsSinceEpoch);
      expect(map['originalInput'], 'Swimming 1 hour easy');
      expect(map['isComplete'], true);
      // ID should not be included in the map
      expect(map.containsKey('id'), false);
    });

    test('isComplete should be false when missingInfo is not empty', () {
      // Arrange
      final model = ExerciseAnalysisResult(
        exerciseType: 'Unknown Workout',
        duration: 'Not specified',
        intensity: 'Not specified',
        estimatedCalories: 0,
        metValue: 0.0,
        timestamp: DateTime.now(),
        originalInput: 'Exercise this morning',
        missingInfo: ['type', 'duration', 'intensity'],
        userId: 'test-user-123',
      );

      // Assert
      expect(model.isComplete, false);
    });

    test('copyWith should create a new instance with updated values including metValue', () {
      // Arrange
      final original = ExerciseAnalysisResult(
        id: 'original-id',
        exerciseType: 'Running',
        duration: '30 minutes',
        intensity: 'Medium',
        estimatedCalories: 300,
        metValue: 7.0,
        timestamp: DateTime.now(),
        originalInput: 'Running 30 minutes',
        userId: 'test-user-123',
      );

      // Act
      final updated = original.copyWith(
        exerciseType: 'Sprint',
        intensity: 'High',
        estimatedCalories: 400,
        metValue: 10.0,
      );

      // Assert
      expect(updated.id, 'original-id'); // Unchanged
      expect(updated.exerciseType, 'Sprint'); // Changed
      expect(updated.duration, '30 minutes'); // Unchanged
      expect(updated.intensity, 'High'); // Changed
      expect(updated.estimatedCalories, 400); // Changed
      expect(updated.metValue, 10.0); // Changed
      expect(updated.timestamp, original.timestamp); // Unchanged
      expect(updated.originalInput, 'Running 30 minutes'); // Unchanged
    });
    
    test('copyWith should update summary and missingInfo correctly', () {
      // Arrange
      final original = ExerciseAnalysisResult(
        exerciseType: 'Yoga',
        duration: '45 minutes',
        intensity: 'Low',
        estimatedCalories: 150,
        timestamp: DateTime.now(),
        originalInput: 'Yoga 45 minutes',
        userId: 'test-user-123',
      );

      // Act
      final updated = original.copyWith(
        summary: 'Relaxing yoga session',
        missingInfo: ['intensity'],
      );

      // Assert
      expect(updated.summary, 'Relaxing yoga session');
      expect(updated.missingInfo, ['intensity']);
      expect(updated.isComplete, false);
    });
    
    // Tambahan test untuk meningkatkan coverage
    
    test('fromMap should handle missingInfo correctly', () {
      // Arrange
      final map = {
        'type': 'Walking',
        'duration': '30 minutes',
        'estimatedCalories': 200,
        'missingInfo': ['intensity']
      };
      final id = 'map-test-id';
      
      // Act
      final model = ExerciseAnalysisResult.fromDbMap(map, id);
      
      // Assert
      expect(model.missingInfo, ['intensity']);
      expect(model.isComplete, false);
    });
    
    test('fromDbMap should handle missingInfo correctly when provided', () {
      // Arrange
      final map = {
        'exerciseType': 'Cycling',
        'duration': '45 minutes',
        'intensity': 'Medium',
        'estimatedCalories': 300,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'originalInput': 'Cycling 45 minutes',
        'missingInfo': ['intensity', 'duration']
      };
      final id = 'dbmap-test-id';
      
      // Act
      final model = ExerciseAnalysisResult.fromDbMap(map, id);
      
      // Assert
      expect(model.missingInfo, ['intensity', 'duration']);
      expect(model.isComplete, false);
    });
    
    test('should copy with all parameters', () {
      // Arrange
      final original = ExerciseAnalysisResult(
        id: 'original-id',
        exerciseType: 'Running',
        duration: '30 minutes',
        intensity: 'Medium',
        estimatedCalories: 300,
        metValue: 7.0,
        summary: 'Original summary',
        timestamp: DateTime.now(),
        originalInput: 'Running 30 minutes',
        missingInfo: ['intensity'],
        userId: 'test-user-123',
      );
      
      final newTime = DateTime.now().add(Duration(days: 1));
      
      // Act
      final updated = original.copyWith(
        id: 'new-id',
        exerciseType: 'Sprint',
        duration: '15 minutes',
        intensity: 'High',
        estimatedCalories: 250,
        metValue: 9.0,
        summary: 'New summary',
        timestamp: newTime,
        originalInput: 'Sprint 15 minutes',
        missingInfo: [],
      );
      
      // Assert
      expect(updated.id, 'new-id');
      expect(updated.exerciseType, 'Sprint');
      expect(updated.duration, '15 minutes');
      expect(updated.intensity, 'High');
      expect(updated.estimatedCalories, 250);
      expect(updated.metValue, 9.0);
      expect(updated.summary, 'New summary');
      expect(updated.timestamp, newTime);
      expect(updated.originalInput, 'Sprint 15 minutes');
      expect(updated.missingInfo, []);
      expect(updated.isComplete, true);
    });
    
    test('fromJson should parse JSON data correctly', () {
      // Arrange
      final jsonData = {
        'exerciseType': 'Running',
        'duration': '30 minutes',
        'intensity': 'High',
        'estimatedCalories': 350,
        'metValue': 8.0,
        'originalInput': 'Running 30 minutes high intensity',
        'timestamp': DateTime.now().millisecondsSinceEpoch
      };

      // Act & Assert
      expectLater(
        ExerciseAnalysisResult.fromJson(jsonData),
        completion(isA<ExerciseAnalysisResult>()
          .having((e) => e.exerciseType, 'exerciseType', 'Running')
          .having((e) => e.duration, 'duration', '30 minutes')
          .having((e) => e.intensity, 'intensity', 'High')
          .having((e) => e.estimatedCalories, 'estimatedCalories', 350)
          .having((e) => e.metValue, 'metValue', 8.0)
        )
      );
    });
    
    test('fromJson should throw ArgumentError when JSON is null', () {
      // Act & Assert
      expect(
        () => ExerciseAnalysisResult.fromJson(null),
        throwsArgumentError
      );
    });
  });
}