import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:health/health.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pockeat/features/sync_fitness_tracker/services/fitness_tracker_sync.dart';

// Mock classes
class MockHealth extends Mock implements Health {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockBuildContext extends Mock implements BuildContext {}

class MockDeviceInfoPlugin extends Mock implements DeviceInfoPlugin {
  @override
  Future<AndroidDeviceInfo> get androidInfo =>
      Future.value(AndroidDeviceInfo.fromMap({
        'id': 'mock-android-id',
        'version': {
          'baseOS': 'mock-baseOS',
          'codename': 'mock-codename',
          'incremental': 'mock-incremental',
          'previewSdkInt': 23,
          'release': 'mock-release',
          'sdkInt': 30,
          'securityPatch': 'mock-securityPatch',
        },
        'board': 'mock-board',
        'bootloader': 'mock-bootloader',
        'brand': 'mock-brand',
        'device': 'mock-device',
        'display': 'mock-display',
        'fingerprint': 'mock-fingerprint',
        'hardware': 'mock-hardware',
        'host': 'mock-host',
        'manufacturer': 'mock-manufacturer',
        'model': 'mock-model',
        'product': 'mock-product',
        'supported32BitAbis': <String>[],
        'supported64BitAbis': <String>[],
        'supportedAbis': <String>[],
        'tags': 'mock-tags',
        'type': 'mock-type',
        'isPhysicalDevice': true,
        'serialNumber': 'mock-serial',
        'isLowRamDevice': false,
        'systemFeatures': <String>[],
      }));
}

// Test subclass to expose protected methods and override dependencies
class TestFitnessTrackerSync extends FitnessTrackerSync {
  final Health mockHealth;
  final MethodChannel mockMethodChannel;

  TestFitnessTrackerSync({
    required this.mockHealth,
    required this.mockMethodChannel,
  });

  @override
  Health get _health => mockHealth;

  @override
  MethodChannel get _methodChannel => mockMethodChannel;

  // Expose protected method for testing
  Future<bool> testCanReadHealthData() => _canReadHealthData();
}

// Test class for mocking data responses
class FitnessTrackerSyncWithMockData extends FitnessTrackerSync {
  final Health mockHealth;
  final MethodChannel mockMethodChannel;
  final int mockSteps;
  final double mockCalories;

  FitnessTrackerSyncWithMockData({
    required this.mockHealth,
    required this.mockMethodChannel,
    required this.mockSteps,
    required this.mockCalories,
  });

  @override
  Health get _health => mockHealth;

  @override
  MethodChannel get _methodChannel => mockMethodChannel;

  @override
  Future<int?> getStepsForDay(DateTime date) async => mockSteps;

