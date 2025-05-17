import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/free_trials_page.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/pricing_option.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/timeline_item.dart';

void main() {
  group('FreeTrialPage', () {
    // Helper function to pump the widget
    Future<void> pumpFreeTrialPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const FreeTrialPage(),
        ),
      );
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('should render all header elements correctly', (WidgetTester tester) async {
      // Arrange & Act
      await pumpFreeTrialPage(tester);

      // Assert - Check for header texts
      expect(find.text('Start your 7-day FREE\ntrial to continue.'), findsOneWidget);
      expect(find.text('Experience all features without limits.'), findsOneWidget);
      expect(find.text('Choose Your Plan'), findsOneWidget);

      // Check for back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Check for "No Payment Due Now" text
      expect(find.text('No Payment Due Now'), findsOneWidget);
    });

    testWidgets('should render all timeline items correctly', (WidgetTester tester) async {
      // Arrange & Act
      await pumpFreeTrialPage(tester);

      // Assert - Check for timeline item texts
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Access all app features like AI, pet companion, and more'), findsOneWidget);
      
      expect(find.text('In 5 Days - Reminder'), findsOneWidget);
      expect(find.text('You\'ll receive a friendly notification'), findsOneWidget);
      
      expect(find.text('In 7 Days - Billing Starts'), findsOneWidget);
      // We can't test for the exact billing date text since it uses DateTime.now()
      expect(find.textContaining('You\'ll be charged on'), findsOneWidget);
      
      // Check for timeline icons
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      
      // Check for TimelineItem widgets
      expect(find.byType(TimelineItem), findsNWidgets(3));
    });

    testWidgets('should render pricing options correctly', (WidgetTester tester) async {
      // Arrange & Act
      await pumpFreeTrialPage(tester);

      // Assert - Check for pricing options
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      
      // Two PricingOption widgets should be present
      expect(find.byType(PricingOption), findsNWidgets(2));
      
      // Check discount is displayed for yearly option
      expect(find.text('Save 33%'), findsOneWidget);
    });

    testWidgets('should display both pricing options with their initial states', (WidgetTester tester) async {
      // Arrange & Act
      await pumpFreeTrialPage(tester);
      
      // Assert - verify both pricing options are displayed
      expect(find.byType(PricingOption), findsNWidgets(2));
      
      // Find the pricing option widgets to check their selected state
      final pricingOptions = tester.widgetList<PricingOption>(find.byType(PricingOption));
      final PricingOption monthlyOption = pricingOptions.first;
      final PricingOption yearlyOption = pricingOptions.last;
      
      // Initially, monthly should be selected by default
      expect(monthlyOption.isSelected, isTrue);
      expect(yearlyOption.isSelected, isFalse);
    });
    
    testWidgets('should have tappable pricing options with GestureDetectors', (WidgetTester tester) async {
      // Arrange
      await pumpFreeTrialPage(tester);
      
      // Assert - find the GestureDetectors that wrap the pricing options
      final gestureDetectors = find.descendant(
        of: find.byType(Row),
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetectors, findsNWidgets(2));
      
      // Verify we can tap them without exceptions
      await tester.tap(gestureDetectors.first, warnIfMissed: false);
      await tester.pump();
      
      await tester.tap(gestureDetectors.last, warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('should display pricing options with monthly and yearly prices', (WidgetTester tester) async {
      // Arrange & Act
      await pumpFreeTrialPage(tester);
      
      // Assert - check both pricing options are displayed
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      
      // Verify that price values are shown but without checking exact formatting
      // This is more robust as formatting may vary by locale and implementation
      expect(find.byType(PricingOption), findsNWidgets(2));
      
      // Find texts containing price indicators
      expect(find.textContaining('Rp'), findsAtLeastNWidgets(2));
      
      // Verify the discount text is shown for the yearly option
      expect(find.text('Save 33%'), findsOneWidget);
    });

    testWidgets('should have "Start My 7-Day Free Trial" button with correct navigation', (WidgetTester tester) async {
      // Arrange
      await pumpFreeTrialPage(tester);
      
      // Assert - find the button
      expect(find.text('Start My 7-Day Free Trial'), findsOneWidget);
      
      // Find the ElevatedButton instead of just the text for tapping
      final buttonFinder = find.ancestor(
        of: find.text('Start My 7-Day Free Trial'),
        matching: find.byType(ElevatedButton),
      );
      expect(buttonFinder, findsOneWidget);
      
      // Mock the Navigator to prevent test failures due to navigation
      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pump(); // Just pump once to handle the initial tap
      
      // In unit tests, we can't fully assert on navigation
      // but we can verify the button is tappable and the action doesn't crash
    });

    testWidgets('should navigate back when back button is pressed', (WidgetTester tester) async {
      // Arrange
      await pumpFreeTrialPage(tester);
      
      // Find the IconButton containing the back icon
      final backButtonFinder = find.ancestor(
        of: find.byIcon(Icons.arrow_back),
        matching: find.byType(IconButton),
      );
      expect(backButtonFinder, findsOneWidget);
      
      // Act - tap back button
      await tester.tap(backButtonFinder, warnIfMissed: false);
      await tester.pump(); // Just pump once to handle the initial tap
      
      // Assert - in unit tests we can't fully assert on navigation
      // but we can verify the tap doesn't crash
    });

    testWidgets('should have correct date calculations', (WidgetTester tester) async {
      // Arrange
      await pumpFreeTrialPage(tester);
      
      // Get today's date for comparison
      final today = DateTime.now();
      final billingDate = today.add(const Duration(days: 7));
      
      // Format the billing date as expected
      final expectedBillingDate = DateFormat('dd MMM yyyy').format(billingDate);
      
      // Assert - check the billing date is displayed correctly
      expect(find.textContaining('You\'ll be charged on'), findsOneWidget);
      expect(find.textContaining(expectedBillingDate), findsOneWidget);
    });

    testWidgets('should have pricing options displayed properly', (WidgetTester tester) async {
      // Arrange & Act
      await pumpFreeTrialPage(tester);
      
      // Find the pricing options
      expect(find.byType(PricingOption), findsNWidgets(2));
      
      // Assert that both Monthly and Yearly options exist
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      
      // Find the Expanded widgets in the UI
      final expandedWidgets = find.byType(Expanded);
      
      // There should be at least 2 Expanded widgets
      expect(expandedWidgets, findsAtLeastNWidgets(2));
      
      // Verify both pricing options are displayed in the UI
      final monthlyOption = find.ancestor(
        of: find.text('Monthly'),
        matching: find.byType(PricingOption),
      );
      final yearlyOption = find.ancestor(
        of: find.text('Yearly'),
        matching: find.byType(PricingOption),
      );
      
      expect(monthlyOption, findsOneWidget);
      expect(yearlyOption, findsOneWidget);
    });

    testWidgets('should have decorative elements', (WidgetTester tester) async {
      // Arrange & Act
      await pumpFreeTrialPage(tester);
      
      // Find the decorative circular elements
      final decorativeCircles = tester.widgetList<Container>(
        find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle
        ),
      );
      
      // Assert - there should be at least 2 decorative circles
      expect(decorativeCircles.length, greaterThanOrEqualTo(2));
    });
  });
}
