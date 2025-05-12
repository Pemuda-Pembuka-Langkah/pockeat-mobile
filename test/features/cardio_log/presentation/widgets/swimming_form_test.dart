// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/presentation/widgets/personal_data_reminder.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/swimming_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/time_selection_widget.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

void main() {
  late SwimmingForm swimmingForm;
  final Color primaryPink = const Color(0xFFFF6B6B);
  double calculatedCalories = 0.0;
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

    // Initialize with proper GlobalKey to access state
    swimmingForm = SwimmingForm(
      key: GlobalKey<SwimmingFormState>(),
      primaryPink: primaryPink,
      healthMetrics: testHealthMetrics,
      onCalculate: (laps, poolLength, stroke, duration) {
        calculatedCalories = laps * poolLength * 0.1;
        return calculatedCalories;
      },
    );
  });

  Widget createTestableWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(body: widget),
    );
  }

  group('SwimmingForm Widget Tests', () {
    testWidgets('should render all components correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Verify all expected components are present
      expect(find.byType(PersonalDataReminder), findsOneWidget);
      expect(find.byType(TimeSelectionWidget), findsOneWidget);

      // Check swimming-specific elements
      expect(find.text('Swimming Stroke'), findsOneWidget);
      expect(find.text('Pool Length'), findsOneWidget);
      expect(find.text('Laps'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.byType(Slider),
          findsNWidgets(2)); // Pool length and laps sliders

      // Verify text elements are present
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);

      // Verify default values displayed
      expect(find.text('25.0 meters'), findsOneWidget);
      expect(find.text('20 laps'), findsOneWidget);
      expect(find.text('Freestyle (Front Crawl)'), findsOneWidget);
      expect(find.text('Total Distance: 500.0 meters'), findsOneWidget);
    });

    testWidgets('selecting different stroke should update state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;

      // Record the initial stroke
      final initialStroke = currentState.selectedStroke;

      // Directly update the state
      currentState.selectedStroke = 'Backstroke';
      await tester.pump();

      // Verify state updated
      expect(currentState.selectedStroke, 'Backstroke');
      expect(currentState.selectedStroke, isNot(equals(initialStroke)));
    });

    testWidgets('changing pool length should update state and total distance',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Get pool length slider
      final Slider slider = tester.widget(find.byType(Slider).first);

      // Move slider to 50 meters
      slider.onChanged!(50.0);
      await tester.pump();

      // Verify pool length and total distance updated
      expect(find.text('50.0 meters'), findsOneWidget);
      expect(find.text('Total Distance: 1000.0 meters'), findsOneWidget);
    });

    testWidgets('changing laps should update state and total distance',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Get laps slider (second slider)
      final Slider slider = tester.widget(find.byType(Slider).at(1));

      // Move slider to 40 laps
      slider.onChanged!(40.0);
      await tester.pump();

      // Verify laps and total distance updated
      expect(find.text('40 laps'), findsOneWidget);
      expect(find.text('Total Distance: 1000.0 meters'), findsOneWidget);
    });

    testWidgets(
        'start time changes should update state and handle time conflicts',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;

      // Initial start time
      final initialStartTime = currentState.selectedStartTime;

      // Find TimeSelectionWidget
      final timeWidget =
          tester.widget<TimeSelectionWidget>(find.byType(TimeSelectionWidget));

      // Set new start time (12:00 PM today)
      final now = DateTime.now();
      final newStartTime = DateTime(now.year, now.month, now.day, 12, 0);
      timeWidget.onStartTimeChanged(newStartTime);
      await tester.pump();

      // Verify start time was updated
      expect(currentState.selectedStartTime.hour, 12);
      expect(currentState.selectedStartTime.minute, 0);
      expect(currentState.selectedStartTime != initialStartTime, true);

      // Verify end time is still after start time
      expect(
          currentState.selectedEndTime.isAfter(currentState.selectedStartTime),
          true);
    });

    testWidgets(
        'end time changes should update state and handle time conflicts',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;

      // Set initial times for testing
      final now = DateTime.now();
      final initialStartTime =
          DateTime(now.year, now.month, now.day, 10, 0); // 10:00 AM today

      // Direct modification of state properties
      currentState.selectedStartTime = initialStartTime;
      currentState.selectedEndTime =
          initialStartTime.add(const Duration(hours: 1)); // 11:00 AM today
      await tester.pump();

      // Find TimeSelectionWidget
      final timeWidget =
          tester.widget<TimeSelectionWidget>(find.byType(TimeSelectionWidget));

      // Set end time to before start time (9:00 AM)
      final newEndTime = DateTime(now.year, now.month, now.day, 9, 0);
      timeWidget.onEndTimeChanged(newEndTime);
      await tester.pump();

      // Verify end time is still after start time (should have added a day)
      expect(
          currentState.selectedEndTime.isAfter(currentState.selectedStartTime),
          true);
    });

    testWidgets('total distance calculation is correct',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // First verify the default value is correctly displayed
      expect(find.text('Total Distance: 500.0 meters'), findsOneWidget);

      // Find the sliders and interact with them to update values
      final poolLengthSlider = find.byType(Slider).first;
      final lapsSlider = find.byType(Slider).at(1);

      // Change pool length to 50m using the slider's onChanged callback
      final Slider poolSlider = tester.widget(poolLengthSlider);
      poolSlider.onChanged!(50.0);
      await tester.pump();

      // Change laps to 30 using the slider's onChanged callback
      final Slider lapSlider = tester.widget(lapsSlider);
      lapSlider.onChanged!(30.0);
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify the intermediate values are displayed properly
      expect(find.text('50.0 meters'), findsOneWidget); // Pool length display
      expect(find.text('30 laps'), findsOneWidget); // Laps display

      // Verify the total distance is updated (30 × 50 = 1500)
      expect(find.text('Total Distance: 1500.0 meters'), findsOneWidget);
    });

    testWidgets('calculateCalories should work correctly with health metrics',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;

      // Set test values - direct modification
      currentState.selectedLaps = 30;
      currentState.customPoolLength = 50.0;
      currentState.selectedStroke = 'Breaststroke';
      final now = DateTime.now();
      currentState.selectedStartTime =
          DateTime(now.year, now.month, now.day, 10, 0);
      currentState.selectedEndTime =
          DateTime(now.year, now.month, now.day, 11, 0);
      await tester.pump();

      // Verify that the form can calculate calories with health metrics
      final calories = swimmingForm.calculateCalories(testHealthMetrics);
      expect(calories, isNotNull);
      expect(calories, greaterThan(0));
    });

    testWidgets('form methods work correctly when called through widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;

      // Set test values
      currentState.selectedLaps = 40;
      currentState.customPoolLength = 25.0;
      final now = DateTime.now();
      currentState.selectedStartTime =
          DateTime(now.year, now.month, now.day, 9, 0);
      currentState.selectedEndTime =
          DateTime(now.year, now.month, now.day, 10, 0);
      await tester.pump();

      // Call calculateCalories through widget
      final calories = swimmingForm.onCalculate(
          currentState.selectedLaps,
          currentState.customPoolLength,
          currentState.selectedStroke,
          currentState.selectedEndTime
              .difference(currentState.selectedStartTime));

      // Verify result is as expected
      // Based on our mock calculation: laps * poolLength * 0.1
      expect(calories, 40 * 25.0 * 0.1);
    });
    testWidgets('dropdown onChanged should update selectedStroke',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Find and tap the dropdown to open it
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select "Backstroke" option
      await tester.tap(find.text('Backstroke').last);
      await tester.pumpAndSettle();

      // Get form state and verify selection
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;

      expect(currentState.selectedStroke, 'Backstroke');
    });
  });
}