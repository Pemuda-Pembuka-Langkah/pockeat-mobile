import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final Map<String, dynamic>? _data;

  MockDocumentSnapshot(this._data);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => 'test-uid';
}

void main() {
  group('HealthMetricsModel', () {
    test('Constructor should create a valid HealthMetricsModel', () {
      final metrics = HealthMetricsModel(
        userId: 'test-uid',
        height: 175.0,
        weight: 72.5,
        age: 25,
        gender: 'male',
        activityLevel: 'moderate',
        fitnessGoal: 'Lose weight',
      );

      expect(metrics.userId, equals('test-uid'));
      expect(metrics.height, equals(175.0));
      expect(metrics.weight, equals(72.5));
      expect(metrics.age, equals(25));
      expect(metrics.gender, equals('male'));
      expect(metrics.activityLevel, equals('moderate'));
      expect(metrics.fitnessGoal, equals('Lose weight'));
    });

    test('toMap should convert HealthMetricsModel to a Map', () {
      final metrics = HealthMetricsModel(
        userId: 'test-uid',
        height: 175.0,
        weight: 72.5,
        age: 25,
        gender: 'female',
        activityLevel: 'active',
        fitnessGoal: 'Lose weight',
      );

      final map = metrics.toMap();

      expect(map['userId'], equals('test-uid'));
      expect(map['height'], equals(175.0));
      expect(map['weight'], equals(72.5));
      expect(map['age'], equals(25));
      expect(map['gender'], equals('female'));
      expect(map['activityLevel'], equals('active'));
      expect(map['fitnessGoal'], equals('Lose weight'));
    });

    test('fromFirestore should create HealthMetricsModel from DocumentSnapshot', () {
      final mockData = {
        'height': 175.0,
        'weight': 72.5,
        'age': 25,
        'gender': 'female',
        'activityLevel': 'light',
        'fitnessGoal': 'Lose weight',
      };

      final mockSnapshot = MockDocumentSnapshot(mockData);
      final metrics = HealthMetricsModel.fromFirestore(mockSnapshot);

      expect(metrics.userId, equals('test-uid'));
      expect(metrics.height, equals(175.0));
      expect(metrics.weight, equals(72.5));
      expect(metrics.age, equals(25));
      expect(metrics.gender, equals('female'));
      expect(metrics.activityLevel, equals('light'));
      expect(metrics.fitnessGoal, equals('Lose weight'));
    });

    test('fromFirestore should handle missing fields gracefully', () {
      final mockData = {
        'height': 180.0,
        'weight': 70.0,
      };

      final mockSnapshot = MockDocumentSnapshot(mockData);

      expect(() => HealthMetricsModel.fromFirestore(mockSnapshot), throwsA(isA<TypeError>()));
    });

    test('toMap should handle correct value types', () {
      final metrics = HealthMetricsModel(
        userId: 'test-uid',
        height: 180.5,
        weight: 75.0,
        age: 30,
        gender: 'male',
        activityLevel: 'very active',
        fitnessGoal: 'Gain muscle',
      );

      final map = metrics.toMap();

      expect(map['height'], isA<double>());
      expect(map['weight'], isA<double>());
      expect(map['age'], isA<int>());
      expect(map['gender'], isA<String>());
      expect(map['activityLevel'], isA<String>());
      expect(map['fitnessGoal'], isA<String>());
    });

    test('fromFirestore should throw exception if data is null', () {
      final mockSnapshot = MockDocumentSnapshot(null);
      expect(() => HealthMetricsModel.fromFirestore(mockSnapshot), throwsException);
    });

    test('fromFirestore should correctly convert numeric fields', () {
      final mockData = {
        'height': 175,
        'weight': 72,
        'age': 25,
        'gender': 'female',
        'activityLevel': 'moderate',
        'fitnessGoal': 'Maintain',
      };

      final mockSnapshot = MockDocumentSnapshot(mockData);
      final metrics = HealthMetricsModel.fromFirestore(mockSnapshot);

      expect(metrics.height, equals(175.0));
      expect(metrics.weight, equals(72.0));
      expect(metrics.age, equals(25));
      expect(metrics.gender, equals('female'));
      expect(metrics.activityLevel, equals('moderate'));
      expect(metrics.fitnessGoal, equals('Maintain'));
    });
  });
}