import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/cardio_log/domain/models/cycling_activity.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/cycling_detail_widget.dart';

void main() {
  final testActivity = CyclingActivity(
    id: 'cycle-1',
    date: DateTime(2025, 3, 2),
    startTime: DateTime(2025, 3, 2, 10, 0),
    endTime: DateTime(2025, 3, 2, 11, 0),
    distanceKm: 20.0,
    cyclingType: CyclingType.commute,
    caloriesBurned: 450,
  );

  group('CyclingDetailWidget Tests', () {
    testWidgets('should display cycling session title', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CyclingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check title is displayed
      expect(find.text('Cycling Session'), findsOneWidget);
    });

    testWidgets('should display formatted date', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CyclingDetailWidget(activity: testActivity),
        ),
      ));

      // Expected formatted date
      final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(testActivity.date);

      // Assert - Check date is displayed
      expect(find.text(formattedDate), findsOneWidget);
    });

    testWidgets('should display distance, duration and calories values', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CyclingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check metric values
      expect(find.text('20.0 km'), findsAtLeastNWidgets(1));
      
      // For duration, use the formatted value method to match exactly what's in the widget
      // Updated to include the "min" suffix that was added in the new design
      final hours = testActivity.duration.inHours.toString().padLeft(2, '0');
      final minutes = testActivity.duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = testActivity.duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      final expectedDuration = hours == '00' ? '$minutes:$seconds min' : '$hours:$minutes:$seconds';
      expect(find.text(expectedDuration), findsAtLeastNWidgets(1));
      
      // Check for numeric calories in metrics card
      expect(find.text('450'), findsAtLeastNWidgets(1));
      
      // And with unit in details section
      expect(find.text('450 kcal'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display cycling icon', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CyclingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check icon
      expect(find.byIcon(Icons.directions_bike), findsOneWidget);
    });

    testWidgets('should display cycling type in details section', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CyclingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check cycling type displayed
      expect(find.text('Cycling Type'), findsOneWidget);
      expect(find.text('Commute/Road Cycling'), findsOneWidget); 
    });

    testWidgets('should display start and end times in details section', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CyclingDetailWidget(activity: testActivity),
        ),
      ));

      // Expected formatted times
      final expectedStartTime = DateFormat('HH:mm').format(testActivity.startTime);
      final expectedEndTime = DateFormat('HH:mm').format(testActivity.endTime);

      // Assert - Check times displayed
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text(expectedStartTime), findsOneWidget);
      
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text(expectedEndTime), findsOneWidget);
    });
    
    testWidgets('should display activity details section with average speed', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CyclingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check section title
      expect(find.text('Activity Details'), findsOneWidget);
      
      // Check for average speed label in the metrics card
      expect(find.text('Avg Speed'), findsOneWidget);
      
      // Check for average speed label in the details section
      expect(find.text('Average Speed'), findsOneWidget);
      
      // Calculate expected speed value exactly as shown in the widget
      final speed = testActivity.distanceKm / (testActivity.duration.inSeconds / 3600);
      final expectedSpeed = '${speed.toStringAsFixed(1)} km/h';
      
      // We expect to find the speed value in at least one place (actually appears in both the metrics card and details section)
      expect(find.text(expectedSpeed), findsAtLeastNWidgets(1));
    });
  });
}
