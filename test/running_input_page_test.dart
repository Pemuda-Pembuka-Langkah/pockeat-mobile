import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/running_input_page.dart';

void main() {
  group('RunningInputPage Widget Tests', () {
    testWidgets('should display initial cardio type as Running', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: RunningInputPage()));

      // Assert
      expect(find.text('Running'), findsWidgets);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
    });

    testWidgets('should switch to Walking mode when walking button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: RunningInputPage()));

      // Act
      await tester.tap(find.text('Walking'));
      await tester.pump();

      // Assert
      expect(find.text('Walking Details'), findsOneWidget);
      expect(find.text('Steps Count'), findsOneWidget);
    });

    testWidgets('should update distance when slider is moved', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: RunningInputPage()));

      // Act
      await tester.drag(find.byType(Slider).first, const Offset(100, 0));
      await tester.pump();

      // Assert
      expect(find.textContaining('km'), findsWidgets);
    });
  });
} 