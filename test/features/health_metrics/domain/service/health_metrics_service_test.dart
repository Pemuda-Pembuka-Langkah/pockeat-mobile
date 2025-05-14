// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_service.dart';
import 'health_metrics_service_test.mocks.dart';

// Import generated mocks

@GenerateMocks([HealthMetricsRepository, FirebaseAuth, User])
void main() {
  late HealthMetricsService service;
  late MockHealthMetricsRepository mockRepository;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockRepository = MockHealthMetricsRepository();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
  });

  group('HealthMetricsService', () {
    group('Constructor', () {
      test('should create with default dependencies when none provided', () async {
        // Don't test with real Firebase.instance - always provide mocks
        service = HealthMetricsService(
          repository: MockHealthMetricsRepository(),
          auth: MockFirebaseAuth(),
        );
        expect(service, isNotNull);
      });

      test('should create with custom dependencies', () {
        service = HealthMetricsService(
          repository: mockRepository,
          auth: mockAuth,
        );
        expect(service, isNotNull);
      });
    });

    group('getUserHealthMetrics', () {
      setUp(() {
        service = HealthMetricsService(
          repository: mockRepository,
          auth: mockAuth,
        );
      });

      test('should return default metrics when user is null', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await service.getUserHealthMetrics();

        // Assert
        expect(result.userId, 'anonymous');
        expect(result.height, 175.0);
        expect(result.weight, 70.0);
        expect(result.age, 30);
        expect(result.gender, 'Male');
        expect(result.activityLevel, 'moderate');
        expect(result.fitnessGoal, 'maintain');
        expect(result.bmi, 22.9);
        expect(result.bmiCategory, 'Normal weight');
        expect(result.desiredWeight, 70.0);
      });

      test('should return user metrics when found in repository', () async {
        // Arrange
        const userId = 'test-user-123';
        final expectedMetrics = HealthMetricsModel(
          userId: userId,
          height: 180.0,
          weight: 80.0,
          age: 25,
          gender: 'Female',
          activityLevel: 'active',
          fitnessGoal: 'lose',
          bmi: 24.7,
          bmiCategory: 'Normal weight',
          desiredWeight: 75.0,
        );

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockRepository.getHealthMetrics(userId))
            .thenAnswer((_) async => expectedMetrics);

        // Act
        final result = await service.getUserHealthMetrics();

        // Assert
        expect(result, equals(expectedMetrics));
        verify(mockRepository.getHealthMetrics(userId)).called(1);
      });

      test('should return default metrics when user exists but no metrics found',
          () async {
        // Arrange
        const userId = 'test-user-456';
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockRepository.getHealthMetrics(userId))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getUserHealthMetrics();

        // Assert
        expect(result.userId, userId);
        expect(result.height, 175.0);
        expect(result.weight, 70.0);
        expect(result.age, 30);
        expect(result.gender, 'Male');
        expect(result.activityLevel, 'moderate');
        expect(result.fitnessGoal, 'maintain');
        expect(result.bmi, 22.9);
        expect(result.bmiCategory, 'Normal weight');
        expect(result.desiredWeight, 70.0);
        verify(mockRepository.getHealthMetrics(userId)).called(1);
      });

      test('should return default metrics when repository throws error',
          () async {
        // Arrange
        const userId = 'test-user-789';
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockRepository.getHealthMetrics(userId))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await service.getUserHealthMetrics();

        // Assert
        expect(result.userId, userId);
        expect(result.height, 175.0);
        expect(result.weight, 70.0);
        expect(result.age, 30);
        expect(result.gender, 'Male');
        expect(result.activityLevel, 'moderate');
        expect(result.fitnessGoal, 'maintain');
        expect(result.bmi, 22.9);
        expect(result.bmiCategory, 'Normal weight');
        expect(result.desiredWeight, 70.0);
        verify(mockRepository.getHealthMetrics(userId)).called(1);
      });

      test('should handle different error types from repository', () async {
        // Arrange
        const userId = 'test-user-error';
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockRepository.getHealthMetrics(userId))
            .thenThrow(ArgumentError('Invalid argument'));

        // Act
        final result = await service.getUserHealthMetrics();

        // Assert
        expect(result.userId, userId);
        expect(result.height, 175.0);
        verify(mockRepository.getHealthMetrics(userId)).called(1);
      });
    });

    group('Edge Cases', () {
      setUp(() {
        service = HealthMetricsService(
          repository: mockRepository,
          auth: mockAuth,
        );
      });

      test('should handle empty user uid', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('');
        when(mockRepository.getHealthMetrics(''))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.getUserHealthMetrics();

        // Assert
        expect(result.userId, '');
        expect(result.height, 175.0);
        verify(mockRepository.getHealthMetrics('')).called(1);
      });

      test('should handle null from repository without throwing', () async {
        // Arrange
        const userId = 'test-user-null';
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockRepository.getHealthMetrics(userId))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(() => service.getUserHealthMetrics(), returnsNormally);
        final result = await service.getUserHealthMetrics();
        expect(result.userId, userId);
      });
    });

    group('Integration', () {
      test('should work end-to-end with real-like scenario', () async {
        // Arrange
        service = HealthMetricsService(
          repository: mockRepository,
          auth: mockAuth,
        );
        
        const userId = 'integration-test-user';
        final existingMetrics = HealthMetricsModel(
          userId: userId,
          height: 165.0,
          weight: 60.0,
          age: 28,
          gender: 'Female',
          activityLevel: 'very-active',
          fitnessGoal: 'gain',
          bmi: 22.0,
          bmiCategory: 'Normal weight',
          desiredWeight: 65.0,
        );

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(userId);
        when(mockRepository.getHealthMetrics(userId))
            .thenAnswer((_) async => existingMetrics);

        // Act
        final result = await service.getUserHealthMetrics();

        // Assert
        expect(result, equals(existingMetrics));
        expect(result.userId, userId);
        expect(result.height, 165.0);
        expect(result.weight, 60.0);
        expect(result.gender, 'Female');
      });
    });
  });
}
