// exercise_option_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Positive test cases
  group('ExerciseOptionCard positive tests', () {
    testWidgets('displays all elements correctly', (WidgetTester tester) async {
      // Test data
      const iconData = Icons.directions_run;
      const title = 'Running';
      const subtitle = 'Track your running session';
      const color = Color(0xFFFF6B6B); // Pink color
      const route = '/running-input';
      
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseOptionCard(
              icon: iconData,
              title: title,
              subtitle: subtitle,
              color: color,
              route: route,
            ),
          ),
        ),
      );
      
      // Verify icon is displayed
      expect(find.byIcon(iconData), findsOneWidget);
      
      // Verify text is displayed
      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
      
      // Verify arrow icon is displayed
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });
    
    testWidgets('has correct styling', (WidgetTester tester) async {
      // Test data
      const iconData = Icons.directions_run;
      const title = 'Running';
      const subtitle = 'Track your running session';
      const color = Color(0xFFFF6B6B); // Pink color
      const route = '/running-input';
      
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseOptionCard(
              icon: iconData,
              title: title,
              subtitle: subtitle,
              color: color,
              route: route,
            ),
          ),
        ),
      );
      
      // Verify the card has the correct height
      final sizedBoxFinder = find.byType(SizedBox).first;
      final SizedBox sizedBox = tester.widget(sizedBoxFinder);
      expect(sizedBox.height, equals(100));
      
      // Verify the icon container has the correct color
      final containerFinder = find.ancestor(
        of: find.byIcon(iconData),
        matching: find.byType(Container),
      );
      final Container container = tester.widget(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(color));
      
      // Verify the icon container has the correct size
      expect(container.constraints?.maxWidth, equals(48));
      expect(container.constraints?.maxHeight, equals(48));
      
      // Verify the forward icon has the correct color
      final forwardIconFinder = find.byIcon(Icons.arrow_forward_ios);
      final Icon forwardIcon = tester.widget(forwardIconFinder);
      expect(forwardIcon.color, equals(color));
    });
    
    testWidgets('navigates to correct route when tapped', (WidgetTester tester) async {
      // Test data
      const iconData = Icons.directions_run;
      const title = 'Running';
      const subtitle = 'Track your running session';
      const color = Color(0xFFFF6B6B); // Pink color
      const route = '/running-input';
      
      // Setup navigation tracker
      bool navigated = false;
      String? navigatedRoute;
      
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseOptionCard(
              icon: iconData,
              title: title,
              subtitle: subtitle,
              color: color,
              route: route,
            ),
          ),
          onGenerateRoute: (settings) {
            navigated = true;
            navigatedRoute = settings.name;
            return MaterialPageRoute(
              builder: (context) => const Scaffold(),
              settings: settings,
            );
          },
        ),
      );
      
      // Tap the card
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      
      // Verify navigation occurred with correct route
      expect(navigated, isTrue);
      expect(navigatedRoute, equals(route));
    });
  });
  
  // Negative test cases
  group('ExerciseOptionCard negative tests', () {
    testWidgets('handles very long text without crashing', (WidgetTester tester) async {
      // Test with extremely long title and subtitle
      const String longTitle = 'This is an extremely long title that would probably cause overflow in most UI components if not handled properly';
      const String longSubtitle = 'This is an extremely long subtitle that would also likely cause overflow issues if the widget does not implement proper text overflow handling';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseOptionCard(
              icon: Icons.directions_run,
              title: longTitle,
              subtitle: longSubtitle,
              color: const Color(0xFFFF6B6B),
              route: '/test',
            ),
          ),
        ),
      );
      
      // The test passes if the widget builds without throwing an exception
      expect(find.byType(ExerciseOptionCard), findsOneWidget);
      
      // Verify texts are displayed (likely truncated/ellipsized)
      expect(find.textContaining('This is an extremely'), findsWidgets);
    });
    
    testWidgets('handles empty strings for title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseOptionCard(
              icon: Icons.directions_run,
              title: '',
              subtitle: '',
              color: const Color(0xFFFF6B6B),
              route: '/test',
            ),
          ),
        ),
      );
      
      // Widget should still render without crashing
      expect(find.byType(ExerciseOptionCard), findsOneWidget);
      
      // Empty strings should be displayed as empty
      expect(find.text(''), findsWidgets);
    });
    
    testWidgets('handles transparent color without visual issues', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseOptionCard(
              icon: Icons.directions_run,
              title: 'Running',
              subtitle: 'Track your running session',
              color: Colors.transparent,
              route: '/test',
            ),
          ),
        ),
      );
      
      // Widget should still render without crashing
      expect(find.byType(ExerciseOptionCard), findsOneWidget);
      
      // Icon should still be displayed even with transparent color
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
    });
    
    testWidgets('handles empty route without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseOptionCard(
              icon: Icons.directions_run,
              title: 'Running',
              subtitle: 'Track your running session',
              color: const Color(0xFFFF6B6B),
              route: '',
            ),
          ),
        ),
      );
      
      // Widget should still render
      expect(find.byType(ExerciseOptionCard), findsOneWidget);
      
      // Test that tapping still works without crashing
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      
      // Test passes if no exception is thrown
    });
  });
}