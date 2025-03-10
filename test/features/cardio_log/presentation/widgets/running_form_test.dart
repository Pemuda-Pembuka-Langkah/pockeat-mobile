import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/running_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/date_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/time_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/distance_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/personal_data_reminder.dart';

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
      expect(find.byType(DateSelectionWidget), findsOneWidget);
      expect(find.byType(TimeSelectionWidget), findsOneWidget);
      expect(find.byType(DistanceSelectionWidget), findsOneWidget);
    });

    testWidgets('initial state has correct default values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Check default values
      expect(currentState.selectedKm, 5);
      expect(currentState.selectedMeter, 0);
      expect(currentState.selectedDate.day, DateTime.now().day);
      
      // Default duration should be 30 minutes
      final diff = currentState.selectedEndTime.difference(currentState.selectedStartTime);
      expect(diff.inMinutes, 30);
    });

    testWidgets('date selection updates state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Initial date
      final initialDate = currentState.selectedDate;
      
      // Create a new date (yesterday)
      final newDate = DateTime.now().subtract(const Duration(days: 1));
      
      // Find DateSelectionWidget and call its callback directly
      final dateWidget = tester.widget<DateSelectionWidget>(find.byType(DateSelectionWidget));
      dateWidget.onDateChanged(newDate);
      await tester.pump();
      
      // Verify date was updated in state
      expect(currentState.selectedDate, newDate);
      expect(currentState.selectedDate != initialDate, true);
    });

    testWidgets('changing date updates start and end times correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set initial times for testing
      final initialStartTime = DateTime(2023, 1, 1, 10, 0); // Jan 1, 10:00 AM
      final initialEndTime = DateTime(2023, 1, 1, 11, 0);   // Jan 1, 11:00 AM
      
      // Direct modification of state properties
      currentState.selectedDate = DateTime(2023, 1, 1);
      currentState.selectedStartTime = initialStartTime;
      currentState.selectedEndTime = initialEndTime;
      await tester.pump();
      
      // Change date to Jan 2
      final newDate = DateTime(2023, 1, 2);
      
      // Find DateSelectionWidget and call its callback
      final dateWidget = tester.widget<DateSelectionWidget>(find.byType(DateSelectionWidget));
      dateWidget.onDateChanged(newDate);
      await tester.pump();
      
      // Verify dates updated but times remained the same
      expect(currentState.selectedDate.day, 2);
      expect(currentState.selectedStartTime.hour, 10);
      expect(currentState.selectedStartTime.minute, 0);
      expect(currentState.selectedEndTime.hour, 11);
      expect(currentState.selectedEndTime.minute, 0);
    });

    testWidgets('date change handles midnight crossing correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Access the RunningFormState
      final GlobalKey<RunningFormState> key = runningForm.key as GlobalKey<RunningFormState>;
      final RunningFormState state = key.currentState!;
      
      // Set up a case that crosses midnight - direct modification
      state.selectedDate = DateTime(2023, 1, 1);
      state.selectedStartTime = DateTime(2023, 1, 1, 23, 30); // 11:30 PM
      state.selectedEndTime = DateTime(2023, 1, 2, 0, 30);    // 12:30 AM (next day)
      
      await tester.pump();
      
      // Change the date to Jan 2
      final newDate = DateTime(2023, 1, 2);
      
      // Find DateSelectionWidget and call its callback
      final dateWidget = tester.widget<DateSelectionWidget>(find.byType(DateSelectionWidget));
      dateWidget.onDateChanged(newDate);
      await tester.pump();
      
      // Verify dates updated while preserving the time relationship
      expect(state.selectedDate.day, 2);
      expect(state.selectedStartTime.day, 2);  // Now Jan 2
      expect(state.selectedStartTime.hour, 23);
      expect(state.selectedStartTime.minute, 30);
      expect(state.selectedEndTime.day, 3);    // Now Jan 3 (maintain relationship)
      expect(state.selectedEndTime.hour, 0);
      expect(state.selectedEndTime.minute, 30);
    });

    testWidgets('start time changes should update state and handle time conflicts', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set initial times for testing - direct modification
      currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0); // 10:00 AM
      currentState.selectedEndTime = DateTime(2023, 1, 1, 11, 0);   // 11:00 AM
      await tester.pump();
      
      // Find TimeSelectionWidget
      final timeWidget = tester.widget<TimeSelectionWidget>(find.byType(TimeSelectionWidget));
      
      // Set start time to after end time (12:00 PM)
      final newStartTime = DateTime(2023, 1, 1, 12, 0);
      timeWidget.onStartTimeChanged(newStartTime);
      await tester.pump();
      
      // Verify start time updated and end time adjusted
      expect(currentState.selectedStartTime, newStartTime);
      expect(currentState.selectedEndTime.isAfter(currentState.selectedStartTime), true);
    });

    testWidgets('end time changes should update state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set initial times for testing - direct modification
      currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0); // 10:00 AM
      currentState.selectedEndTime = DateTime(2023, 1, 1, 11, 0);   // 11:00 AM
      await tester.pump();
      
      // Find TimeSelectionWidget
      final timeWidget = tester.widget<TimeSelectionWidget>(find.byType(TimeSelectionWidget));
      
      // Set new end time (1:00 PM)
      final newEndTime = DateTime(2023, 1, 1, 13, 0);
      timeWidget.onEndTimeChanged(newEndTime);
      await tester.pump();
      
      // Verify end time updated
      expect(currentState.selectedEndTime, newEndTime);
    });
    
    testWidgets('distance selection should update state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Get form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Find DistanceSelectionWidget
      final distanceWidget = tester.widget<DistanceSelectionWidget>(find.byType(DistanceSelectionWidget));
      
      // Update km and meter values
      distanceWidget.onKmChanged(8);
      await tester.pump();
      
      distanceWidget.onMeterChanged(300);
      await tester.pump();
      
      // Verify state updated
      expect(currentState.selectedKm, 8);
      expect(currentState.selectedMeter, 300);
    });

    testWidgets('calculateCalories should call onCalculate with correct parameters', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Access form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set test values - direct modification
      currentState.selectedKm = 7;
      currentState.selectedMeter = 500;
      currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0);
      currentState.selectedEndTime = DateTime(2023, 1, 1, 10, 45);
      
      // Calculate calories
      final calories = currentState.calculateCalories();
      
      // Verify calculation
      // Distance: 7.5 km, Duration: 45 minutes
      expect(calories, 7.5 * 45 * 0.1);
    });

    testWidgets('calculateCalories in widget should access state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Access form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set test values - direct modification
      currentState.selectedKm = 4;
      currentState.selectedMeter = 200;
      currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0);
      currentState.selectedEndTime = DateTime(2023, 1, 1, 10, 30);
      
      // Call calculateCalories on the widget
      final calories = runningForm.calculateCalories();
      
      // Verify it correctly accesses the state's method
      // Distance: 4.2 km, Duration: 30 minutes
      expect(calories, 4.2 * 30 * 0.1);
    });

    testWidgets('getCalories should be an alias for calculateCalories', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(runningForm));
      
      // Access form state
      final state = runningForm.key as GlobalKey<RunningFormState>;
      final currentState = state.currentState!;
      
      // Set test values - direct modification
      currentState.selectedKm = 6;
      currentState.selectedMeter = 0;
      currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0);
      currentState.selectedEndTime = DateTime(2023, 1, 1, 11, 0);
      
      // Verify getCalories returns the same as calculateCalories
      expect(runningForm.getCalories(), runningForm.calculateCalories());
    });
  });
}