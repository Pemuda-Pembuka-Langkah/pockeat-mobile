import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/cycling_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/date_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/time_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/distance_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/personal_data_reminder.dart';

void main() {
  late CyclingForm cyclingForm;
  final Color primaryPink = const Color(0xFFFF6B6B);
  double calculatedCalories = 0.0;
  String lastTypeChanged = '';

  setUp(() {
    cyclingForm = CyclingForm(
      key: GlobalKey<CyclingFormState>(),
      primaryPink: primaryPink,
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
    testWidgets('should render all components correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));

      // Verify all expected components are present
      expect(find.byType(PersonalDataReminder), findsOneWidget);
      expect(find.byType(DateSelectionWidget), findsOneWidget);
      expect(find.byType(TimeSelectionWidget), findsOneWidget);
      expect(find.byType(DistanceSelectionWidget), findsOneWidget);
      
      // Check cycling-specific elements
      expect(find.text('Cycling Activity Type'), findsOneWidget);
      expect(find.text('Mountain'), findsOneWidget);
      expect(find.text('Commute'), findsOneWidget);
      expect(find.text('Stationary'), findsOneWidget);
    });

    testWidgets('should show Mountain as default selected cycling type', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));
      
      // Find the Container for Mountain button to check if it's selected
      final mountainFinder = find.ancestor(
        of: find.text('Mountain'),
        matching: find.byType(Container),
      ).first;
      
      final mountainContainer = tester.widget<Container>(mountainFinder);
      final decoration = mountainContainer.decoration as BoxDecoration;
      
      // Verify Mountain is selected (has colored background)
      expect(decoration.color, isNotNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('tapping Commute option should update the selected type', (WidgetTester tester) async {
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
      final commuteFinder = find.ancestor(
        of: find.text('Commute'),
        matching: find.byType(Container),
      ).first;
      
      final commuteContainer = tester.widget<Container>(commuteFinder);
      final decoration = commuteContainer.decoration as BoxDecoration;
      
      // Verify Commute is selected (has colored background)
      expect(decoration.color, isNotNull);
      expect(decoration.border, isNotNull);
      
      // Verify callback was called
      expect(lastTypeChanged, 'commute');
    });

    testWidgets('tapping Stationary option should update the selected type', (WidgetTester tester) async {
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

    testWidgets('date selection updates state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));
      
      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
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
      await tester.pumpWidget(createTestableWidget(cyclingForm));
      
      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
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

    testWidgets('start time changes should update state and handle time conflicts', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));
      
      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
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
      await tester.pumpWidget(createTestableWidget(cyclingForm));
      
      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
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
      await tester.pumpWidget(createTestableWidget(cyclingForm));
      
      // Get form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;
      
      // Find DistanceSelectionWidget
      final distanceWidget = tester.widget<DistanceSelectionWidget>(find.byType(DistanceSelectionWidget));
      
      // Update km and meter values
      distanceWidget.onKmChanged(10);
      await tester.pump();
      
      distanceWidget.onMeterChanged(500);
      await tester.pump();
      
      // Verify state updated
      expect(currentState.selectedKm, 10);
      expect(currentState.selectedMeter, 500);
    });

    testWidgets('calculateCalories should call onCalculate with correct parameters', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));
      
      // Access form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;
      
      // Set test values - direct modification
      currentState.selectedKm = 10;
      currentState.selectedMeter = 500;
      currentState.selectedCyclingType = CyclingActivityType.mountain;
      currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0);
      currentState.selectedEndTime = DateTime(2023, 1, 1, 11, 0);
      
      // Calculate calories
      final calories = currentState.calculateCalories();
      
      // Verify calculation
      // Distance: 10.5 km, Duration: 60 minutes
      expect(calories, 10.5 * 60 * 0.1);
    });

    testWidgets('getCalories in widget should access state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(cyclingForm));
      
      // Access form state
      final state = cyclingForm.key as GlobalKey<CyclingFormState>;
      final currentState = state.currentState!;
      
      // Set test values - direct modification
      currentState.selectedKm = 15;
      currentState.selectedMeter = 700;
      currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0);
      currentState.selectedEndTime = DateTime(2023, 1, 1, 11, 30);
      
      // Call getCalories on the widget
      final calories = cyclingForm.getCalories();
      
      // Verify it correctly accesses the state's method
      // Distance: 15.7 km, Duration: 90 minutes
      expect(calories, 15.7 * 90 * 0.1);
    });

    // We removed the test for _buildCyclingTypeOption since it's an implementation detail
    // and is already covered by our widget tests that verify the UI rendering
  });
}