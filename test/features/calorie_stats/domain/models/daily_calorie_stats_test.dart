// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'daily_calorie_stats_test.mocks.dart';

@GenerateMocks([DocumentSnapshot])
void main() {
  group('DailyCalorieStats', () {
    test('constructor should set all properties correctly', () {
      // Arrange
      const String id = 'test-id';
      const String userId = 'test-user';
      final DateTime date = DateTime(2023, 4, 15);
      const int caloriesBurned = 500;
      const int caloriesConsumed = 1800;

      // Act
      final stats = DailyCalorieStats(
        id: id,
        userId: userId,
        date: date,
        caloriesBurned: caloriesBurned,
        caloriesConsumed: caloriesConsumed,
      );

      // Assert
      expect(stats.id, equals(id));
      expect(stats.userId, equals(userId));
      expect(stats.date, equals(date));
      expect(stats.caloriesBurned, equals(caloriesBurned));
      expect(stats.caloriesConsumed, equals(caloriesConsumed));
      expect(stats.netCalories, equals(caloriesConsumed - caloriesBurned));
    });

    test('constructor should generate id when not provided', () {
      // Arrange
      const String userId = 'test-user';
      final DateTime date = DateTime(2023, 4, 15);
      const int caloriesBurned = 500;
      const int caloriesConsumed = 1800;

      // Act
      final stats = DailyCalorieStats(
        userId: userId,
        date: date,
        caloriesBurned: caloriesBurned,
        caloriesConsumed: caloriesConsumed,
      );

      // Assert
      expect(stats.id, isNotNull);
      expect(stats.id, isNotEmpty);
    });

    test('toMap should return correct Map representation', () {
      // Arrange
      const String id = 'test-id';
      const String userId = 'test-user';
      final DateTime date = DateTime(2023, 4, 15);
      const int caloriesBurned = 500;
      const int caloriesConsumed = 1800;
      final stats = DailyCalorieStats(
        id: id,
        userId: userId,
        date: date,
        caloriesBurned: caloriesBurned,
        caloriesConsumed: caloriesConsumed,
      );

      // Act
      final map = stats.toMap();

      // Assert
      expect(map['userId'], equals(userId));
      expect(map['date'], isA<Timestamp>());
      expect((map['date'] as Timestamp).toDate().year, equals(date.year));
      expect((map['date'] as Timestamp).toDate().month, equals(date.month));
      expect((map['date'] as Timestamp).toDate().day, equals(date.day));
      expect(map['caloriesBurned'], equals(caloriesBurned));
      expect(map['caloriesConsumed'], equals(caloriesConsumed));
      expect(map['netCalories'], equals(caloriesConsumed - caloriesBurned));
    });

    test('fromFirestore should create instance from DocumentSnapshot', () {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      final Map<String, dynamic> testData = {
        'userId': 'test-user',
        'date': Timestamp.fromDate(DateTime(2023, 4, 15)),
        'caloriesBurned': 500,
        'caloriesConsumed': 1800,
      };
      when(mockSnapshot.id).thenReturn('doc-id');
      when(mockSnapshot.data()).thenReturn(testData);

      // Act
      final stats = DailyCalorieStats.fromFirestore(mockSnapshot);

      // Assert
      expect(stats.id, equals('doc-id'));
      expect(stats.userId, equals('test-user'));
      expect(stats.date.year, equals(2023));
      expect(stats.date.month, equals(4));
      expect(stats.date.day, equals(15));
      expect(stats.caloriesBurned, equals(500));
      expect(stats.caloriesConsumed, equals(1800));
      expect(stats.netCalories, equals(1300));
    });

    test('netCalories should be calculated correctly', () {
      // Arrange & Act
      final stats1 = DailyCalorieStats(
        userId: 'user1',
        date: DateTime.now(),
        caloriesBurned: 500,
        caloriesConsumed: 1800,
      );

      final stats2 = DailyCalorieStats(
        userId: 'user2',
        date: DateTime.now(),
        caloriesBurned: 300,
        caloriesConsumed: 2000,
      );

      final stats3 = DailyCalorieStats(
        userId: 'user3',
        date: DateTime.now(),
        caloriesBurned: 1000,
        caloriesConsumed: 1000,
      );

      // Assert
      expect(stats1.netCalories, equals(1300));
      expect(stats2.netCalories, equals(1700));
      expect(stats3.netCalories, equals(0));
    });
  });
}