  @override
  Future<double?> getCaloriesBurnedForDay(DateTime date) async => mockCalories;
}

void fitnessTrackerSyncTests() {
  late TestFitnessTrackerSync fitnessTrackerSync;
  late MockHealth mockHealth;
  late MockMethodChannel mockMethodChannel;
  late MockBuildContext mockContext;

  setUp(() {
    mockHealth = MockHealth();
    mockMethodChannel = MockMethodChannel();
    mockContext = MockBuildContext();

    fitnessTrackerSync = TestFitnessTrackerSync(
      mockHealth: mockHealth,
      mockMethodChannel: mockMethodChannel,
    );

    registerFallbackValue(
        HealthDataType.STEPS); // Register fallback values for Mocktail
    registerFallbackValue([HealthDataType.STEPS]);
    registerFallbackValue(DateTime.now());
  });

  group('Initialization and Permissions', () {
    test('initializeAndCheckPermissions succeeds when all checks pass',
        () async {
      // Arrange
      when(() => mockHealth.configure()).thenAnswer((_) async => null);
      when(() => mockHealth.isHealthConnectAvailable())
          .thenAnswer((_) async => true);
      when(() => mockHealth.hasPermissions(any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await fitnessTrackerSync.initializeAndCheckPermissions();

      // Assert
      expect(result, true);
      verify(() => mockHealth.configure()).called(1);
      verify(() => mockHealth.isHealthConnectAvailable()).called(1);
      verify(() => mockHealth.hasPermissions(any())).called(1);
    });

    test(
        'initializeAndCheckPermissions fails when Health Connect not available',
        () async {
      // Arrange
      when(() => mockHealth.configure()).thenAnswer((_) async => null);
      when(() => mockHealth.isHealthConnectAvailable())
          .thenAnswer((_) async => false);

      // Act
      final result = await fitnessTrackerSync.initializeAndCheckPermissions();

      // Assert
      expect(result, false);
      verify(() => mockHealth.configure()).called(1);
      verify(() => mockHealth.isHealthConnectAvailable()).called(1);
      verifyNever(() => mockHealth.hasPermissions(any()));
    });

    test('initializeAndCheckPermissions handles permission check exceptions',
        () async {
      // Arrange
      when(() => mockHealth.configure()).thenAnswer((_) async => null);
      when(() => mockHealth.isHealthConnectAvailable())
          .thenAnswer((_) async => true);
      when(() => mockHealth.hasPermissions(any()))
          .thenThrow(Exception('Permission error'));

      // Mock the _canReadHealthData method to return false since it's used as fallback
      when(() => mockHealth.getTotalStepsInInterval(any(), any()))
          .thenThrow(Exception('Steps error'));
      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenThrow(Exception('Data error'));

      // Act
      final result = await fitnessTrackerSync.initializeAndCheckPermissions();

      // Assert
      expect(result, false);
    });

    test(
        'hasRequiredPermissions returns true when _localPermissionState is true',
        () async {
      // Arrange
      fitnessTrackerSync.setPermissionGranted();

      // Act
      final result = await fitnessTrackerSync.hasRequiredPermissions();

      // Assert
      expect(result, true);
      // Should not call health methods when using local state
      verifyNever(() => mockHealth.hasPermissions(any()));
    });

    test('_canReadHealthData returns true if getTotalStepsInInterval succeeds',
        () async {
      // Arrange
      when(() => mockHealth.getTotalStepsInInterval(any(), any()))
          .thenAnswer((_) async => 1000);

      // Act
      final result = await fitnessTrackerSync.testCanReadHealthData();

      // Assert
      expect(result, true);
      verify(() => mockHealth.getTotalStepsInInterval(any(), any())).called(1);
    });

    test('_canReadHealthData tries alternative method if first method fails',
        () async {
      // Arrange
      when(() => mockHealth.getTotalStepsInInterval(any(), any()))
          .thenThrow(Exception('Steps error'));
      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => []);

      // Act
      final result = await fitnessTrackerSync.testCanReadHealthData();

      // Assert
      expect(result, true);
      verify(() => mockHealth.getTotalStepsInInterval(any(), any())).called(1);
      verify(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).called(1);
    });
  });

  group('Platform Operations', () {
    test('openHealthConnect calls method channel correctly', () async {
      // Arrange
      when(() => mockMethodChannel.invokeMethod('launchHealthConnect'))
          .thenAnswer((_) async => null);

      // Act
      await fitnessTrackerSync.openHealthConnect(mockContext);

      // Assert
      verify(() => mockMethodChannel.invokeMethod('launchHealthConnect'))
          .called(1);
    });

    test('openHealthConnect handles exceptions', () async {
      // Arrange
      when(() => mockMethodChannel.invokeMethod('launchHealthConnect'))
          .thenThrow(PlatformException(code: 'ERROR'));

      // Act & Assert (should not throw)
      await fitnessTrackerSync.openHealthConnect(mockContext);
      verify(() => mockMethodChannel.invokeMethod('launchHealthConnect'))
          .called(1);
    });

    test('openHealthConnectPlayStore calls method channel correctly', () async {
      // Arrange
      when(() => mockMethodChannel.invokeMethod('openHealthConnectPlayStore'))
          .thenAnswer((_) async => null);

      // Act
      await fitnessTrackerSync.openHealthConnectPlayStore();

      // Assert
      verify(() => mockMethodChannel.invokeMethod('openHealthConnectPlayStore'))
          .called(1);
    });
  });

  group('Data Operations', () {
    test('getTodayFitnessData returns combined steps and calories', () async {
      // Arrange
      final mockSteps = 5000;
      final mockCalories = 250.0;

      final syncWithMockData = FitnessTrackerSyncWithMockData(
        mockHealth: mockHealth,
        mockMethodChannel: mockMethodChannel,
        mockSteps: mockSteps,
        mockCalories: mockCalories,
      );

      // Act
      final result = await syncWithMockData.getTodayFitnessData();

      // Assert
      expect(result['steps'], mockSteps);
      expect(result['calories'], mockCalories);
    });

    test('getStepsForDay gets steps successfully with primary method',
        () async {
      // Arrange
      final testDate = DateTime.now();
      final testSteps = 5000;

      when(() => mockHealth.getTotalStepsInInterval(any(), any()))
          .thenAnswer((_) async => testSteps);

      // Act
      final result = await fitnessTrackerSync.getStepsForDay(testDate);

      // Assert
      expect(result, testSteps);
      verify(() => mockHealth.getTotalStepsInInterval(any(), any())).called(1);
    });

    test('getStepsForDay falls back to alternative method when primary fails',
        () async {
      // Arrange
      final testDate = DateTime.now();

      when(() => mockHealth.getTotalStepsInInterval(any(), any()))
          .thenThrow(Exception('Steps error'));

      final mockDataPoint = HealthDataPoint(
        NumericHealthValue(2000.0),
        HealthDataType.STEPS,
        HealthDataUnit.COUNT,
        DateTime.now().subtract(Duration(hours: 1)),
        DateTime.now(),
        PlatformType.ANDROID,
        'deviceId',
        'sourceId',
        'sourceName',
      );

      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => [mockDataPoint]);

      // Act
      final result = await fitnessTrackerSync.getStepsForDay(testDate);

      // Assert
      expect(result, 2000);
    });

    test('getCaloriesBurnedForDay combines TOTAL_CALORIES_BURNED values',
        () async {
      // Arrange
      final testDate = DateTime.now();

      final mockDataPoint1 = HealthDataPoint(
        NumericHealthValue(100.0),
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataUnit.KILOCALORIE,
        DateTime.now().subtract(Duration(hours: 2)),
        DateTime.now().subtract(Duration(hours: 1)),
        PlatformType.ANDROID,
        'deviceId',
        'sourceId',
        'sourceName',
      );

      final mockDataPoint2 = HealthDataPoint(
        NumericHealthValue(50.0),
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataUnit.KILOCALORIE,
        DateTime.now().subtract(Duration(hours: 1)),
        DateTime.now(),
        PlatformType.ANDROID,
        'deviceId',
        'sourceId',
        'sourceName',
      );

      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => [mockDataPoint1, mockDataPoint2]);

      // Act
      final result = await fitnessTrackerSync.getCaloriesBurnedForDay(testDate);

      // Assert
      expect(result, 150.0); // 100.0 + 50.0
    });

    test(
        'getCaloriesBurnedForDay falls back to ACTIVE_ENERGY_BURNED if no TOTAL_CALORIES_BURNED',
        () async {
      // Arrange
      final testDate = DateTime.now();

      final mockDataPoint = HealthDataPoint(
        NumericHealthValue(75.0),
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataUnit.KILOCALORIE,
        DateTime.now().subtract(Duration(hours: 1)),
        DateTime.now(),
        PlatformType.ANDROID,
        'deviceId',
        'sourceId',
        'sourceName',
      );

      when(() => mockHealth.getHealthDataFromTypes(
            types: any(named: 'types'),
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
          )).thenAnswer((_) async => [mockDataPoint]);

      // Act
      final result = await fitnessTrackerSync.getCaloriesBurnedForDay(testDate);

      // Assert
      expect(result, 75.0);
    });
  });
}
