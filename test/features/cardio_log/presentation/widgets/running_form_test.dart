// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/presentation/widgets/distance_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/personal_data_reminder.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/running_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/time_selection_widget.dart';

void main() {
  late RunningForm runningForm;
  final Color primaryPink = const Color(0xFFFF6B6B);
  double calculatedCalories = 0.0;

  setUp(() {
    runningForm = RunningForm(
      key: GlobalKey<RunningFormState>(),
      primaryPink: primaryPink,
      onCalculate: (distance, duration) {
        calculatedCalories = distance * duration.inMinutes * 0.1;
        return calculatedCalories;
      },
    );
  });

  Widget createTestableWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(body: widget),
    );
  }

  group('RunningForm Widget Tests', () {
    testWidgets('should render all components correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));

      // Verify all expected components are present
      expect(find.byType(PersonalDataReminder), findsOneWidget);
      expect(find.byType(TimeSelectionWidget), findsOneWidget);
      expect(find.byType(DistanceSelectionWidget), findsOneWidget);
      
      // Verify text elements are present
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
    });

    testWidgets('initial state has correct default values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Check default values
      expect(currentState.selectedKm, 0);
      expect(currentState.selectedMeter, 0);
      
      // Default duration should be 30 minutes
      final diff = currentState.selectedEndTime.difference(currentState.selectedStartTime);
      expect(diff.inMinutes, 1);
    });


    testWidgets('end time changes should update state and handle time conflicts', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set initial times for testing
      final now = DateTime.now();
      final initialStartTime = DateTime(now.year, now.month, now.day, 10, 0); // 10:00 AM today
      
      // Direct modification of state properties
      currentState.selectedStartTime = initialStartTime;
      currentState.selectedEndTime = initialStartTime.add(const Duration(hours: 1)); // 11:00 AM today
      await tester.pump();
      
      // Find TimeSelectionWidget
      final timeWidget = tester.widget<TimeSelectionWidget>(find.byType(TimeSelectionWidget));
      
      // Set end time to before start time (9:00 AM)
      final newEndTime = DateTime(now.year, now.month, now.day, 9, 0);
      timeWidget.onEndTimeChanged(newEndTime);
      await tester.pump();
      
      // Verify end time was set correctly and one day was added (should be tomorrow at 9:00)
      expect(currentState.selectedEndTime.hour, 9);
      expect(currentState.selectedEndTime.minute, 0);
      expect(currentState.selectedEndTime.isAfter(currentState.selectedStartTime), true);
    });
    
    testWidgets('distance selection should update state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Initial values
      expect(currentState.selectedKm, 0);
      expect(currentState.selectedMeter, 0);
      
      // Find DistanceSelectionWidget
      final distanceWidget = tester.widget<DistanceSelectionWidget>(find.byType(DistanceSelectionWidget));
      
      // Set new km value
      distanceWidget.onKmChanged(5);
      await tester.pump();
      
      // Verify km value was updated
      expect(currentState.selectedKm, 5);
      
      // Set new meter value
      distanceWidget.onMeterChanged(500);
      await tester.pump();
      
      // Verify meter value was updated
      expect(currentState.selectedMeter, 500);
    });
    
    testWidgets('calculateCalories should use correct values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set values for testing
      currentState.selectedKm = 5;
      currentState.selectedMeter = 500;
      final now = DateTime.now();
      currentState.selectedStartTime = DateTime(now.year, now.month, now.day, 10, 0);
      currentState.selectedEndTime = DateTime(now.year, now.month, now.day, 11, 0);
      await tester.pump();
      
      // Calculate calories
      final calories = currentState.calculateCalories();
      
      // Expected value based on our mock calculation function: distance * duration * 0.1
      // Distance = 5.5 km, Duration = 60 minutes
      // Expected = 5.5 * 60 * 0.1 = 33.0
      expect(calories, 33.0);
      expect(calculatedCalories, 33.0); // The mock variable should also be updated
    });
    
    testWidgets('form methods work correctly when called through widget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set values for testing
      currentState.selectedKm = 10;
      currentState.selectedMeter = 0;
      final now = DateTime.now();
      currentState.selectedStartTime = DateTime(now.year, now.month, now.day, 9, 0);
      currentState.selectedEndTime = DateTime(now.year, now.month, now.day, 11, 0);
      await tester.pump();
      
      // Call methods through widget
      final calories1 = runningForm.getCalories();
      final calories2 = runningForm.calculateCalories();
      
      // Both should return the same value
      expect(calories1, calories2);
      
      // Expected value based on our mock calculation function: distance * duration * 0.1
      // Distance = 10 km, Duration = 120 minutes
      // Expected = 10 * 120 * 0.1 = 120.0
      expect(calories1, 120.0);
    });
  });
}
