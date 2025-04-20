import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/log_history/presentation/widgets/log_history_tab_widget.dart';

void main() {
  late AppColors mockColors;

  setUp(() {
    mockColors = AppColors(
      primaryYellow: const Color(0xFFFFE893),
      primaryPink: const Color(0xFFFF6B6B),
      primaryGreen: const Color(0xFF4ECDC4),
    );
  });

  group('LogHistoryTabWidget', () {
    testWidgets('renders correctly when selected', (WidgetTester tester) async {
      bool tapCalled = false;
      
      // Build the widget in selected state inside a Row to properly handle Expanded
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              LogHistoryTabWidget(
                label: 'Food',
                index: 0,
                isSelected: true,
                onTap: () {
                  tapCalled = true;
                },
                colors: mockColors,
              ),
            ],
          ),
        ),
      ));

      // Verify the widget renders
      expect(find.text('Food'), findsOneWidget);
      
      // Verify the selected styling - first find the inner Container
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      
      // Check the decoration properties
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      
      // Check the text style
      final text = tester.widget<Text>(find.text('Food'));
      expect(text.style!.color, equals(mockColors.primaryPink));
      expect(text.style!.fontSize, equals(13));
      expect(text.style!.fontWeight, equals(FontWeight.w600));
      
      // Tap the tab
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      
      // Verify the callback was called
      expect(tapCalled, isTrue);
    });

    testWidgets('renders correctly when not selected', (WidgetTester tester) async {
      bool tapCalled = false;
      
      // Build the widget in unselected state inside a Row to properly handle Expanded
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              LogHistoryTabWidget(
                label: 'Exercise',
                index: 1,
                isSelected: false,
                onTap: () {
                  tapCalled = true;
                },
                colors: mockColors,
              ),
            ],
          ),
        ),
      ));

      // Verify the widget renders
      expect(find.text('Exercise'), findsOneWidget);
      
      // Verify the unselected styling - first find the inner Container
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      
      // Check the decoration properties
      expect(decoration.color, equals(Colors.transparent));
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
      expect(decoration.boxShadow, isNull);
      
      // Check the text style
      final text = tester.widget<Text>(find.text('Exercise'));
      expect(text.style!.color, equals(Colors.black54));
      expect(text.style!.fontSize, equals(13));
      expect(text.style!.fontWeight, equals(FontWeight.w500));
      
      // Tap the tab
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      
      // Verify the callback was called
      expect(tapCalled, isTrue);
    });

    testWidgets('has correct expanded constraints', (WidgetTester tester) async {
      // Build the widget inside a Row to properly handle Expanded
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              LogHistoryTabWidget(
                label: 'Test Tab',
                index: 0,
                isSelected: true,
                onTap: () {},
                colors: mockColors,
              ),
            ],
          ),
        ),
      ));

      // Verify the widget is wrapped in an Expanded
      expect(find.byType(Expanded), findsOneWidget);
    });
    
    testWidgets('has text aligned to center', (WidgetTester tester) async {
      // Build the widget inside a Row to properly handle Expanded
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              LogHistoryTabWidget(
                label: 'Test Tab',
                index: 0,
                isSelected: true,
                onTap: () {},
                colors: mockColors,
              ),
            ],
          ),
        ),
      ));

      // Check text alignment
      final text = tester.widget<Text>(find.text('Test Tab'));
      expect(text.textAlign, equals(TextAlign.center));
    });
  });
}