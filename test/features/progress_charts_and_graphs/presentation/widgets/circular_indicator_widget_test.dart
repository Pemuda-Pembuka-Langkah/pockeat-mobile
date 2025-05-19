// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/circular_indicator_widget.dart';

void main() {
  group('CircularIndicatorWidget', () {
    testWidgets('renders correctly with all required props', (WidgetTester tester) async {
      // Define test data
      const String testLabel = 'Steps';
      const String testValue = '8,432';
      const IconData testIcon = Icons.directions_walk;
      const Color testColor = Colors.blue;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: testLabel,
                value: testValue,
                icon: testIcon,
                color: testColor,
              ),
            ),
          ),
        ),
      );

      // Verify widget structure
      expect(find.byType(CircularIndicatorWidget), findsOneWidget);
      
      // Cari semua Container dalam widget
      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      expect(containers.length, greaterThanOrEqualTo(2)); // Minimal ada 2 container
      
      expect(find.byType(Column), findsOneWidget);
      
      // Find any Stack rather than expecting exactly one
      expect(find.byType(Stack), findsWidgets); // Ubah ke findsWidgets karena ada beberapa Stack
      
      expect(find.text(testLabel), findsOneWidget);
      expect(find.text(testValue), findsOneWidget);
      
      // Verify icon is rendered with correct properties
      final iconFinder = find.byIcon(testIcon);
      expect(iconFinder, findsOneWidget);
      final Icon iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, testColor);
      expect(iconWidget.size, 32);
      
      // Verify circle container's background color
      // Gunakan byWidgetPredicate untuk mencari AnimatedContainer spesifik dengan shape: BoxShape.circle
      final circleContainerFinder = find.byWidgetPredicate((widget) {
        if (widget is AnimatedContainer) {
          final decoration = widget.decoration;
          return decoration is BoxDecoration && decoration.shape == BoxShape.circle;
        }
        return false;
      });
      
      expect(circleContainerFinder, findsOneWidget);
      final circleContainer = tester.widget<AnimatedContainer>(circleContainerFinder);
      
      final BoxDecoration decoration = circleContainer.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect((decoration.color as Color).alpha, (testColor.withOpacity(0.1)).alpha);
      expect((decoration.color as Color).red, (testColor.withOpacity(0.1)).red);
      expect((decoration.color as Color).green, (testColor.withOpacity(0.1)).green);
      expect((decoration.color as Color).blue, (testColor.withOpacity(0.1)).blue);
      
      // Verify text styles
      final labelText = tester.widget<Text>(find.text(testLabel));
      expect(labelText.style!.fontSize, 14);
      expect(labelText.style!.color, Colors.grey);
      expect(labelText.style!.fontWeight, FontWeight.w500);
      
      final valueText = tester.widget<Text>(find.text(testValue));
      expect(valueText.style!.fontSize, 18);
      expect(valueText.style!.fontWeight, FontWeight.bold);
      expect(valueText.style!.color, Colors.black87);
    });

    testWidgets('properly handles onTap callback', (WidgetTester tester) async {
      bool callbackCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Tap Me',
                value: 'Value',
                icon: Icons.touch_app,
                color: Colors.orange,
                onTap: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Initially the callback hasn't been called
      expect(callbackCalled, false);
      
      // Tap on the widget
      await tester.tap(find.byType(CircularIndicatorWidget));
      await tester.pump();
      
      // Verify callback was called
      expect(callbackCalled, true);
    });
    
    testWidgets('does nothing when tapped with null onTap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'No Action',
                value: 'Value',
                icon: Icons.not_interested,
                color: Colors.grey,
                onTap: null,
              ),
            ),
          ),
        ),
      );

      // Should not throw when tapped
      await tester.tap(find.byType(CircularIndicatorWidget));
      await tester.pump();
    });

    testWidgets('has proper shadow and decoration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Distance',
                value: '5.4 km',
                icon: Icons.directions_run,
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );

      // Find the main container
      final outerContainer = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.byType(Column),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      
      // Check its decoration
      final BoxDecoration decoration = outerContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.color, Colors.white);
      expect(decoration.boxShadow!.length, 1);
      
      // Gunakan aproximation untuk color test yang lebih robust
      final actualShadowOpacity = decoration.boxShadow![0].color.opacity;
      expect(actualShadowOpacity, closeTo(0.05, 0.001));
      
      expect(decoration.boxShadow![0].blurRadius, 10);
      expect(decoration.boxShadow![0].offset, const Offset(0, 4));
    });

    testWidgets('has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Test',
                value: 'Value',
                icon: Icons.check,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Find the main container
      final container = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.byType(Column),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      
      // Check padding
      expect(container.padding, const EdgeInsets.symmetric(vertical: 16, horizontal: 8));
    });

    testWidgets('has proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Test',
                value: 'Value',
                icon: Icons.check,
                color: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Find SizedBox heights - pastikan urutan yang benar
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      
      // Verifikasi jumlah SizedBox yang ada (penting untuk debug)
      expect(sizedBoxes.length, greaterThanOrEqualTo(2), reason: "Should have at least 2 SizedBoxes");
      
      // Sesuaikan dengan nilai aktual di implementasi widget
      // Periksa urutan SizedBox untuk memastikan kita mendapatkan yang tepat
      expect(sizedBoxes.where((sb) => sb.height == 16.0).isNotEmpty, isTrue, 
        reason: "At least one SizedBox should have height 16.0");
      expect(sizedBoxes.where((sb) => sb.height == 8.0).isNotEmpty, isTrue,
        reason: "At least one SizedBox should have height 8.0");
    });
    
    testWidgets('shows edit icon for interactive widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Test',
                value: 'Value',
                icon: Icons.check,
                color: Colors.green,
                onTap: () {}, // Make it interactive
              ),
            ),
          ),
        ),
      );

      // Verify small edit icon is present (in corner of main icon)
      final editIcons = find.byIcon(Icons.edit);
      expect(editIcons, findsWidgets); // Should find at least one edit icon
      
      // Verify that at least one edit icon has white color and size 10
      bool foundSmallEditIcon = false;
      for (final iconWidget in tester.widgetList<Icon>(find.byIcon(Icons.edit))) {
        if (iconWidget.color == Colors.white && iconWidget.size == 10) {
          foundSmallEditIcon = true;
          break;
        }
      }
      expect(foundSmallEditIcon, isTrue, reason: "Should find small edit icon with white color and size 10");
    });
    
    testWidgets('does not show edit icon for non-interactive widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularIndicatorWidget(
                label: 'Test',
                value: 'Value',
                icon: Icons.check,
                color: Colors.green,
                onTap: null, // Non-interactive
              ),
            ),
          ),
        ),
      );
      
      // Check for Container with edit icon
      final smallEditIconContainer = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final child = widget.child;
          return child is Icon && 
                 (child as Icon).icon == Icons.edit &&
                 (child as Icon).size == 10;
        }
        return false;
      });
      
      expect(smallEditIconContainer, findsNothing);
    });
  });
}