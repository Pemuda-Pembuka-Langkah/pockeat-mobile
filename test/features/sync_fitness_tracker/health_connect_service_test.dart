import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pockeat/features/sync_fitness_tracker/services/health_connect_service.dart';

// Mock the Health class
class MockHealth extends Mock implements Health {}

// Mock Permission class for activity recognition
class MockPermission extends Mock implements Permission {
  static final activityRecognition = MockPermission();
}

void main() {
  late FitnessService fitnessService;
  late MockHealth mockHealth;

  setUp(() {
    mockHealth = MockHealth();
    fitnessService = FitnessService();
    
    // Replace the internal Health instance with our mock
    fitnessService.setHealthInstance(mockHealth);
    
    // Register fallback values for any named parameters
    registerFallbackValue(HealthDataType.STEPS);
    registerFallbackValue(DateTime.now());
    registerFallbackValue(<HealthDataType>[]);
  });

  group('FitnessService - Initialization', () {
    test('initialize returns true when Health Connect is available and configured', () async {
      // Arrange
      when(() => mockHealth.configure()).thenAnswer((_) async {});
      when(() => mockHealth.isHealthConnectAvailable()).thenAnswer((_) async => true);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenAnswer((_) async => HealthConnectSdkStatus.sdkAvailable);
      when(() => MockPermission.activityRecognition.request())
          .thenAnswer((_) async => PermissionStatus.granted);
      when(() => mockHealth.hasPermissions(any()))
          .thenAnswer((_) async => true);
      when(() => mockHealth.isHealthDataHistoryAvailable())
          .thenAnswer((_) async => true);
      when(() => mockHealth.requestHealthDataHistoryAuthorization())
          .thenAnswer((_) async => true);

      // Act
      final result = await fitnessService.initialize();

      // Assert
      expect(result, true);
      verify(() => mockHealth.configure()).called(1);
    });

    test('initialize returns false when Health Connect is not available', () async {
      // Arrange
      when(() => mockHealth.configure()).thenAnswer((_) async {});
      when(() => mockHealth.isHealthConnectAvailable()).thenAnswer((_) async => true);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenAnswer((_) async => HealthConnectSdkStatus.notInstalled);
      when(() => mockHealth.installHealthConnect()).thenAnswer((_) async {});

      // Act
      final result = await fitnessService.initialize();

      // Assert
      expect(result, false);
      verify(() => mockHealth.installHealthConnect()).called(1);
    });

    test('initialize returns false when permissions are denied', () async {
      // Arrange
      when(() => mockHealth.configure()).thenAnswer((_) async {});
      when(() => mockHealth.isHealthConnectAvailable()).thenAnswer((_) async => true);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenAnswer((_) async => HealthConnectSdkStatus.sdkAvailable);
      when(() => MockPermission.activityRecognition.request())
          .thenAnswer((_) async => PermissionStatus.granted);
      when(() => mockHealth.hasPermissions(any()))
          .thenAnswer((_) async => false);
      when(() => mockHealth.requestAuthorization(any()))
          .thenAnswer((_) async => false);

      // Act
      final result = await fitnessService.initialize();

      // Assert
      expect(result, false);
      verify(() => mockHealth.requestAuthorization(any())).called(1);
    });
  });

  group('FitnessService - Data Retrieval', () {
    setUp(() {
      // Setup common mocks for successful initialization
      when(() => mockHealth.configure()).thenAnswer((_) async {});
      when(() => mockHealth.isHealthConnectAvailable()).thenAnswer((_) async => true);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenAnswer((_) async => HealthConnectSdkStatus.sdkAvailable);
      when(() => MockPermission.activityRecognition.request())
          .thenAnswer((_) async => PermissionStatus.granted);
      when(() => mockHealth.hasPermissions(any()))
          .thenAnswer((_) async => true);
      when(() => mockHealth.isHealthDataHistoryAvailable())
          .thenAnswer((_) async => true);
      when(() => mockHealth.requestHealthDataHistoryAuthorization())
          .thenAnswer((_) async => true);
    });

    test('getStepCount returns correct step count', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Mock the getTotalStepsInInterval method
      when(() => mockHealth.getTotalStepsInInterval(
            any(),
            any(),
            includeManualEntry: any(named: 'includeManualEntry'),
          )).thenAnswer((_) async => 5000);

      // Initialize first to set _isInitialized = true
      await fitnessService.initialize();

      // Act
      final steps = await fitnessService.getStepCount(
        startTime: yesterday,
        endTime: now,
        includeManualEntries: true,
      );

      // Assert
      expect(steps, 5000);
      verify(() => mockHealth.getTotalStepsInInterval(
            yesterday,
            now,
            includeManualEntry: true,
          )).called(1);
    });

    test('getStepCount returns 0 when Health returns null', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Mock the getTotalStepsInInterval method to return null
      when(() => mockHealth.getTotalStepsInInterval(
            any(),
            any(),
            includeManualEntry: any(named: 'includeManualEntry'),
          )).thenAnswer((_) async => null);

      // Initialize first to set _isInitialized = true
      await fitnessService.initialize();

      // Act
      final steps = await fitnessService.getStepCount(
        startTime: yesterday,
        endTime: now,
      );

      // Assert
      expect(steps, 0);
    });

    test('getTotalCaloriesBurned returns correct calories', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Create mock health data for calories
      final mockNumericValue = NumericHealthValue(1000.5);
      final mockHealthDataPoint = HealthDataPoint(
        value: mockNumericValue,
        type: HealthDataType.TOTAL_CALORIES_BURNED,
        unit: HealthDataUnit.CALORIES,
        dateFrom: yesterday,
        dateTo: now,
        platformType: HealthPlatformType.IOS,
        sourceId: 'test',
        sourceName: 'Test Source',
        deviceId: 'test-device',
        uuid: 'test-uuid',
        recordingMethod: RecordingMethod.automatic,
      );
      
      // Mock the getHealthDataFromTypes method
      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => [mockHealthDataPoint]);

      // Initialize first to set _isInitialized = true
      await fitnessService.initialize();

      // Act
      final calories = await fitnessService.getTotalCaloriesBurned(
        startTime: yesterday,
        endTime: now,
      );

      // Assert
      expect(calories, 1000.5);
      verify(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: yesterday,
            endTime: now,
          )).called(1);
    });

    test('getTotalCaloriesBurned returns 0 when no data is available', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Mock the getHealthDataFromTypes method to return an empty list
      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => []);

      // Initialize first to set _isInitialized = true
      await fitnessService.initialize();

      // Act
      final calories = await fitnessService.getTotalCaloriesBurned(
        startTime: yesterday,
        endTime: now,
      );

      // Assert
      expect(calories, 0);
    });

    test('getActiveCaloriesBurned returns correct calories', () async {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Create mock health data for active calories
      final mockNumericValue = NumericHealthValue(500.5);
      final mockHealthDataPoint = HealthDataPoint(
        value: mockNumericValue,
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        unit: HealthDataUnit.CALORIES,
        dateFrom: yesterday,
        dateTo: now,
        platformType: HealthPlatformType.IOS,
        sourceId: 'test',
        sourceName: 'Test Source',
        deviceId: 'test-device',
        uuid: 'test-uuid',
        recordingMethod: RecordingMethod.automatic,
      );
      
      // Mock the getHealthDataFromTypes method
      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => [mockHealthDataPoint]);

      // Initialize first to set _isInitialized = true
      await fitnessService.initialize();

      // Act
      final calories = await fitnessService.getActiveCaloriesBurned(
        startTime: yesterday,
        endTime: now,
      );

      // Assert
      expect(calories, 500.5);
    });
  });

  group('FitnessService - Availability', () {
    test('isAvailable returns true when Health Connect is available', () async {
      // Arrange
      when(() => mockHealth.isHealthConnectAvailable()).thenAnswer((_) async => true);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenAnswer((_) async => HealthConnectSdkStatus.sdkAvailable);

      // Act
      final result = await fitnessService.isAvailable();

      // Assert
      expect(result, true);
    });

    test('isAvailable returns false when Health Connect is not available', () async {
      // Arrange
      when(() => mockHealth.isHealthConnectAvailable()).thenAnswer((_) async => true);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenAnswer((_) async => HealthConnectSdkStatus.notInstalled);

      // Act
      final result = await fitnessService.isAvailable();

      // Assert
      expect(result, false);
    });
  });

  test('openHealthSettings calls the correct methods', () async {
    // Arrange
    when(() => mockHealth.configure()).thenAnswer((_) async {});
    when(() => mockHealth.isHealthConnectAvailable()).thenAnswer((_) async => true);
    when(() => mockHealth.openHealthConnectSettings()).thenAnswer((_) async {});

    // Act
    await fitnessService.openHealthSettings();

    // Assert
    verify(() => mockHealth.configure()).called(1);
    verify(() => mockHealth.isHealthConnectAvailable()).called(1);
    verify(() => mockHealth.openHealthConnectSettings()).called(1);
  });
}