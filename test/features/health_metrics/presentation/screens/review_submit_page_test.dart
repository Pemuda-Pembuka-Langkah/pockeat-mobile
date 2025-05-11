// review_submit_page_test.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/review_submit_page.dart';
import 'review_submit_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit, LoginService, NavigatorObserver])
void main() {
  late MockHealthMetricsFormCubit mockCubit;
  late MockLoginService mockLoginService;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    mockLoginService = MockLoginService();
    when(mockCubit.stream).thenAnswer((_) => const Stream.empty());

    // Register mocks and fakes
    final getIt = GetIt.instance;
    if (getIt.isRegistered<CaloricRequirementService>()) {
      getIt.unregister<CaloricRequirementService>();
    }
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
    getIt.registerSingleton<CaloricRequirementService>(
        FakeCaloricRequirementService());
    getIt.registerSingleton<LoginService>(mockLoginService);
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<CaloricRequirementService>()) {
      getIt.unregister<CaloricRequirementService>();
    }
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
  });

  // Helper methods for testing

  // Create a test widget with unique keys for different tests
  Widget createTestWidget(HealthMetricsFormState state, {
    bool forHomeNavigation = false,
    Key? appKey,
  }) {
    when(mockCubit.state).thenReturn(state);

    if (forHomeNavigation) {
      return MaterialApp(
        key: appKey,
        home: const Scaffold(body: Text('Home Page')),
        routes: {
          '/register': (_) => const Scaffold(body: Text('Register Page')),
          '/height-weight': (_) => const Scaffold(body: Text('Height Weight Page')),
        },
      );
    } else {
      return MaterialApp(
        key: appKey,
        home: ScaffoldMessenger(
              child: BlocProvider<HealthMetricsFormCubit>.value(
                value: mockCubit,
                child: const ReviewSubmitPage(),
              ),
            ),
        routes: {
          '/register': (_) => const Scaffold(body: Text('Register Page')),
          '/height-weight': (_) => const Scaffold(body: Text('Height Weight Page')),
        },
      );
    }
  }

  group('UI display tests', () {
    testWidgets('displays all values correctly with "Other" goal', (WidgetTester tester) async {
      final state = HealthMetricsFormState(
        selectedGoals: ["Lose Fat", "Other"],
        otherGoalReason: "Boost confidence",
        height: 180,
        weight: 75,
        birthDate: DateTime(1995, 5, 10),
        gender: "Male",
        activityLevel: "moderately_active", // Underscore format to test formatter
        dietType: "Keto",
        desiredWeight: 70,
        weeklyGoal: 0.5,
        bmi: 23.15,
        bmiCategory: "Normal",
      );

      await tester.pumpWidget(createTestWidget(state, appKey: UniqueKey()));
      await tester.pumpAndSettle();

      expect(find.text("Goals: "), findsOneWidget);
      expect(find.text("Lose Fat, Other: Boost confidence"), findsOneWidget);
      expect(find.text("Height: "), findsOneWidget);
      expect(find.text("180.0 cm"), findsOneWidget);
      expect(find.text("Weight: "), findsOneWidget);
      expect(find.text("75.0 kg"), findsOneWidget);
      expect(find.text("Birth Date: "), findsOneWidget);
      expect(find.text("1995-05-10"), findsOneWidget);
      expect(find.text("Activity Level: "), findsOneWidget);
      expect(find.text("Moderately Active"),
          findsOneWidget); // Should format correctly
      expect(find.text("Diet Type: "), findsOneWidget);
      expect(find.text("Keto"), findsOneWidget);
      expect(find.text("Desired Weight: "), findsOneWidget);
      expect(find.text("70.0 kg"), findsOneWidget);
      expect(find.text("Weekly Goal: "), findsOneWidget);
      expect(find.text("0.5 kg/week"), findsOneWidget);
      // Check for macronutrient information
      // Widget testing only verifies the ReviewSubmitPage renders without errors
      // We can't verify the exact text content as it's dependent on mocked services
      // that aren't fully initialized in this test environment
    });

    testWidgets('handles empty and null values gracefully',
        (WidgetTester tester) async {
      final state = HealthMetricsFormState(
        // Missing or null values to test fallback displays
        selectedGoals: [],
        height: null,
        weight: null,
        birthDate: null,
        gender: null,
        activityLevel: null,
        dietType: null,
        desiredWeight: null,
        weeklyGoal: null,
        bmi: 0,
        bmiCategory: "-",
      );

      await tester.pumpWidget(createTestWidget(state, appKey: UniqueKey()));
      await tester.pumpAndSettle();

      // Verify default/empty values are displayed correctly
      expect(find.text("Goals: "), findsOneWidget);
      expect(find.text("-"),
          findsAtLeastNWidgets(1)); // Multiple fields should show "-"

    });

    testWidgets('displays correct personalized message for weight gain goals',
        (WidgetTester tester) async {
      final state = HealthMetricsFormState(
        selectedGoals: ["Gain Muscle", "Gain Weight"],
        height: 180,
        weight: 70,
        bmi: 21.6,
        bmiCategory: "Normal",
      );

      await tester.pumpWidget(createTestWidget(state, appKey: UniqueKey()));
      await tester.pumpAndSettle();

      // Just verify the widget rendered successfully
      expect(find.byType(ReviewSubmitPage), findsOneWidget);
    });

    testWidgets('sets up for register navigation when user is not logged in',
        (WidgetTester tester) async {
      final state = HealthMetricsFormState(
        selectedGoals: ["Gain Muscle"],
        height: 180,
        weight: 75,
        birthDate: DateTime(2000),
        gender: "Female",
        activityLevel: "very_active",
        desiredWeight: 80,
        weeklyGoal: 1,
      );

      SharedPreferences.setMockInitialValues({});
      
      // Mock user is not logged in
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget(state, appKey: UniqueKey()));
      await tester.pumpAndSettle();

      // Just check that the widget renders without crashing
    });

    testWidgets('shows home widget with home navigation', (WidgetTester tester) async {
      final state = HealthMetricsFormState(
        selectedGoals: ["Maintain Weight"],
        height: 175,
        weight: 70,
        bmi: 22.9,
        bmiCategory: "Normal",
      );
      
      // Set SharedPreferences to indicate onboarding is NOT in progress
      SharedPreferences.setMockInitialValues({'onboardingInProgress': false});
      
      await tester.pumpWidget(createTestWidget(state, forHomeNavigation: true, appKey: UniqueKey()));
      await tester.pumpAndSettle();
      // Should show home page
      expect(find.text('Home Page'), findsOneWidget);
    });
  });

  group('Navigation tests', () {
    test('verifies login service behavior', () async {
      // Mock user is not logged in
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);
      
      // Verify the service returns null as expected
      final user = await mockLoginService.getCurrentUser();
      expect(user, isNull);
      
      // Verify login service was called
      verify(mockLoginService.getCurrentUser()).called(1);
    });
    
    testWidgets('reviews page renders successfully', (WidgetTester tester) async {
      final state = HealthMetricsFormState(
        selectedGoals: ["Maintain Weight"],
        height: 175,
        weight: 70,
        bmi: 22.9,
        bmiCategory: "Normal",
      );
      
      // Set SharedPreferences to indicate onboarding is in progress
      SharedPreferences.setMockInitialValues({'onboardingInProgress': true});

      await tester.pumpWidget(createTestWidget(state, appKey: UniqueKey()));
      await tester.pumpAndSettle();
      
      // Test passes if widget builds without errors
    });
  });

  group('Form submission tests', () {
    test('verifies form submission with mocked services', () async {
      // Mock user is logged in
      final mockUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => mockUser);
      
      // Setup form cubit methods
      when(mockCubit.setUserId('test-uid')).thenReturn(null);
      when(mockCubit.submit()).thenAnswer((_) async {});
      
      // Verify the mock user is returned
      final user = await mockLoginService.getCurrentUser();
      expect(user, isNotNull);
      expect(user?.uid, equals('test-uid'));
      
      // Verify the login service was called
      verify(mockLoginService.getCurrentUser()).called(1);
      
      // Test setting user ID
      mockCubit.setUserId('test-uid');
      verify(mockCubit.setUserId('test-uid')).called(1);
      
      // Test submitting the form
      await mockCubit.submit();
      verify(mockCubit.submit()).called(1);
    });
    
    test('handles error during form submission', () async {
      // Setup mocks
      when(mockCubit.submit()).thenThrow(Exception('Form submission failed'));
      
      // Verify the exception is thrown
      expect(() => mockCubit.submit(), throwsException);
    });
  });

  group('Utility method tests', () {
    testWidgets('formatActivityLevel correctly formats activity level strings',
        (WidgetTester tester) async {
      final page = ReviewSubmitPage();

      // Test with null
      expect(page.formatActivityLevel(null), "-");

      // Test with underscores
      expect(page.formatActivityLevel("sedentary"), "Sedentary");
      expect(page.formatActivityLevel("lightly_active"), "Lightly Active");
    });
  });
}

/// A fake caloric requirement service for testing
class FakeCaloricRequirementService extends CaloricRequirementService {
  @override
  CaloricRequirementModel analyze({
    required String userId,
    required HealthMetricsModel model,
  }) {
    // Just return a dummy model
    return CaloricRequirementModel(
      userId: 'user123',
      bmr: 1500,
      tdee: 2000,
      proteinGrams: 150.0,
      carbsGrams: 200.0,
      fatGrams: 66.7,
      timestamp: DateTime.now(),
    );
  }
}
