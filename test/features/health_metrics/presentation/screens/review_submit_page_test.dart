// review_submit_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/review_submit_page.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';

import 'review_submit_page_test.mocks.dart';

@GenerateMocks([HealthMetricsFormCubit])
void main() {
  late MockHealthMetricsFormCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthMetricsFormCubit();
    when(mockCubit.stream).thenAnswer((_) => const Stream.empty());

    // Register FakeCaloricRequirementService
    final getIt = GetIt.instance;
    if (getIt.isRegistered<CaloricRequirementService>()) {
      getIt.unregister<CaloricRequirementService>();
    }
    getIt.registerSingleton<CaloricRequirementService>(FakeCaloricRequirementService());
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<CaloricRequirementService>()) {
      getIt.unregister<CaloricRequirementService>();
    }
  });

  Widget createTestWidget(HealthMetricsFormState state) {
    when(mockCubit.state).thenReturn(state);

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => ScaffoldMessenger(
              child: BlocProvider<HealthMetricsFormCubit>.value(
                value: mockCubit,
                child: const ReviewSubmitPage(),
              ),
            ),
        '/register': (_) => const Scaffold(body: Text('Register Page')),
      },
    );
  }

  testWidgets('displays all values correctly with "Other" goal', (WidgetTester tester) async {
    final state = HealthMetricsFormState(
      selectedGoals: ["Lose Fat", "Other"],
      otherGoalReason: "Boost confidence",
      height: 180,
      weight: 75,
      birthDate: DateTime(1995, 5, 10),
      gender: "Male",
      activityLevel: "Moderately Active",
      dietType: "Keto",
      desiredWeight: 70,
      weeklyGoal: 0.5,
    );

    await tester.pumpWidget(createTestWidget(state));
    await tester.pump();

    expect(find.text("Goals: "), findsOneWidget);
    expect(find.text("Lose Fat, Other: Boost confidence"), findsOneWidget);
    expect(find.text("Height: "), findsOneWidget);
    expect(find.text("180.0 cm"), findsOneWidget);
    expect(find.text("Weight: "), findsOneWidget);
    expect(find.text("75.0 kg"), findsOneWidget);
    expect(find.text("Birth Date: "), findsOneWidget);
    expect(find.text("1995-05-10"), findsOneWidget);
    expect(find.text("Diet Type: "), findsOneWidget);
    expect(find.text("Keto"), findsOneWidget);
    expect(find.text("Desired Weight: "), findsOneWidget);
    expect(find.text("70.0 kg"), findsOneWidget);
    expect(find.text("Weekly Goal: "), findsOneWidget);
    expect(find.text("0.5 kg/week"), findsOneWidget);
  });

  testWidgets('saves onboarding flags and navigates to register page', (WidgetTester tester) async {
    final state = HealthMetricsFormState(
      selectedGoals: ["Gain Muscle"],
      height: 180,
      weight: 75,
      birthDate: DateTime(2000),
      gender: "Female",
      activityLevel: "Very Active",
      desiredWeight: 80,
      weeklyGoal: 1,
    );

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(createTestWidget(state));
    await tester.pump();

    // Tap Continue button
    await tester.tap(find.text('Continue to Create Account'));
    await tester.pumpAndSettle();

    // Check SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboardingInProgress'), isFalse);

    // Should navigate to register page
    expect(find.text('Register Page'), findsOneWidget);
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
      userId: userId,
      bmr: 1500,
      tdee: 2000,
      timestamp: DateTime.now(),
    );
  }
}