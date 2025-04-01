import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/cardio_log/domain/models/swimming_activity.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/swimming_detail_widget.dart';

void main() {
  final testActivity = SwimmingActivity(
    id: 'swim-1',
    userId: "test-user-id",
    date: DateTime(2025, 3, 3),
    startTime: DateTime(2025, 3, 3, 16, 0),
    endTime: DateTime(2025, 3, 3, 16, 45),
    laps: 20,
    poolLength: 50.0,
    stroke: 'freestyle',
    caloriesBurned: 500,
  );

  group('SwimmingDetailWidget Tests', () {
    testWidgets('should display swimming session title', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SwimmingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check title is displayed
      expect(find.text('Swimming Session'), findsOneWidget);
    });

    testWidgets('should display formatted date', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SwimmingDetailWidget(activity: testActivity),
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
          body: SwimmingDetailWidget(activity: testActivity),
        ),
      ));
      
      // Calculate the total distance as defined in the widget (laps * poolLength)
      final totalDistance = '${(testActivity.laps * testActivity.poolLength).toInt()} m';
      
      // Assert - Check metric values
      expect(find.text(totalDistance), findsAtLeastNWidgets(1));
      
      // For duration, use the formatted value method to match exactly what's in the widget
      // Now includes the " min" suffix that was added in the new design
      final minutes = testActivity.duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = testActivity.duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      final expectedDuration = '$minutes:$seconds min';
      expect(find.text(expectedDuration), findsAtLeastNWidgets(1));
      
      // Test for calories value in the metrics card
      expect(find.text('500'), findsAtLeastNWidgets(1));
      
      // In the details section it shows with kcal unit
      expect(find.text('500 kcal'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display swimming icon', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SwimmingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check icon
      expect(find.byIcon(Icons.pool), findsOneWidget);
    });

    testWidgets('should display swimming specific metrics in details section', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SwimmingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check Activity Details section
      expect(find.text('Activity Details'), findsOneWidget);
      
      // Check swimming metrics
      expect(find.text('Laps'), findsOneWidget);
      expect(find.text(testActivity.laps.toString()), findsOneWidget);
      
      expect(find.text('Pool Length'), findsOneWidget);
      expect(find.text('${testActivity.poolLength} m'), findsOneWidget);
    });

    testWidgets('should display stroke style in details section', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SwimmingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check stroke style is displayed with first letter capitalized
      expect(find.text('Stroke Style'), findsOneWidget);
      expect(find.text('Freestyle'), findsOneWidget); // First letter capitalized as per _getStrokeStyle
    });
    
    testWidgets('should display start and end times in details section', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SwimmingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check time information
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text(DateFormat('HH:mm').format(testActivity.startTime)), findsOneWidget);
      
      expect(find.text('End Time'), findsOneWidget);
      expect(find.text(DateFormat('HH:mm').format(testActivity.endTime)), findsOneWidget);
    });
    
    testWidgets('should display pace calculation', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SwimmingDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check pace label is displayed
      expect(find.text('Pace (100m)'), findsAtLeastNWidgets(1));
      
      // Calculate the expected pace value exactly as in the widget
      final totalDistance = testActivity.laps * testActivity.poolLength;
      final durationInSeconds = testActivity.duration.inSeconds;
      final pace100m = totalDistance > 0 ? (durationInSeconds / (totalDistance / 100)) : 0;
      final paceMinutes = (pace100m / 60).floor();
      final paceSeconds = (pace100m % 60).round();
      final expectedPace = '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}';
      
      // Find the pace text
      expect(find.text(expectedPace), findsAtLeastNWidgets(1));
    });
  });
}
