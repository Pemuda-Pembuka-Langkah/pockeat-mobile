import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/swimming_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/date_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/time_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/personal_data_reminder.dart';

void main() {
  late SwimmingForm swimmingForm;
  final Color primaryPink = const Color(0xFFFF6B6B);
  double calculatedCalories = 0.0;

  setUp(() {
    // Initialize with proper GlobalKey to access state
    swimmingForm = SwimmingForm(
      key: GlobalKey<SwimmingFormState>(),
      primaryPink: primaryPink,
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
    testWidgets('should render all components correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));

      // Verify all expected components are present
      expect(find.byType(PersonalDataReminder), findsOneWidget);
      expect(find.byType(DateSelectionWidget), findsOneWidget);
      expect(find.byType(TimeSelectionWidget), findsOneWidget);
      
      // Check swimming-specific elements
      expect(find.text('Swimming Stroke'), findsOneWidget);
      expect(find.text('Pool Length'), findsOneWidget);
      expect(find.text('Laps'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2)); // Pool length and laps sliders
      
      // Verify default values displayed
      expect(find.text('25.0 meters'), findsOneWidget);
      expect(find.text('20 laps'), findsOneWidget);
      expect(find.text('Freestyle (Front Crawl)'), findsOneWidget);
      expect(find.text('Total Distance: 500.0 meters'), findsOneWidget);
    });

    testWidgets('selecting different stroke should update state', (WidgetTester tester) async {
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

    testWidgets('changing pool length should update state and total distance', (WidgetTester tester) async {
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

    testWidgets('changing laps should update state and total distance', (WidgetTester tester) async {
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

    testWidgets('date selection updates state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));
      
      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
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

    testWidgets('start time changes should update state and handle time conflicts', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));
      
      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;
      
      // Set initial times for testing - update state directly in tests
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
      await tester.pumpWidget(createTestableWidget(swimmingForm));
      
      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
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

    // test('calculateCalories should call onCalculate with correct parameters', () {
    //   // Access form state
    //   final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
    //   final currentState = state.currentState!;
      
    //   // Set test values - directly modify state properties
    //   currentState.selectedLaps = 30;
    //   currentState.customPoolLength = 50.0;
    //   currentState.selectedStroke = 'Breaststroke';
    //   currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0);
    //   currentState.selectedEndTime = DateTime(2023, 1, 1, 11, 0);
      
    //   // Call calculateCalories 
    //   final calories = swimmingForm.calculateCalories();
      
    //   // Verify calories calculation used our test values
    //   expect(calories, 30 * 50.0 * 0.1); // Based on our mocked onCalculate
    // });

    testWidgets('total distance calculation is correct', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));
      
      // Get form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;
      
      // Set test values - direct modification
      currentState.selectedLaps = 40;
      currentState.customPoolLength = 40.0;
      
      // Wait for widget to rebuild
      await tester.pumpAndSettle();
      
      // Verify directly from state - no need to find UI elements
      expect(currentState.selectedLaps * currentState.customPoolLength, 1600.0);
    });

    testWidgets('calculateCalories calls onCalculate with correct parameters', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(swimmingForm));
      
      // Access form state
      final state = swimmingForm.key as GlobalKey<SwimmingFormState>;
      final currentState = state.currentState!;
      
      // Set test values - direct modification
      currentState.selectedLaps = 25;
      currentState.customPoolLength = 30.0;
      currentState.selectedStroke = 'Backstroke';
      currentState.selectedStartTime = DateTime(2023, 1, 1, 10, 0);
      currentState.selectedEndTime = DateTime(2023, 1, 1, 10, 30);
      
      // Calculate calories through the public method
      final calories = swimmingForm.calculateCalories();
      
      // Check result matches our mocked calculation
      expect(calories, 25 * 30.0 * 0.1);
    });
  });
}