// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/presentation/widgets/cycling_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/distance_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/personal_data_reminder.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/time_selection_widget.dart';
import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';

void main() {
  late CyclingForm cyclingForm;
  final Color primaryPink = const Color(0xFFFF6B6B);
  double calculatedCalories = 0.0;
  String lastTypeChanged = '';
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

    cyclingForm = CyclingForm(
      key: GlobalKey<CyclingFormState>(),
      primaryPink: primaryPink,
      healthMetrics: testHealthMetrics,
      onCalculate: (distance, duration, type) {
        calculatedCalories = distance * duration.inMinutes * 0.1;
        return calculatedCalories;
      },
      onTypeChanged: (type) {
        lastTypeChanged = type;
      },
    );
  });

  Widget createTestableWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(body: widget),
    );
  }

  group('CyclingForm Widget Tests', () {
    testWidgets(
        'should add a day to end time when end time is before start time',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;

      // Set initial times where end time is before start time
      final now = DateTime.now();
      // Set start time to 11:00 PM
      currentState.selectedStartTime =
          DateTime(now.year, now.month, now.day, 23, 0);
      // Set end time to 1:00 AM (which would be before start time)
      currentState.selectedEndTime =
          DateTime(now.year, now.month, now.day, 1, 0);

      // Find TimeSelectionWidget
      final timeWidget =
          tester.widget<TimeSelectionWidget>(find.byType(TimeSelectionWidget));

      // Trigger the onEndTimeChanged to execute the code path
      timeWidget.onEndTimeChanged(currentState.selectedEndTime);
      await tester.pump();

      // Verify the end time has a day added to it
      expect(currentState.selectedEndTime.day,
          currentState.selectedStartTime.add(const Duration(days: 1)).day);
      expect(currentState.selectedEndTime.hour, 1);
      expect(currentState.selectedEndTime.minute, 0);
    });

    testWidgets('should render all components correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Verify all expected components are present
      expect(find.byType(PersonalDataReminder), findsOneWidget);
      expect(find.byType(TimeSelectionWidget), findsOneWidget);
      expect(find.byType(DistanceSelectionWidget), findsOneWidget);

      // Check cycling-specific elements
      expect(find.text('Cycling Activity Type'), findsOneWidget);
      expect(find.text('Mountain'), findsOneWidget);
      expect(find.text('Commute'), findsOneWidget);
      expect(find.text('Stationary'), findsOneWidget);

      // Verify text elements are present
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
    });

    testWidgets('should show Mountain as default selected cycling type',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Find the Container for Mountain button to check if it's selected
      final mountainFinder = find
          .ancestor(
            of: find.text('Mountain'),
            matching: find.byType(Container),
          )
          .first;

      final mountainContainer = tester.widget<Container>(mountainFinder);
      final decoration = mountainContainer.decoration as BoxDecoration;

      // Verify Mountain is selected (has colored background)
      expect(decoration.color, isNotNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('tapping Commute option should update the selected type',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Tap on Commute
      await tester.tap(find.text('Commute'));
      await tester.pump();

      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;

      // Verify state updated
      expect(currentState.selectedCyclingType, CyclingActivityType.commute);

      // Verify UI updated - Commute should now be selected
      final commuteFinder = find
          .ancestor(
            of: find.text('Commute'),
            matching: find.byType(Container),
          )
          .first;

      final commuteContainer = tester.widget<Container>(commuteFinder);
      final decoration = commuteContainer.decoration as BoxDecoration;

      // Verify Commute is selected (has colored background)
      expect(decoration.color, isNotNull);
      expect(decoration.border, isNotNull);

      // Verify callback was called
      expect(lastTypeChanged, 'commute');
    });

    testWidgets('tapping Stationary option should update the selected type',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Tap on Stationary
      await tester.tap(find.text('Stationary'));
      await tester.pump();

      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;

      // Verify state updated
      expect(currentState.selectedCyclingType, CyclingActivityType.stationary);

      // Verify callback was called
      expect(lastTypeChanged, 'stationary');
    });

    testWidgets(
        'start time changes should update state and handle time conflicts',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
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
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
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

      // Verify end time was set correctly and should be after start time
      expect(
          currentState.selectedEndTime.isAfter(currentState.selectedStartTime),
          true);
    });

    testWidgets('distance selection should update state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;

      // Find DistanceSelectionWidget
      final distanceWidget = tester.widget<DistanceSelectionWidget>(
          find.byType(DistanceSelectionWidget));

      // Update km and meter values
      distanceWidget.onKmChanged(8);
      await tester.pump();

      distanceWidget.onMeterChanged(300);
      await tester.pump();

      // Verify state updated
      expect(currentState.selectedKm, 8);
      expect(currentState.selectedMeter, 300);
    });

    testWidgets('calculateCalories should work correctly with health metrics',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;

      // Set test values
      currentState.selectedKm = 7;
      currentState.selectedMeter = 500;
      final now = DateTime.now();
      currentState.selectedStartTime =
          DateTime(now.year, now.month, now.day, 10, 0);
      currentState.selectedEndTime =
          DateTime(now.year, now.month, now.day, 10, 45);

      // Update cycling type through onTypeChanged callback to ensure lastTypeChanged is updated
      lastTypeChanged = ''; // Reset the variable first
      cyclingForm.onTypeChanged?.call('commute');
      currentState.selectedCyclingType = CyclingActivityType.commute;

      await tester.pump();

      // Verify that the form can calculate calories with health metrics
      final calories = cyclingForm.calculateCalories(testHealthMetrics);
      expect(calories, isNotNull);
      expect(calories, greaterThan(0));
    });

    testWidgets('form methods work correctly when called through widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;

      // Set values for testing
      currentState.selectedKm = 10;
      currentState.selectedMeter = 0;
      final now = DateTime.now();
      currentState.selectedStartTime =
          DateTime(now.year, now.month, now.day, 9, 0);
      currentState.selectedEndTime =
          DateTime(now.year, now.month, now.day, 11, 0);
      await tester.pump();

      // Calculate parameters manually
      final totalDistance =
          currentState.selectedKm + (currentState.selectedMeter / 1000); // 10.0
      final duration = currentState.selectedEndTime
          .difference(currentState.selectedStartTime); // 120 minutes
      final cyclingType =
          currentState.selectedCyclingType.toString().split('.').last;

      // Call calculation directly
      final calories =
          cyclingForm.onCalculate(totalDistance, duration, cyclingType);

      // Expected value based on our mock calculation function: distance * duration * 0.1
      // Distance = 10 km, Duration = 120 minutes
      // Expected = 10 * 120 * 0.1 = 120.0
      expect(calories, 120.0);
    });
  });
}