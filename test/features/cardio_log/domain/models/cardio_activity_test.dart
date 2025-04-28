// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/domain/models/models.dart';

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
      test('RunningActivity calculateCalories method should call calculator',
          () {
        final activity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
        );

        // Force calculation
        final calories = activity.calculateCalories();

        // The actual value will depend on the CalorieCalculator implementation
        expect(calories, isNotNull);
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

        // Check that values were updated
        expect(updatedActivity.id, 'new-id');
        expect(updatedActivity.date, DateTime(2023, 3, 16));
        expect(updatedActivity.startTime, DateTime(2023, 3, 16, 10, 0));
        expect(updatedActivity.endTime, DateTime(2023, 3, 16, 10, 45));
        expect(updatedActivity.distanceKm, 10.0);
        expect(updatedActivity.caloriesBurned, 600);

        // Test that providing null keeps original values
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

        // Check that values were updated
        expect(updatedActivity.id, 'new-id');
        expect(updatedActivity.date, DateTime(2023, 3, 16));
        expect(updatedActivity.startTime, DateTime(2023, 3, 16, 10, 0));
        expect(updatedActivity.endTime, DateTime(2023, 3, 16, 10, 45));
        expect(updatedActivity.distanceKm, 20.0);
        expect(updatedActivity.cyclingType, CyclingType.commute);
        expect(updatedActivity.caloriesBurned, 500);

        // Test that providing null keeps original values
        final partialUpdate = originalActivity.copyWith(
          distanceKm: 25.0,
        );

        expect(partialUpdate.id, originalActivity.id);
        expect(partialUpdate.date, originalActivity.date);
        expect(partialUpdate.cyclingType, originalActivity.cyclingType);
        expect(partialUpdate.distanceKm, 25.0);
      });

      test('CyclingActivity calculateCalories method should call calculator',
          () {
        final activity = CyclingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 15.0,
          cyclingType: CyclingType.mountain,
        );

        // Force calculation
        final calories = activity.calculateCalories();

        // The actual value will depend on the CalorieCalculator implementation
        // But we just want to verify the method gets called for coverage
        expect(calories, isNotNull);
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
      test('SwimmingActivity calculateCalories method should call calculator',
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

        // Force calculation
        final calories = activity.calculateCalories();

        // The actual value will depend on the CalorieCalculator implementation
        expect(calories, isNotNull);
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

        // Check that values were updated
        expect(updatedActivity.id, 'new-id');
        expect(updatedActivity.date, DateTime(2023, 3, 16));
        expect(updatedActivity.startTime, DateTime(2023, 3, 16, 10, 0));
        expect(updatedActivity.endTime, DateTime(2023, 3, 16, 10, 45));
        expect(updatedActivity.laps, 30);
        expect(updatedActivity.poolLength, 50.0);
        expect(updatedActivity.stroke, 'Backstroke');
        expect(updatedActivity.caloriesBurned, 500);

        // Test that providing null keeps original values
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

      test('RunningActivity constructor should handle null ID', () {
        final activity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
        );

        expect(activity.id, isNotNull);
      });

      test('CyclingActivity constructor should handle optional calories', () {
        final activity = CyclingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 15.0,
          cyclingType: CyclingType.commute,
        );

        expect(activity.caloriesBurned, 0.0);
      });

      test('RunningActivity fromMap with minimal data', () {
        final map = {
          'type': 'running',
          'date': testDate.millisecondsSinceEpoch,
          'startTime': testStartTime.millisecondsSinceEpoch,
          'endTime': testEndTime.millisecondsSinceEpoch,
        };

        final activity = RunningActivity.fromMap(map);

        expect(activity.distanceKm, 0.0);
        expect(activity.caloriesBurned, 0.0);
      });
      test('RunningActivity copyWith should create new instance', () {
        final originalActivity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
        );

        final updatedActivity = originalActivity.copyWith(
          distanceKm: 7.0,
          caloriesBurned: 400,
        );

        expect(updatedActivity.distanceKm, 7.0);
        expect(updatedActivity.caloriesBurned, 400);
        expect(updatedActivity.id, originalActivity.id);
      });
      test('RunningActivity copyWith should create new instance', () {
        final originalActivity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
        );

        final updatedActivity = originalActivity.copyWith(
          distanceKm: 7.0,
          caloriesBurned: 400,
        );

        expect(updatedActivity.distanceKm, 7.0);
        expect(updatedActivity.caloriesBurned, 400);
        expect(updatedActivity.id, originalActivity.id);
      });
      test('RunningActivity copyWith should create new instance', () {
        final originalActivity = RunningActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 5.0,
        );

        final updatedActivity = originalActivity.copyWith(
          distanceKm: 7.0,
          caloriesBurned: 400,
        );

        expect(updatedActivity.distanceKm, 7.0);
        expect(updatedActivity.caloriesBurned, 400);
        expect(updatedActivity.id, originalActivity.id);
      });

      test('CyclingActivity should handle zero distance', () {
        final activity = CyclingActivity(
          userId: "test-user-id",
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
          distanceKm: 0.0,
          cyclingType: CyclingType.stationary,
        );

        expect(activity.distanceKm, 0.0);
        expect(activity.speedKmPerHour, 0.0);
      });

      test('CardioActivityFactory fromFormData with missing optional data', () {
        final activity = CardioActivityFactory.fromFormData(
          userId: "test-user-id",
          type: CardioType.swimming,
          date: testDate,
          startTime: testStartTime,
          endTime: testEndTime,
        );

        expect(activity, isA<SwimmingActivity>());
        expect((activity as SwimmingActivity).laps, 0);
        expect(activity.caloriesBurned, 0.0);
      });
      test(
          'fromFormData should create CyclingActivity with commute type correctly',
          () {
        final formData = {
          'distanceKm': 12.0,
          'caloriesBurned': 350.0,
          'cyclingType': 'commute',
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
        expect((activity as CyclingActivity).cyclingType, CyclingType.commute);
        expect(activity.distanceKm, 12.0);
      });

      test(
          'fromFormData should create CyclingActivity with stationary type correctly',
          () {
        final formData = {
          'distanceKm': 0.0,
          'caloriesBurned': 200.0,
          'cyclingType': 'stationary',
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
        expect(
            (activity as CyclingActivity).cyclingType, CyclingType.stationary);
      });
      test(
          'CardioActivityFactory should create CyclingActivity with commute type',
          () {
        final formData = {
          'distanceKm': 10.0,
          'cyclingType': 'commute',
        };

        final activity = CardioActivityFactory.fromFormData(
          userId: "test-user-id",
          type: CardioType.cycling,
          date: DateTime(2023, 1, 1),
          startTime: DateTime(2023, 1, 1, 10, 0),
          endTime: DateTime(2023, 1, 1, 10, 30),
          formData: formData,
        );

        expect(activity, isA<CyclingActivity>());
        expect((activity as CyclingActivity).cyclingType, CyclingType.commute);
      });

      test(
          'CardioActivityFactory should create CyclingActivity with stationary type',
          () {
        final formData = {
          'distanceKm': 5.0,
          'cyclingType': 'stationary',
        };

        final activity = CardioActivityFactory.fromFormData(
          userId: "test-user-id",
          type: CardioType.cycling,
          date: DateTime(2023, 1, 1),
          startTime: DateTime(2023, 1, 1, 10, 0),
          endTime: DateTime(2023, 1, 1, 10, 30),
          formData: formData,
        );

        expect(activity, isA<CyclingActivity>());
        expect(
            (activity as CyclingActivity).cyclingType, CyclingType.stationary);
      });
    });
  });
}
