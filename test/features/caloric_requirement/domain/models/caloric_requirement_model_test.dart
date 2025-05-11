// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';

// Mock class using mocktail
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('CaloricRequirementModel', () {
    test('Constructor creates valid instance', () {
      final now = DateTime.now();
      final model = CaloricRequirementModel(
        userId: 'user123',
        bmr: 1500.0,
        tdee: 2000.0,
        proteinGrams: 150.0,
        carbsGrams: 200.0,
        fatGrams: 66.7,
        timestamp: now,
      );

      expect(model.userId, equals('user123'));
      expect(model.bmr, equals(1500.0));
      expect(model.tdee, equals(2000.0));
      expect(model.proteinGrams, equals(150.0));
      expect(model.carbsGrams, equals(200.0));
      expect(model.fatGrams, equals(66.7));
      expect(model.timestamp, equals(now));
    });

    test('toMap returns correct values', () {
      final now = DateTime(2024, 4, 12, 10);
      final model = CaloricRequirementModel(
        userId: 'user456',
        bmr: 1600.0,
        tdee: 2100.0,
        proteinGrams: 160.0,
        carbsGrams: 210.0,
        fatGrams: 70.0,
        timestamp: now,
      );

      final map = model.toMap();

      expect(map['userId'], equals('user456'));
      expect(map['bmr'], equals(1600.0));
      expect(map['tdee'], equals(2100.0));
      expect(map['proteinGrams'], equals(160.0));
      expect(map['carbsGrams'], equals(210.0));
      expect(map['fatGrams'], equals(70.0));
      expect(map['timestamp'], equals(now.toIso8601String()));
    });

    test('fromFirestore creates valid model', () {
      final mockData = {
        'bmr': 1450.0,
        'tdee': 1900.0,
        'proteinGrams': 140.0,
        'carbsGrams': 190.0,
        'fatGrams': 63.3,
        'timestamp': DateTime(2024, 1, 1).toIso8601String(),
      };

      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(mockData);
      when(() => snapshot.id).thenReturn('test-user');

      final model = CaloricRequirementModel.fromFirestore(snapshot);

      expect(model.userId, equals('test-user'));
      expect(model.bmr, equals(1450.0));
      expect(model.tdee, equals(1900.0));
      expect(model.proteinGrams, equals(140.0));
      expect(model.carbsGrams, equals(190.0));
      expect(model.fatGrams, equals(63.3));
      expect(model.timestamp, equals(DateTime(2024, 1, 1)));
    });

    test('fromFirestore throws when data is null', () {
      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(null);

      expect(() => CaloricRequirementModel.fromFirestore(snapshot), throwsException);
    });

    test('fromFirestore parses numeric fields correctly', () {
      final mockData = {
        'bmr': 1350,       // int
        'tdee': 1800.5,    // double
        'proteinGrams': 135,
        'carbsGrams': 180.5,
        'fatGrams': 60,
        'timestamp': DateTime(2024, 1, 1).toIso8601String(),
      };

      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(mockData);
      when(() => snapshot.id).thenReturn('user-id');

      final model = CaloricRequirementModel.fromFirestore(snapshot);

      expect(model.bmr, equals(1350.0));
      expect(model.tdee, equals(1800.5));
      expect(model.proteinGrams, equals(135.0));
      expect(model.carbsGrams, equals(180.5));
      expect(model.fatGrams, equals(60.0));
    });

    test('toMap has correct value types', () {
      final model = CaloricRequirementModel(
        userId: 'test-user',
        bmr: 1700.25,
        tdee: 2200.75,
        proteinGrams: 165.5,
        carbsGrams: 245.3,
        fatGrams: 73.6,
        timestamp: DateTime.now(),
      );

      final map = model.toMap();

      expect(map['bmr'], isA<double>());
      expect(map['tdee'], isA<double>());
      expect(map['proteinGrams'], isA<double>());
      expect(map['carbsGrams'], isA<double>());
      expect(map['fatGrams'], isA<double>());
      expect(map['userId'], isA<String>());
      expect(map['timestamp'], isA<String>());
    });
  });
}