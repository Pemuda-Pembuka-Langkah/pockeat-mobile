// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/domain/models/models.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

// Extension untuk menambahkan property yang dibutuhkan dalam test
extension RunningActivityExtension on RunningActivity {
  double get durationInMinutes => duration.inMinutes.toDouble();

  double get paceMinPerKm {
    if (distanceKm == 0) return 0;
    return durationInMinutes / distanceKm;
  }
}

extension CyclingActivityExtension on CyclingActivity {
  double get speedKmPerHour {
    final durationHours = duration.inMinutes / 60.0;
    if (durationHours == 0) return 0;
    return distanceKm / durationHours;
  }
}

extension SwimmingActivityExtension on SwimmingActivity {
  double get distanceInMeters => laps * poolLength;
  double get distanceKm => distanceInMeters / 1000;

  double get paceMinPerKm {
    if (distanceKm == 0) return 0;
    return duration.inMinutes / distanceKm;
  }
}

void main() {
  late HealthMetricsModel testHealthMetrics;

  setUp(() {
    testHealthMetrics = HealthMetricsModel(
      userId: 'test-user',
      height: 175.0,
      weight: 70.0,
      age: 30,
      gender: 'Male',
      activityLevel: 'moderate',
      fitnessGoal: 'maintain',
      bmi: 22.9,
      bmiCategory: 'Normal weight',
      desiredWeight: 70.0,
    );
  });

  group('CardioActivity Models Tests', () {
    final testDate = DateTime(2023, 3, 15);
    final testStartTime = DateTime(2023, 3, 15, 9, 0);
    final testEndTime = DateTime(2023, 3, 15, 9, 30);

    group('RunningActivity Tests', () {
      test('RunningActivity should be created correctly', () {
        final activity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
          caloriesBurned: 300,
        );

        expect(activity.date, testDate);
        expect(activity.startTime, testStartTime);
        expect(activity.endTime, testEndTime);
        expect(activity.distanceKm, 5.0);
        expect(activity.caloriesBurned, 300);
        expect(activity.type, CardioType.running);
      });

      test('RunningActivity toMap should convert correctly', () {
        final activity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
          caloriesBurned: 300,
        );

        final map = activity.toMap();

        expect(map['type'], 'running');
        expect(map['date'], testDate.millisecondsSinceEpoch);
        expect(map['startTime'], testStartTime.millisecondsSinceEpoch);
        expect(map['endTime'], testEndTime.millisecondsSinceEpoch);
        expect(map['distanceKm'], 5.0);
        expect(map['caloriesBurned'], 300);
      });

      test('RunningActivity pace calculation should be correct', () {
        final activity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
          caloriesBurned: 300,
        );

        // 30 minutes / 5 km = 6 min/km
        expect(activity.paceMinPerKm, 6.0);
      });

      test('RunningActivity duration calculation should be correct', () {
        final activity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
          caloriesBurned: 300,
        );

        expect(activity.durationInMinutes, 30);
      });

      test('RunningActivity calculateCaloriesWithHealthMetrics method should work',
          () {
        final activity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
        );

        final calories = activity.calculateCaloriesWithHealthMetrics(testHealthMetrics);

        expect(calories, isNotNull);
        expect(calories, isA<double>());
        expect(calories, greaterThan(0));
      });

      test('RunningActivity deprecated calculateCalories method should return stored value',
          () {
        final activity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
          caloriesBurned: 300.0,
        );

        final calories = activity.calculateCalories();
        expect(calories, 300.0);
      });

      test(
          'RunningActivity copyWith should create a new instance with updated values',
          () {
        final originalActivity = RunningActivity(
          userId: "test-user-id",
          id: 'test-id',
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
          caloriesBurned: 300,
        );

        final updatedActivity = originalActivity.copyWith(
          id: 'new-id',
          date: DateTime(2023, 3, 16),
          startTime: DateTime(2023, 3, 16, 10, 0),
          endTime: DateTime(2023, 3, 16, 10, 45),
          distanceKm: 10.0,
          caloriesBurned: 600,
        );

        expect(updatedActivity.id, 'new-id');
        expect(updatedActivity.date, DateTime(2023, 3, 16));
        expect(updatedActivity.startTime, DateTime(2023, 3, 16, 10, 0));
        expect(updatedActivity.endTime, DateTime(2023, 3, 16, 10, 45));
        expect(updatedActivity.distanceKm, 10.0);
        expect(updatedActivity.caloriesBurned, 600);

        final partialUpdate = originalActivity.copyWith(
          distanceKm: 7.0,
        );

        expect(partialUpdate.id, originalActivity.id);
        expect(partialUpdate.date, originalActivity.date);
        expect(partialUpdate.distanceKm, 7.0);
        expect(partialUpdate.caloriesBurned, originalActivity.caloriesBurned);
      });
    });

    group('CyclingActivity Tests', () {
      test('CyclingActivity fromMap should parse commute type correctly', () {
        final map = {
          'type': 'cycling',
          'date': testDate.millisecondsSinceEpoch,
          'startTime': testStartTime.millisecondsSinceEpoch,
          'endTime': testEndTime.millisecondsSinceEpoch,
          'distanceKm': 10.0,
          'cyclingType': 'commute',
          'caloriesBurned': 300.0,
        };

        final activity = CyclingActivity.fromMap(map);

        expect(activity.cyclingType, CyclingType.commute);
        expect(activity.cyclingTypeString, 'commute');
      });

      test('CyclingActivity fromMap should parse stationary type correctly',
          () {
        final map = {
          'type': 'cycling',
          'date': testDate.millisecondsSinceEpoch,
          'startTime': testStartTime.millisecondsSinceEpoch,
          'endTime': testEndTime.millisecondsSinceEpoch,
          'distanceKm': 5.0,
          'cyclingType': 'stationary',
          'caloriesBurned': 250.0,
        };

        final activity = CyclingActivity.fromMap(map);

        expect(activity.cyclingType, CyclingType.stationary);
        expect(activity.cyclingTypeString, 'stationary');
      });

      test(
          'CyclingActivity copyWith should create a new instance with updated values',
          () {
        final originalActivity = CyclingActivity(
          userId: "test-user-id",
          id: 'test-id',
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 15.0,
          cyclingType: CyclingType.mountain,
          caloriesBurned: 450,
        );

        final updatedActivity = originalActivity.copyWith(
          id: 'new-id',
          date: DateTime(2023, 3, 16),
          startTime: DateTime(2023, 3, 16, 10, 0),
          endTime: DateTime(2023, 3, 16, 10, 45),
          distanceKm: 20.0,
          cyclingType: CyclingType.commute,
          caloriesBurned: 500,
        );

        expect(updatedActivity.id, 'new-id');
        expect(updatedActivity.date, DateTime(2023, 3, 16));
        expect(updatedActivity.startTime, DateTime(2023, 3, 16, 10, 0));
        expect(updatedActivity.endTime, DateTime(2023, 3, 16, 10, 45));
        expect(updatedActivity.distanceKm, 20.0);
        expect(updatedActivity.cyclingType, CyclingType.commute);
        expect(updatedActivity.caloriesBurned, 500);

        final partialUpdate = originalActivity.copyWith(
          distanceKm: 25.0,
        );

        expect(partialUpdate.id, originalActivity.id);
        expect(partialUpdate.date, originalActivity.date);
        expect(partialUpdate.cyclingType, originalActivity.cyclingType);
        expect(partialUpdate.distanceKm, 25.0);
      });

      test('CyclingActivity calculateCaloriesWithHealthMetrics method should work',
          () {
        final activity = CyclingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 15.0,
          cyclingType: CyclingType.mountain,
        );

        final calories = activity.calculateCaloriesWithHealthMetrics(testHealthMetrics);

        expect(calories, isNotNull);
        expect(calories, isA<double>());
        expect(calories, greaterThan(0));
      });

      test('CyclingActivity deprecated calculateCalories method should return stored value',
          () {
        final activity = CyclingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 15.0,
          cyclingType: CyclingType.mountain,
          caloriesBurned: 450.0,
        );

        final calories = activity.calculateCalories();
        expect(calories, 450.0);
      });

      test('CyclingActivity should be created correctly', () {
        final activity = CyclingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 15.0,
          cyclingType: CyclingType.mountain,
          caloriesBurned: 450,
        );

        expect(activity.date, testDate);
        expect(activity.startTime, testStartTime);
        expect(activity.endTime, testEndTime);
        expect(activity.distanceKm, 15.0);
        expect(activity.cyclingType, CyclingType.mountain);
        expect(activity.caloriesBurned, 450);
        expect(activity.type, CardioType.cycling);
      });

      test('CyclingActivity toMap should convert correctly', () {
        final activity = CyclingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 15.0,
          cyclingType: CyclingType.mountain,
          caloriesBurned: 450,
        );

        final map = activity.toMap();

        expect(map['type'], 'cycling');
        expect(map['date'], testDate.millisecondsSinceEpoch);
        expect(map['startTime'], testStartTime.millisecondsSinceEpoch);
        expect(map['endTime'], testEndTime.millisecondsSinceEpoch);
        expect(map['distanceKm'], 15.0);
        expect(map['cyclingType'], 'mountain');
        expect(map['caloriesBurned'], 450);
      });

      test('CyclingActivity speed calculation should be correct', () {
        final activity = CyclingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime:
              testStartTime.add(const Duration(minutes: 60)), // Total 1 hour
          distanceKm: 30.0,
          cyclingType: CyclingType.mountain,
          caloriesBurned: 450,
        );

        // 30 km / 1 hour = 30 km/h
        expect(activity.speedKmPerHour, 30.0);
      });
    });

    group('SwimmingActivity Tests', () {
      test('SwimmingActivity should be created correctly', () {
        final activity = SwimmingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          caloriesBurned: 350,
        );

        expect(activity.date, testDate);
        expect(activity.startTime, testStartTime);
        expect(activity.endTime, testEndTime);
        expect(activity.laps, 20);
        expect(activity.poolLength, 25.0);
        expect(activity.stroke, 'Freestyle (Front Crawl)');
        expect(activity.caloriesBurned, 350);
        expect(activity.type, CardioType.swimming);
      });

      test('SwimmingActivity toMap should convert correctly', () {
        final activity = SwimmingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          caloriesBurned: 350,
        );

        final map = activity.toMap();

        expect(map['type'], 'swimming');
        expect(map['date'], testDate.millisecondsSinceEpoch);
        expect(map['startTime'], testStartTime.millisecondsSinceEpoch);
        expect(map['endTime'], testEndTime.millisecondsSinceEpoch);
        expect(map['laps'], 20);
        expect(map['poolLength'], 25.0);
        expect(map['stroke'], 'Freestyle (Front Crawl)');
        expect(map['caloriesBurned'], 350);
      });

      test('SwimmingActivity distance calculation should be correct', () {
        final activity = SwimmingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          caloriesBurned: 350,
        );

        // 20 laps * 25m = 500m = 0.5km
        expect(activity.distanceInMeters, 500.0);
        expect(activity.distanceKm, 0.5);
      });

      test('SwimmingActivity pace calculation should be correct', () {
        final activity = SwimmingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          caloriesBurned: 350,
        );

        // 30 minutes / 0.5 km = 60 min/km
        expect(activity.paceMinPerKm, 60.0);
      });

      test('SwimmingActivity calculateCaloriesWithHealthMetrics method should work',
          () {
        final activity = SwimmingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
        );

        final calories = activity.calculateCaloriesWithHealthMetrics(testHealthMetrics);

        expect(calories, isNotNull);
        expect(calories, isA<double>());
        expect(calories, greaterThan(0));
      });

      test('SwimmingActivity deprecated calculateCalories method should return stored value',
          () {
        final activity = SwimmingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          caloriesBurned: 350.0,
        );

        final calories = activity.calculateCalories();
        expect(calories, 350.0);
      });

      test(
          'SwimmingActivity copyWith should create a new instance with updated values',
          () {
        final originalActivity = SwimmingActivity(
          userId: "test-user-id",
          id: 'test-id',
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          caloriesBurned: 350,
        );

        final updatedActivity = originalActivity.copyWith(
          id: 'new-id',
          date: DateTime(2023, 3, 16),
          startTime: DateTime(2023, 3, 16, 10, 0),
          endTime: DateTime(2023, 3, 16, 10, 45),
          laps: 30,
          poolLength: 50.0,
          stroke: 'Backstroke',
          caloriesBurned: 500,
        );

        expect(updatedActivity.id, 'new-id');
        expect(updatedActivity.date, DateTime(2023, 3, 16));
        expect(updatedActivity.startTime, DateTime(2023, 3, 16, 10, 0));
        expect(updatedActivity.endTime, DateTime(2023, 3, 16, 10, 45));
        expect(updatedActivity.laps, 30);
        expect(updatedActivity.poolLength, 50.0);
        expect(updatedActivity.stroke, 'Backstroke');
        expect(updatedActivity.caloriesBurned, 500);

        final partialUpdate = originalActivity.copyWith(
          laps: 25,
        );

        expect(partialUpdate.id, originalActivity.id);
        expect(partialUpdate.date, originalActivity.date);
        expect(partialUpdate.stroke, originalActivity.stroke);
        expect(partialUpdate.laps, 25);
        expect(partialUpdate.poolLength, originalActivity.poolLength);
      });
    });

    group('CardioActivityFactory Tests', () {
      test('fromMap should create RunningActivity correctly', () {
        final map = {
          'type': 'running',
          'date': testDate.millisecondsSinceEpoch,
          'startTime': testStartTime.millisecondsSinceEpoch,
          'endTime': testEndTime.millisecondsSinceEpoch,
          'distanceKm': 5.0,
          'caloriesBurned': 300.0,
        };

        final activity = CardioActivityFactory.fromMap(map);

        expect(activity, isA<RunningActivity>());
        expect(activity.type, CardioType.running);
        expect((activity as RunningActivity).distanceKm, 5.0);
      });

      test('fromMap should create CyclingActivity correctly', () {
        final map = {
          'type': 'cycling',
          'date': testDate.millisecondsSinceEpoch,
          'startTime': testStartTime.millisecondsSinceEpoch,
          'endTime': testEndTime.millisecondsSinceEpoch,
          'distanceKm': 15.0,
          'cyclingType': 'mountain',
          'caloriesBurned': 450.0,
        };

        final activity = CardioActivityFactory.fromMap(map);

        expect(activity, isA<CyclingActivity>());
        expect(activity.type, CardioType.cycling);
        expect((activity as CyclingActivity).cyclingType, CyclingType.mountain);
      });

      test('fromMap should create SwimmingActivity correctly', () {
        final map = {
          'type': 'swimming',
          'date': testDate.millisecondsSinceEpoch,
          'startTime': testStartTime.millisecondsSinceEpoch,
          'endTime': testEndTime.millisecondsSinceEpoch,
          'laps': 20,
          'poolLength': 25.0,
          'stroke': 'Freestyle (Front Crawl)',
          'caloriesBurned': 350.0,
        };

        final activity = CardioActivityFactory.fromMap(map);

        expect(activity, isA<SwimmingActivity>());
        expect(activity.type, CardioType.swimming);
        expect((activity as SwimmingActivity).laps, 20);
      });

      test('fromMap should throw for unknown activity type', () {
        final map = {
          'type': 'unknown',
          'date': testDate.millisecondsSinceEpoch,
          'startTime': testStartTime.millisecondsSinceEpoch,
          'endTime': testEndTime.millisecondsSinceEpoch,
          'caloriesBurned': 300.0,
        };

        expect(() => CardioActivityFactory.fromMap(map), throwsArgumentError);
      });

      test('fromFormData should create RunningActivity correctly', () {
        final formData = {
          'distanceKm': 5.0,
          'caloriesBurned': 300.0,
        };

        final activity = CardioActivityFactory.fromFormData(
          userId: "test-user-id",
          type: CardioType.running,
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          formData: formData,
        );

        expect(activity, isA<RunningActivity>());
        expect(activity.type, CardioType.running);
        expect((activity as RunningActivity).distanceKm, 5.0);
      });

      test('fromFormData should create CyclingActivity correctly', () {
        final formData = {
          'distanceKm': 15.0,
          'caloriesBurned': 450.0,
          'cyclingType': 'mountain',
        };

        final activity = CardioActivityFactory.fromFormData(
          userId: "test-user-id",
          type: CardioType.cycling,
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          formData: formData,
        );

        expect(activity, isA<CyclingActivity>());
        expect(activity.type, CardioType.cycling);
        expect((activity as CyclingActivity).cyclingType, CyclingType.mountain);
      });

      test('fromFormData should create SwimmingActivity correctly', () {
        final formData = {
          'caloriesBurned': 350.0,
          'laps': 20,
          'poolLength': 25.0,
          'stroke': 'Freestyle (Front Crawl)',
        };

        final activity = CardioActivityFactory.fromFormData(
          userId: "test-user-id",
          type: CardioType.swimming,
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          formData: formData,
        );

        expect(activity, isA<SwimmingActivity>());
        expect(activity.type, CardioType.swimming);
        expect((activity as SwimmingActivity).laps, 20);
      });
    });
  });
}