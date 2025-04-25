// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'analytics_service_test.mocks.dart';

// Use build_runner to generate mocks
@GenerateMocks([FirebaseAnalytics])

void main() {
  group('AnalyticsService Tests', () {
    late MockFirebaseAnalytics mockAnalytics;
    late AnalyticsService analyticsService;
    late FirebaseAnalyticsObserver mockObserver;

    setUp(() {
      mockAnalytics = MockFirebaseAnalytics();
      analyticsService = AnalyticsService(analytics: mockAnalytics);
      mockObserver = analyticsService.observer;

      // Setup the mocks to return Future<void> for all relevant methods
      when(mockAnalytics.logLogin(loginMethod: anyNamed('loginMethod')))
          .thenAnswer((_) => Future<void>.value());
      
      when(mockAnalytics.logSignUp(signUpMethod: anyNamed('signUpMethod')))
          .thenAnswer((_) => Future<void>.value());
          
      when(mockAnalytics.logEvent(
        name: anyNamed('name'),
        parameters: anyNamed('parameters')
      )).thenAnswer((_) => Future<void>.value());
          
      when(mockAnalytics.logScreenView(
        screenName: anyNamed('screenName'),
        screenClass: anyNamed('screenClass')
      )).thenAnswer((_) => Future<void>.value());
          
      when(mockAnalytics.setAnalyticsCollectionEnabled(any))
          .thenAnswer((_) => Future<void>.value());
    });

    test('observer returns FirebaseAnalyticsObserver', () {
      // Act
      final observer = analyticsService.observer;
      
      // Assert
      expect(observer, isA<FirebaseAnalyticsObserver>());
    });

    // COMPREHENSIVE INITIALIZE TESTS
    group('initialize', () {
      test('sets analytics collection enabled', () async {
        // Execute
        await analyticsService.initialize();
        
        // Verify
        verify(mockAnalytics.setAnalyticsCollectionEnabled(true)).called(1);
      });
      
      test('sets default event parameters', () async {
        // Execute
        await analyticsService.initialize();
        
        // Verify correct default parameters are set
        verify(mockAnalytics.setDefaultEventParameters(any)).called(1);
      });
      
      test('initialize should handle errors gracefully', () async {
        // Setup
        when(mockAnalytics.setAnalyticsCollectionEnabled(any))
            .thenThrow(Exception('Test error'));
        
        // Execute & Verify - should not throw exception
        expect(() async => await analyticsService.initialize(), returnsNormally);
      });
      
      test('stops initialization chain after error', () async {
        // Setup - first method throws an error
        when(mockAnalytics.setAnalyticsCollectionEnabled(any))
            .thenThrow(Exception('Test error'));
        when(mockAnalytics.setDefaultEventParameters(any))
            .thenAnswer((_) => Future<void>.value());
            
        // Execute
        await analyticsService.initialize();
        
        // Verify first method was called and threw
        verify(mockAnalytics.setAnalyticsCollectionEnabled(true)).called(1);
        
        // Verify second method was NOT called because of the error
        verifyNever(mockAnalytics.setDefaultEventParameters(any));
      });
    });

    // COMPREHENSIVE LOGIN TESTS
    group('logLogin', () {
      test('calls Firebase Analytics with correct method when provided', () async {
        // Execute
        await analyticsService.logLogin(method: 'google');

        // Verify
        verify(mockAnalytics.logLogin(loginMethod: 'google')).called(1);
      });
      
      test('uses default method "email" when no method provided', () async {
        // Execute
        await analyticsService.logLogin();

        // Verify
        verify(mockAnalytics.logLogin(loginMethod: 'email')).called(1);
      });
      
      test('handles errors gracefully', () async {
        // Setup
        when(mockAnalytics.logLogin(loginMethod: anyNamed('loginMethod')))
            .thenThrow(Exception('Test error'));

        // Execute & Verify
        expect(() async => await analyticsService.logLogin(), returnsNormally);
      });
    });


    // COMPREHENSIVE SIGNUP TESTS
    group('logSignUp', () {
      test('calls Firebase Analytics with correct method when provided', () async {
        // Execute
        await analyticsService.logSignUp(method: 'facebook');

        // Verify
        verify(mockAnalytics.logSignUp(signUpMethod: 'facebook')).called(1);
      });
      
      test('uses default method "email" when no method provided', () async {
        // Execute
        await analyticsService.logSignUp();

        // Verify
        verify(mockAnalytics.logSignUp(signUpMethod: 'email')).called(1);
      });
      
      test('handles errors gracefully', () async {
        // Setup
        when(mockAnalytics.logSignUp(signUpMethod: anyNamed('signUpMethod')))
            .thenThrow(Exception('Test error'));

        // Execute & Verify
        expect(() async => await analyticsService.logSignUp(), returnsNormally);
      });
    });

    // COMPREHENSIVE FOOD LOGGING TESTS
    group('logFoodAdded', () {
      test('logs event with correct parameters', () async {
        // Execute
        await analyticsService.logFoodAdded(foodName: 'Apple', calories: 95.0);

        // Use verify with argument capture instead of complex matchers
        final params = verify(mockAnalytics.logEvent(
          name: 'food_logged',
          parameters: captureAnyNamed('parameters')
        )).captured.single as Map<String, dynamic>;
        
        // Verify captured parameters
        expect(params['food_name'], equals('Apple'));
        expect(params['calories'], equals(95.0));
        expect(params['timestamp'], isNotNull);
      });
      
      test('handles null calories', () async {
        // Execute
        await analyticsService.logFoodAdded(foodName: 'Orange');

        // Use verify with argument capture instead of complex matchers
        final params = verify(mockAnalytics.logEvent(
          name: 'food_logged',
          parameters: captureAnyNamed('parameters')
        )).captured.single as Map<String, dynamic>;
        
        // Verify captured parameters
        expect(params['food_name'], equals('Orange'));
        expect(params['calories'], isNull);
        expect(params['timestamp'], isNotNull);
      });
      
      test('handles errors gracefully', () async {
        // Setup
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters')
        )).thenThrow(Exception('Test error'));

        // Execute & Verify
        expect(() async => await analyticsService.logFoodAdded(foodName: 'Apple'), returnsNormally);
      });
    });

    // COMPREHENSIVE EXERCISE LOGGING TESTS
    group('logExerciseAdded', () {
      test('logs event with all parameters', () async {
        // Execute
        await analyticsService.logExerciseAdded(
          exerciseType: 'cardio',
          exerciseName: 'Running',
          duration: 30
        );

        // Use verify with argument capture instead of complex matchers
        final params = verify(mockAnalytics.logEvent(
          name: 'exercise_logged',
          parameters: captureAnyNamed('parameters')
        )).captured.single as Map<String, dynamic>;
        
        // Verify captured parameters
        expect(params['exercise_type'], equals('cardio'));
        expect(params['exercise_name'], equals('Running'));
        expect(params['duration'], equals(30));
        expect(params['timestamp'], isNotNull);
      });
      
      test('handles optional parameters correctly', () async {
        // Execute
        await analyticsService.logExerciseAdded(exerciseType: 'strength');

        // Use verify with argument capture instead of complex matchers
        final params = verify(mockAnalytics.logEvent(
          name: 'exercise_logged',
          parameters: captureAnyNamed('parameters')
        )).captured.single as Map<String, dynamic>;
        
        // Verify captured parameters
        expect(params['exercise_type'], equals('strength'));
        expect(params['exercise_name'], isNull);
        expect(params['duration'], isNull);
        expect(params['timestamp'], isNotNull);
      });
    });

    // SCREEN VIEW TESTS
    group('logScreenView', () {
      test('calls Firebase Analytics with correct parameters', () async {
        // Execute
        await analyticsService.logScreenView(
          screenName: 'test_screen',
          screenClass: 'TestScreen',
        );

        // Verify
        verify(mockAnalytics.logScreenView(
          screenName: 'test_screen',
          screenClass: 'TestScreen',
        )).called(1);
      });
      
      test('handles null screenClass', () async {
        // Execute
        await analyticsService.logScreenView(screenName: 'test_screen');

        // Verify
        verify(mockAnalytics.logScreenView(
          screenName: 'test_screen',
          screenClass: null,
        )).called(1);
      });
      
      test('handles errors gracefully', () async {
        // Setup
        when(mockAnalytics.logScreenView(
          screenName: anyNamed('screenName'),
          screenClass: anyNamed('screenClass')
        )).thenThrow(Exception('Test error'));

        // Execute & Verify
        expect(() async => await analyticsService.logScreenView(screenName: 'error_screen'), returnsNormally);
      });
    });

    // PROGRESS VIEWED TESTS
    group('logProgressViewed', () {
      test('logs event with category when provided', () async {
        // Execute
        await analyticsService.logProgressViewed(category: 'weight');

        // Use verify with argument capture instead of complex matchers
        final params = verify(mockAnalytics.logEvent(
          name: 'progress_viewed',
          parameters: captureAnyNamed('parameters')
        )).captured.single as Map<String, dynamic>;
        
        // Verify captured parameters
        expect(params['category'], equals('weight'));
        expect(params['timestamp'], isNotNull);
      });
      
      test('uses default category "all" when not provided', () async {
        // Execute
        await analyticsService.logProgressViewed();

        // Use verify with argument capture instead of complex matchers
        final params = verify(mockAnalytics.logEvent(
          name: 'progress_viewed',
          parameters: captureAnyNamed('parameters')
        )).captured.single as Map<String, dynamic>;
        
        // Verify captured parameters
        expect(params['category'], equals('all'));
        expect(params['timestamp'], isNotNull);
      });
    });

    // HEALTH METRICS TESTS
    group('logHealthMetricsUpdated', () {
      test('logs event with timestamp', () async {
        // Execute
        await analyticsService.logHealthMetricsUpdated();

        // Use verify with argument capture instead of complex matchers
        final params = verify(mockAnalytics.logEvent(
          name: 'health_metrics_updated',
          parameters: captureAnyNamed('parameters')
        )).captured.single as Map<String, dynamic>;
        
        // Verify captured parameters
        expect(params['timestamp'], isNotNull);
      });
    });

    // ANALYTICS COLLECTION TESTS
    group('setAnalyticsCollectionEnabled', () {
      test('enables analytics collection', () async {
        // Execute
        await analyticsService.setAnalyticsCollectionEnabled(true);

        // Verify
        verify(mockAnalytics.setAnalyticsCollectionEnabled(true)).called(1);
      });
      
      test('disables analytics collection', () async {
        // Execute
        await analyticsService.setAnalyticsCollectionEnabled(false);

        // Verify
        verify(mockAnalytics.setAnalyticsCollectionEnabled(false)).called(1);
      });
      
      test('handles errors gracefully', () async {
        // Setup
        when(mockAnalytics.setAnalyticsCollectionEnabled(any))
            .thenThrow(Exception('Test error'));

        // Execute & Verify
        expect(() async => await analyticsService.setAnalyticsCollectionEnabled(true), returnsNormally);
      });
    });

    // CUSTOM EVENT TESTS
    group('logEvent', () {
      test('logs custom event with parameters', () async {
        // Setup
        final params = {'key': 'value', 'count': 42};
        
        // Execute
        await analyticsService.logEvent(
          name: 'custom_event',
          parameters: params,
        );

        // Verify
        verify(mockAnalytics.logEvent(
          name: 'custom_event',
          parameters: params,
        )).called(1);
      });
      
      test('logs custom event without parameters', () async {
        // Execute
        await analyticsService.logEvent(name: 'simple_event');

        // Verify
        verify(mockAnalytics.logEvent(
          name: 'simple_event',
          parameters: null,
        )).called(1);
      });
      
      test('handles errors gracefully', () async {
        // Setup
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters')
        )).thenThrow(Exception('Test error'));

        // Execute & Verify
        expect(() async => await analyticsService.logEvent(name: 'error_event'), returnsNormally);
      });
    });
  });
}
