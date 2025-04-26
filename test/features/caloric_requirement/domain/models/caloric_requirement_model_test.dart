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
        timestamp: now,
      );

      expect(model.userId, equals('user123'));
      expect(model.bmr, equals(1500.0));
      expect(model.tdee, equals(2000.0));
      expect(model.timestamp, equals(now));
    });

    test('toMap returns correct values', () {
      final now = DateTime(2024, 4, 12, 10);
      final model = CaloricRequirementModel(
        userId: 'user456',
        bmr: 1600.0,
        tdee: 2100.0,
        timestamp: now,
      );

      final map = model.toMap();

      expect(map['userId'], equals('user456'));
      expect(map['bmr'], equals(1600.0));
      expect(map['tdee'], equals(2100.0));
      expect(map['timestamp'], equals(now.toIso8601String()));
    });

    test('fromFirestore creates valid model', () {
      final mockData = {
        'userId': 'test-user',
        'bmr': 1450.0,
        'tdee': 1900.0,
        'timestamp': DateTime(2024, 1, 1).toIso8601String(),
      };

      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(mockData);
      when(() => snapshot.id).thenReturn('test-user');
      
      final model = CaloricRequirementModel.fromFirestore(snapshot);

      expect(model.userId, equals('test-user'));
      expect(model.bmr, equals(1450.0));
      expect(model.tdee, equals(1900.0));
      expect(model.timestamp, equals(DateTime(2024, 1, 1)));
    });

    test('fromFirestore throws when data is null', () {
      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(null);

      expect(() => CaloricRequirementModel.fromFirestore(snapshot), throwsException);
    });

    test('fromFirestore parses numeric fields correctly', () {
      final mockData = {
        'userId': 'user-id',
        'bmr': 1350,       // int
        'tdee': 1800.5,    // double
        'timestamp': DateTime(2024, 1, 1).toIso8601String(),
      };

      final snapshot = MockDocumentSnapshot();
      when(() => snapshot.data()).thenReturn(mockData);
      when(() => snapshot.id).thenReturn('user-id');

      final model = CaloricRequirementModel.fromFirestore(snapshot);

      expect(model.bmr, equals(1350.0));
      expect(model.tdee, equals(1800.5));
    });

    test('toMap has correct value types', () {
      final model = CaloricRequirementModel(
        userId: 'test-user',
        bmr: 1700.25,
        tdee: 2200.75,
        timestamp: DateTime.now(),
      );

      final map = model.toMap();

      expect(map['bmr'], isA<double>());
      expect(map['tdee'], isA<double>());
      expect(map['userId'], isA<String>());
      expect(map['timestamp'], isA<String>());
    });
  });
}
