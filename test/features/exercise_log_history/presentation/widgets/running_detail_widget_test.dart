import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/cardio_log/domain/models/running_activity.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/running_detail_widget.dart';

void main() {
  final testActivity = RunningActivity(
    id: 'run-1',
    date: DateTime(2025, 3, 1),
    startTime: DateTime(2025, 3, 1, 8, 0),
    endTime: DateTime(2025, 3, 1, 8, 30),
    distanceKm: 5.0,
    caloriesBurned: 350,
  );

  group('RunningDetailWidget Tests', () {
    testWidgets('should display running session title', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RunningDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check title is displayed
      expect(find.text('Running Session'), findsOneWidget);
    });

    testWidgets('should display formatted date', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RunningDetailWidget(activity: testActivity),
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
          body: RunningDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check metric values
      expect(find.text('5.0 km'), findsAtLeastNWidgets(1));
      
      // For duration, use the formatted value method to match what's in the widget
      final expectedDuration = _formatDuration(testActivity.duration);
      expect(find.text(expectedDuration), findsAtLeastNWidgets(1));
      
      expect(find.text('350 kcal'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display running icon', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RunningDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check icon
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
    });

    testWidgets('should display activity details section with time', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RunningDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check section title and time
      expect(find.text('Activity Details'), findsOneWidget);
      
      // Check for Date row
      expect(find.text('Date'), findsOneWidget);
      expect(find.text(DateFormat('dd MMM yyyy').format(testActivity.date)), findsOneWidget);
      
      // Check for Time row (matches implementation)
      expect(find.text('Time'), findsOneWidget);
      expect(find.text(DateFormat('HH:mm').format(testActivity.startTime)), findsOneWidget);
    });
    
    testWidgets('should display pace information', (WidgetTester tester) async {
      // Arrange - Build the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RunningDetailWidget(activity: testActivity),
        ),
      ));

      // Assert - Check pace is displayed
      expect(find.text('Pace'), findsOneWidget);
    });
  });
}

// Helper method to match the formatting in the widget
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
}
