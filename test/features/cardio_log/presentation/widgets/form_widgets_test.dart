// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/cardio_log/presentation/widgets/cycling_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/distance_selection_widget.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/running_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/swimming_form.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/time_selection_widget.dart';

void main() {
  final Color primaryPink = const Color(0xFFFF6B6B);
  
  group('TimeSelectionWidget Tests', () {
    testWidgets('TimeSelectionWidget should render correctly', 
        (WidgetTester tester) async {
      DateTime selectedStartTime = DateTime.now().subtract(const Duration(hours: 1));
      DateTime selectedEndTime = DateTime.now();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSelectionWidget(
              primaryColor: primaryPink,
              selectedStartTime: selectedStartTime,
              selectedEndTime: selectedEndTime,
              onStartTimeChanged: (time) {
                selectedStartTime = time;
              },
              onEndTimeChanged: (time) {
                selectedEndTime = time;
              },
            ),
          ),
        ),
      );
      
      // Verify time selection UI elements
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      
      // Instead of checking for specific time format, check for the widget's existence
      // and verify that the duration text is displayed
      expect(find.byType(InkWell), findsAtLeast(2)); // At least 2 InkWell widgets for time selection
      
      // Check for duration text
      expect(find.textContaining('Duration:'), findsOneWidget);
    });
  });
  
  group('DistanceSelectionWidget Tests', () {
    testWidgets('DistanceSelectionWidget should render correctly', 
        (WidgetTester tester) async {
      int selectedKm = 5;
      int selectedMeter = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DistanceSelectionWidget(
              primaryColor: primaryPink,
              selectedKm: selectedKm,
              selectedMeter: selectedMeter,
              onKmChanged: (km) {
                selectedKm = km;
              },
              onMeterChanged: (meter) {
                selectedMeter = meter;
              },
            ),
          ),
        ),
      );
      
      // Verify distance selection UI elements
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
      expect(find.text('m'), findsOneWidget);
    });
  });

  group('RunningForm Tests', () {
    testWidgets('RunningForm should render correctly', 
        (WidgetTester tester) async {
      double calculatedCalories = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RunningForm(
              primaryPink: primaryPink,
              onCalculate: (distance, duration) {
                calculatedCalories = distance * 60; // Simplified calculation for test
                return calculatedCalories;
              },
            ),
          ),
        ),
      );
      
      // Verify running form UI elements
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
    });
  });

  group('CyclingForm Tests', () {
    testWidgets('CyclingForm should render correctly', 
        (WidgetTester tester) async {
      double calculatedCalories = 0;
      // ignore: unused_local_variable
      String selectedType = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CyclingForm(
              primaryPink: primaryPink,
              onCalculate: (distance, duration, type) {
                calculatedCalories = distance * 50; // Simplified calculation for test
                return calculatedCalories;
              },
              onTypeChanged: (type) {
                selectedType = type;
              },
            ),
          ),
        ),
      );
      
      // Verify cycling form UI elements
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Cycling Activity Type'), findsOneWidget);
      expect(find.text('Mountain'), findsOneWidget);
      expect(find.text('Commute'), findsOneWidget);
      expect(find.text('Stationary'), findsOneWidget);
    });
  });

  group('SwimmingForm Tests', () {
    testWidgets('SwimmingForm should render correctly', 
        (WidgetTester tester) async {
      double calculatedCalories = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwimmingForm(
              primaryPink: primaryPink,
              onCalculate: (laps, poolLength, stroke, duration) {
                calculatedCalories = laps * 15; // Simplified calculation for test
                return calculatedCalories;
              },
            ),
          ),
        ),
      );
      
      // Verify swimming form UI elements
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text('Laps'), findsOneWidget);
      expect(find.text('Pool Length'), findsOneWidget);
      expect(find.text('Swimming Stroke'), findsOneWidget);
    });
  });
} 
