import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/cardio_log/domain/models/user_constants.dart';
import 'package:pockeat/features/cardio_log/services/calorie_calculator.dart';

void main() {
  group('CalorieCalculator Tests', () {
    setUp(() {
      // Set up user constants for consistent tests
      UserConstants.weight = 70; // kg
      UserConstants.height = 170; // cm
      UserConstants.age = 30;
      UserConstants.gender = 'Male';
    });

    group('Basic Functionality Tests', () {
      test('calculateBMR should calculate correct BMR for male', () {
        UserConstants.gender = 'Male';
        double bmr = CalorieCalculator.calculateBMR();
        
        // BMR formula for men: (10 * weight) + (6.25 * height) - (5 * age) + 5
        double expectedBMR = (10 * 70) + (6.25 * 170) - (5 * 30) + 5;
        expect(bmr, expectedBMR);
      });

      test('calculateBMR should calculate correct BMR for female', () {
        UserConstants.gender = 'Female';
        double bmr = CalorieCalculator.calculateBMR();
        
        // BMR formula for women: (10 * weight) + (6.25 * height) - (5 * age) - 161
        double expectedBMR = (10 * 70) + (6.25 * 170) - (5 * 30) - 161;
        expect(bmr, expectedBMR);
      });

      test('calculateCaloriesWithMET should calculate calories based on MET and duration', () {
        double bmr = CalorieCalculator.calculateBMR();
        double met = 8.0;
        Duration duration = const Duration(minutes: 60);
        
        double caloriesPerMinute = (bmr / 1440) * met;
        double expectedCalories = caloriesPerMinute * 60;
        
        double result = CalorieCalculator.calculateCaloriesWithMET(
          met: met,
          duration: duration,
        );
        
        expect(result, expectedCalories);
      });
    });

    group('Input Validation Tests', () {
      test('validateInputs should throw error for negative distance', () {
        expect(() => CalorieCalculator.validateInputs(
          distanceKm: -1.0,
          duration: const Duration(minutes: 30),
        ), throwsArgumentError);
      });

      test('validateInputs should throw error for zero duration', () {
        expect(() => CalorieCalculator.validateInputs(
          distanceKm: 5.0,
          duration: const Duration(seconds: 0),
        ), throwsArgumentError);
      });

      test('validateInputs should not throw error for valid inputs', () {
        expect(() => CalorieCalculator.validateInputs(
          distanceKm: 5.0,
          duration: const Duration(minutes: 30),
        ), returnsNormally);
      });
    });

    group('Running Calorie Calculation Tests', () {
      test('getRunningMETBySpeed should return correct MET value for different speeds', () {
        expect(CalorieCalculator.getRunningMETBySpeed(7.5), 7.0);   // Jogging lambat
        expect(CalorieCalculator.getRunningMETBySpeed(8.2), 8.5);   // 8-8.4 km/h
        expect(CalorieCalculator.getRunningMETBySpeed(8.7), 9.0);   // 8.5-8.9 km/h
        expect(CalorieCalculator.getRunningMETBySpeed(9.5), 9.3);   // 9-10 km/h
        expect(CalorieCalculator.getRunningMETBySpeed(10.5), 10.5); // 10-11 km/h
        expect(CalorieCalculator.getRunningMETBySpeed(11.5), 11.0); // 11-12 km/h
        expect(CalorieCalculator.getRunningMETBySpeed(13.0), 12.5); // 12-14 km/h
        expect(CalorieCalculator.getRunningMETBySpeed(15.0), 14.8); // 14-16 km/h
        expect(CalorieCalculator.getRunningMETBySpeed(17.0), 16.8); // 16-17.5 km/h
        expect(CalorieCalculator.getRunningMETBySpeed(18.0), 18.5); // > 17.5 km/h
      });

      test('calculateRunningCalories should calculate correct calories for running', () {
        double distance = 5.0; // km
        Duration duration = const Duration(minutes: 30);
        
        // Kecepatan: 5 km / 0.5 jam = 10 km/h
        // MET for 10 km/h should be 9.3
        double speed = (distance / duration.inSeconds) * 3600;
        double met = CalorieCalculator.getRunningMETBySpeed(speed);
        
        double expectedCalories = CalorieCalculator.calculateCaloriesWithMET(
          met: met,
          duration: duration,
        );
        
        double result = CalorieCalculator.calculateRunningCalories(
          distanceKm: distance,
          duration: duration,
        );
        
        expect(result, expectedCalories);
      });

      test('calculateRunningCalories should throw error for invalid inputs', () {
        expect(() => CalorieCalculator.calculateRunningCalories(
          distanceKm: -1.0,
          duration: const Duration(minutes: 30),
        ), throwsArgumentError);
        
        expect(() => CalorieCalculator.calculateRunningCalories(
          distanceKm: 5.0,
          duration: const Duration(seconds: 0),
        ), throwsArgumentError);
      });
    });

    group('Cycling Calorie Calculation Tests', () {
      test('getCyclingMETBySpeed should return correct MET value for different speeds and types', () {
        // Mountain biking has a fixed MET
        expect(CalorieCalculator.getCyclingMETBySpeed(10.0, 'mountain'), 8.5);
        expect(CalorieCalculator.getCyclingMETBySpeed(30.0, 'mountain'), 8.5);
        
        // Stationary biking has a fixed MET
        expect(CalorieCalculator.getCyclingMETBySpeed(10.0, 'stationary'), 6.8);
        
        // Commute biking varies by speed
        expect(CalorieCalculator.getCyclingMETBySpeed(15.0, 'commute'), 4.0);  // < 16 km/h
        expect(CalorieCalculator.getCyclingMETBySpeed(18.0, 'commute'), 6.8);  // 16-19 km/h
        expect(CalorieCalculator.getCyclingMETBySpeed(20.0, 'commute'), 8.0);  // 19-22 km/h
        expect(CalorieCalculator.getCyclingMETBySpeed(24.0, 'commute'), 10.0); // 22-25 km/h
        expect(CalorieCalculator.getCyclingMETBySpeed(27.0, 'commute'), 12.0); // 25-30 km/h
        expect(CalorieCalculator.getCyclingMETBySpeed(35.0, 'commute'), 16.0); // > 30 km/h
      });

      test('calculateCyclingCalories should calculate correct calories for cycling', () {
        double distance = 10.0; // km
        Duration duration = const Duration(minutes: 45);
        String type = 'mountain';
        
        double result = CalorieCalculator.calculateCyclingCalories(
          distanceKm: distance,
          duration: duration,
          cyclingType: type,
        );
        
        // Manual calculation to verify
        double speed = (distance / duration.inSeconds) * 3600;
        double met = CalorieCalculator.getCyclingMETBySpeed(speed, type);
        double expectedCalories = CalorieCalculator.calculateCaloriesWithMET(
          met: met,
          duration: duration,
        );
        
        expect(result, expectedCalories);
      });

      test('calculateCyclingCalories should throw error for invalid inputs', () {
        expect(() => CalorieCalculator.calculateCyclingCalories(
          distanceKm: -1.0,
          duration: const Duration(minutes: 30),
          cyclingType: 'mountain',
        ), throwsArgumentError);
        
        expect(() => CalorieCalculator.calculateCyclingCalories(
          distanceKm: 5.0,
          duration: const Duration(seconds: 0),
          cyclingType: 'mountain',
        ), throwsArgumentError);
      });
    });

    group('Swimming Calorie Calculation Tests', () {
      test('getSwimmingMETBySpeedAndStroke should return correct MET values', () {
        // Slow speed (less than 25 m/min)
        expect(
          CalorieCalculator.getSwimmingMETBySpeedAndStroke(20, 'Freestyle (Front Crawl)'),
          7.8 * 0.8 // base MET * 0.8 for slow
        );
        
        // Medium speed (25-50 m/min)
        expect(
          CalorieCalculator.getSwimmingMETBySpeedAndStroke(30, 'Freestyle (Front Crawl)'),
          7.8 // base MET for medium
        );
        
        // Fast speed (more than 50 m/min)
        expect(
          CalorieCalculator.getSwimmingMETBySpeedAndStroke(60, 'Freestyle (Front Crawl)'),
          7.8 * 1.2 // base MET * 1.2 for fast
        );
        
        // Different strokes
        expect(
          CalorieCalculator.getSwimmingMETBySpeedAndStroke(30, 'Breaststroke'),
          10.3 // base MET for breaststroke
        );
        
        expect(
          CalorieCalculator.getSwimmingMETBySpeedAndStroke(30, 'Backstroke'),
          7.15 // base MET for backstroke
        );
        
        expect(
          CalorieCalculator.getSwimmingMETBySpeedAndStroke(30, 'Butterfly'),
          13.8 // base MET for butterfly
        );
      });

      test('calculateSwimmingCalories should calculate correct calories for swimming', () {
        int laps = 20;
        double poolLength = 25.0; // meters
        String stroke = 'Freestyle (Front Crawl)';
        Duration duration = const Duration(minutes: 30);
        
        double result = CalorieCalculator.calculateSwimmingCalories(
          laps: laps,
          poolLength: poolLength,
          stroke: stroke,
          duration: duration,
        );
        
        // Manual calculation to verify
        double distance = laps * poolLength;
        double speedMetersPerMinute = distance / (duration.inSeconds / 60);
        double met = CalorieCalculator.getSwimmingMETBySpeedAndStroke(speedMetersPerMinute, stroke);
        double expectedCalories = CalorieCalculator.calculateCaloriesWithMET(
          met: met,
          duration: duration,
        );
        
        expect(result, expectedCalories);
      });

      test('calculateSwimmingCalories should throw error for invalid inputs', () {
        expect(() => CalorieCalculator.calculateSwimmingCalories(
          laps: 0,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          duration: const Duration(minutes: 30),
        ), throwsArgumentError);
        
        expect(() => CalorieCalculator.calculateSwimmingCalories(
          laps: 20,
          poolLength: 0,
          stroke: 'Freestyle (Front Crawl)',
          duration: const Duration(minutes: 30),
        ), throwsArgumentError);
        
        expect(() => CalorieCalculator.calculateSwimmingCalories(
          laps: 20,
          poolLength: 25.0,
          stroke: 'Freestyle (Front Crawl)',
          duration: const Duration(seconds: 0),
        ), throwsArgumentError);
      });
    });
  });
} 