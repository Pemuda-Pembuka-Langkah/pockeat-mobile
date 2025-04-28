import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    testWidgets('renders all three period options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Verify all three options are rendered
      expect(find.text('1 Week'), findsOneWidget);
      expect(find.text('1 Month'), findsOneWidget);
      expect(find.text('All time'), findsOneWidget);
    });

    testWidgets('has correct default selection based on props', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(selectedPeriod: '1 Week'));

      // Verify the PeriodTabWidgets have correct isSelected value
      final weekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('1 Week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weekTab.isSelected, true);

      final monthTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('1 Month'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(monthTab.isSelected, false);

      final allTimeTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('All time'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(allTimeTab.isSelected, false);
    });

    testWidgets('has correct selection when changed via props', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(selectedPeriod: '1 Month'));

      // Verify the PeriodTabWidgets have correct isSelected value
      final weekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('1 Week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weekTab.isSelected, false);

      final monthTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('1 Month'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(monthTab.isSelected, true);

      // Check 'All time' tab with different selection
      await tester.pumpWidget(createWidget(selectedPeriod: 'All time'));
      await tester.pumpAndSettle();

      final allTimeTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('All time'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(allTimeTab.isSelected, true);
    });

    testWidgets('calls onPeriodSelected when tapping a tab', (WidgetTester tester) async {
      String selectedPeriod = '1 Week';

      await tester.pumpWidget(createWidget(
        selectedPeriod: selectedPeriod,
        onPeriodSelected: (period) {
          selectedPeriod = period;
        },
      ));

      // Tap the '1 Month' tab
      await tester.tap(find.text('1 Month'));
      await tester.pump();
      
      // Verify callback was called and value was updated
      expect(selectedPeriod, '1 Month');

      // Tap the 'All time' tab
      await tester.tap(find.text('All time'));
      await tester.pump();
      
      // Verify callback was called and value was updated again
      expect(selectedPeriod, 'All time');

      // Tap the '1 Week' tab to go back to initial state
      await tester.tap(find.text('1 Week'));
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

      // Verify the selected tab has correct color
      final weekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('1 Week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weekTab.selectedColor, testColor);
      
      // Verify another tab also has the same selected color configured
      final monthTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('1 Month'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(monthTab.selectedColor, testColor);
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
      expect(row.children.length, 3);
      expect(row.children.every((child) => child is PeriodTabWidget), true);
    });
  });
}