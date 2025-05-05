// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_tab_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/week_selection_tabs.dart';

void main() {
  group('WeekSelectionTabs', () {
    // Helper function to create test widget
    Widget createTestWidget({
      String selectedWeek = 'This week',
      Function(String)? onWeekSelected,
      Color primaryColor = Colors.blue,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: WeekSelectionTabs(
              selectedWeek: selectedWeek,
              onWeekSelected: onWeekSelected ?? (week) {},
              primaryColor: primaryColor,
            ),
          ),
        ),
      );
    }

    testWidgets('renders all four week options correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify all four week options are rendered
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Last week'), findsOneWidget);
      expect(find.text('2 wks. ago'), findsOneWidget);
      expect(find.text('3 wks. ago'), findsOneWidget);

      // Verify exactly four PeriodTabWidgets are rendered
      expect(find.byType(PeriodTabWidget), findsNWidgets(4));
    });

    testWidgets('selects the correct tab based on selectedWeek prop', (WidgetTester tester) async {
      // Test with 'This week' selected
      await tester.pumpWidget(createTestWidget(selectedWeek: 'This week'));

      // Verify 'This week' tab is selected
      final thisWeekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('This week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(thisWeekTab.isSelected, true);

      // Other tabs should not be selected
      final lastWeekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Last week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(lastWeekTab.isSelected, false);

      // Test with 'Last week' selected
      await tester.pumpWidget(createTestWidget(selectedWeek: 'Last week'));
      await tester.pumpAndSettle();

      // Verify 'Last week' tab is now selected
      final updatedLastWeekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Last week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(updatedLastWeekTab.isSelected, true);

      // 'This week' should no longer be selected
      final updatedThisWeekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('This week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(updatedThisWeekTab.isSelected, false);
    });

    testWidgets('selects older week tabs correctly', (WidgetTester tester) async {
      // Test with '2 wks. ago' selected
      await tester.pumpWidget(createTestWidget(selectedWeek: '2 wks. ago'));

      // Verify '2 wks. ago' tab is selected
      final twoWeeksTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('2 wks. ago'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(twoWeeksTab.isSelected, true);

      // Test with '3 wks. ago' selected
      await tester.pumpWidget(createTestWidget(selectedWeek: '3 wks. ago'));
      await tester.pumpAndSettle();

      // Verify '3 wks. ago' tab is now selected
      final threeWeeksTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('3 wks. ago'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(threeWeeksTab.isSelected, true);
    });

    testWidgets('calls onWeekSelected when tapping a tab', (WidgetTester tester) async {
      String selectedWeek = 'This week';

      await tester.pumpWidget(createTestWidget(
        selectedWeek: selectedWeek,
        onWeekSelected: (week) {
          selectedWeek = week;
        },
      ));

      // Tap on 'Last week' tab
      await tester.tap(find.text('Last week'));
      await tester.pump();

      // Verify callback was called and the value was updated
      expect(selectedWeek, 'Last week');

      // Tap on '2 wks. ago' tab
      await tester.tap(find.text('2 wks. ago'));
      await tester.pump();

      // Verify callback was called again with new value
      expect(selectedWeek, '2 wks. ago');

      // Tap on '3 wks. ago' tab
      await tester.tap(find.text('3 wks. ago'));
      await tester.pump();

      // Verify callback was called again with new value
      expect(selectedWeek, '3 wks. ago');

      // Tap on 'This week' tab to return to initial state
      await tester.tap(find.text('This week'));
      await tester.pump();

      // Verify callback was called again with initial value
      expect(selectedWeek, 'This week');
    });

    testWidgets('applies the primary color correctly to selected tabs', (WidgetTester tester) async {
      const Color testColor = Colors.purple;

      await tester.pumpWidget(createTestWidget(
        selectedWeek: 'This week',
        primaryColor: testColor,
      ));

      // Verify selected tab uses the provided primary color
      final thisWeekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('This week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(thisWeekTab.selectedColor, testColor);

      // Verify other tabs also have the same selected color configured
      // (even though they're not currently selected)
      final lastWeekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Last week'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(lastWeekTab.selectedColor, testColor);
    });

    testWidgets('container has correct decoration properties', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the outer container
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WeekSelectionTabs),
          matching: find.byType(Container),
        ).first,
      );

      // Verify container decoration properties
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.grey[200]);
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('handles dynamic changes to selected week', (WidgetTester tester) async {
      final key = GlobalKey<ScaffoldState>();
      String currentSelectedWeek = 'This week';
      
      Widget buildTestWidget() {
        return MaterialApp(
          home: Scaffold(
            key: key,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: WeekSelectionTabs(
                selectedWeek: currentSelectedWeek,
                onWeekSelected: (week) {
                  currentSelectedWeek = week;
                },
                primaryColor: Colors.blue,
              ),
            ),
          ),
        );
      }
      
      await tester.pumpWidget(buildTestWidget());
      
      // Initial state: 'This week' should be selected
      expect(
        tester.widget<PeriodTabWidget>(
          find.ancestor(
            of: find.text('This week'),
            matching: find.byType(PeriodTabWidget),
          ),
        ).isSelected, 
        true
      );
      
      // Change selected week programmatically
      currentSelectedWeek = 'Last week';
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      
      // Verify 'Last week' is now selected
      expect(
        tester.widget<PeriodTabWidget>(
          find.ancestor(
            of: find.text('Last week'),
            matching: find.byType(PeriodTabWidget),
          ),
        ).isSelected, 
        true
      );
      
      // And 'This week' is no longer selected
      expect(
        tester.widget<PeriodTabWidget>(
          find.ancestor(
            of: find.text('This week'),
            matching: find.byType(PeriodTabWidget),
          ),
        ).isSelected, 
        false
      );
    });
  });
}
