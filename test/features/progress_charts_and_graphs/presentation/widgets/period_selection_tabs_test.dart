// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_selection_tabs.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_tab_widget.dart';

void main() {
  group('PeriodSelectionTabs', () {
    // Function to create test widget with required parameters
    Widget createWidget({
      String selectedPeriod = '1 Week',
      Function(String)? onPeriodSelected,
      Color primaryColor = Colors.blue,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PeriodSelectionTabs(
            selectedPeriod: selectedPeriod,
            onPeriodSelected: onPeriodSelected ?? (period) {},
            primaryColor: primaryColor,
          ),
        ),
      );
    }

    testWidgets('renders all period options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Verify the two options that actually exist in the widget
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('has correct default selection based on props', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(selectedPeriod: '1 Week'));

      // Verify PeriodTabWidgets have correct isSelected values
      final dailyTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Daily'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(dailyTab.isSelected, true);

      final weeklyTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Weekly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weeklyTab.isSelected, false);
    });

    testWidgets('has correct selection when changed via props', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(selectedPeriod: '1 Month'));

      // Verify PeriodTabWidgets have correct isSelected values
      final dailyTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Daily'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(dailyTab.isSelected, false);

      final weeklyTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Weekly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weeklyTab.isSelected, true);
    });

    testWidgets('calls onPeriodSelected when tapping a tab', (WidgetTester tester) async {
      String selectedPeriod = '1 Week';

      await tester.pumpWidget(createWidget(
        selectedPeriod: selectedPeriod,
        onPeriodSelected: (period) {
          selectedPeriod = period;
        },
      ));

      // Tap the Weekly tab
      await tester.tap(find.text('Weekly'));
      await tester.pump();
      
      // Verify callback was called and value was updated
      expect(selectedPeriod, '1 Month');

      // Tap the Daily tab to return to initial state
      await tester.tap(find.text('Daily'));
      await tester.pump();
      
      // Verify callback was called and value was updated again
      expect(selectedPeriod, '1 Week');
    });

    testWidgets('applies primary color correctly to selected tab', (WidgetTester tester) async {
      const Color testColor = Colors.purple;
      
      await tester.pumpWidget(createWidget(
        selectedPeriod: '1 Week',
        primaryColor: testColor,
      ));

      // Verify the selected tab has the correct color
      final dailyTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Daily'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(dailyTab.selectedColor, testColor);
      
      // Verify other tab also has the same color
      final weeklyTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Weekly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weeklyTab.selectedColor, testColor);
    });
    
    testWidgets('container has correct decoration properties', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Find the outer container
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PeriodSelectionTabs),
          matching: find.byType(Container),
        ).first,
      );
      
      // Verify container decoration properties
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.grey[200]);
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });
    
    testWidgets('layout uses Row for horizontal arrangement', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Verify Row is used for layout
      expect(find.byType(Row), findsOneWidget);
      
      // Verify all PeriodTabWidgets are direct children of Row
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 2);
      expect(row.children.every((child) => child is PeriodTabWidget), true);
    });
  });
}
