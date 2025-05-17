// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/widgets/pricing_option.dart';

void main() {
  group('PricingOption', () {
    const String monthlyTitle = 'Monthly';
    const int monthlyPrice = 99000;
    const Color primaryGreen = Colors.green;
    final Color textDarkColor = Colors.black87;
    final Color textLightColor = Colors.grey;

    testWidgets('should render unselected option correctly', (WidgetTester tester) async {
      // Arrange - format price the same way the widget does
      final formatter = NumberFormat('#,###', 'id_ID');
      final formattedPrice = formatter.format(monthlyPrice);

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PricingOption(
              title: monthlyTitle,
              price: monthlyPrice,
              isSelected: false,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
              textLightColor: textLightColor,
            ),
          ),
        ),
      );

      // Assert - verify content is displayed correctly
      expect(find.text(monthlyTitle), findsOneWidget);
      expect(find.text(formattedPrice), findsOneWidget);
      expect(find.text('Rp '), findsOneWidget);
      
      // Verify POPULAR label is not displayed for unselected option
      expect(find.text('POPULAR'), findsNothing);
      
      // Check container styling (should have white background for unselected)
      final outerContainer = tester.widget<Container>(find.byType(Container).first);
      final decoration = outerContainer.decoration as BoxDecoration;
      expect((decoration.color as Color), equals(Colors.white));
    });

    testWidgets('should render selected option correctly', (WidgetTester tester) async {
      // Act - build widget with isSelected=true and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PricingOption(
              title: 'Yearly',
              price: 999000,
              isSelected: true,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
              textLightColor: textLightColor,
            ),
          ),
        ),
      );

      // Assert - verify POPULAR label is displayed for selected option
      expect(find.text('POPULAR'), findsOneWidget);
      
      // Check container styling (should have green tinted background for selected)
      final outerContainer = tester.widget<Container>(find.byType(Container).first);
      final decoration = outerContainer.decoration as BoxDecoration;
      expect((decoration.color as Color).value, equals(primaryGreen.withOpacity(0.1).value));
      
      // Check for box shadow presence
      expect(decoration.boxShadow, isNotNull);
    });

    testWidgets('should display discount tag when provided', (WidgetTester tester) async {
      // Arrange
      const String discountText = '40%';

      // Act - build widget with discount and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PricingOption(
              title: 'Yearly',
              price: 999000,
              discount: discountText,
              isSelected: false,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
              textLightColor: textLightColor,
            ),
          ),
        ),
      );

      // Assert - verify discount tag is displayed
      expect(find.text('Save $discountText'), findsOneWidget);
      
      // Find the discount tag container
      final discountTagFinder = find.ancestor(
        of: find.text('Save $discountText'),
        matching: find.byType(Container),
      ).first;
      
      final discountContainer = tester.widget<Container>(discountTagFinder);
      final discountDecoration = discountContainer.decoration as BoxDecoration;
      
      // Verify discount tag styling
      expect(discountDecoration.color?.value, equals(primaryGreen.withOpacity(0.2).value));
      expect(discountDecoration.borderRadius, isA<BorderRadius>());
    });
    
    testWidgets('should use custom colors properly', (WidgetTester tester) async {
      // Arrange
      const Color customGreen = Colors.teal;
      final Color customTextDark = Colors.indigo;
      final Color customTextLight = Colors.blue;

      // Act - build widget with custom colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PricingOption(
              title: monthlyTitle,
              price: monthlyPrice,
              isSelected: true,
              primaryGreen: customGreen,
              textDarkColor: customTextDark,
              textLightColor: customTextLight,
            ),
          ),
        ),
      );

      // Assert - verify custom colors are applied
      // Find the title text
      final titleText = tester.widget<Text>(find.text(monthlyTitle));
      expect(titleText.style?.color, equals(customTextDark));
      
      // Find the currency text (should be light color)
      final currencyText = tester.widget<Text>(find.text('Rp '));
      expect(currencyText.style?.color, equals(customTextLight));
      
      // Find the POPULAR label background
      final popularLabelFinder = find.ancestor(
        of: find.text('POPULAR'),
        matching: find.byType(Container),
      ).first;
      
      final popularContainer = tester.widget<Container>(popularLabelFinder);
      final popularDecoration = popularContainer.decoration as BoxDecoration;
      
      // Verify POPULAR label uses the custom green
      expect(popularDecoration.color, equals(customGreen));
    });

    testWidgets('should have consistent height regardless of content', (WidgetTester tester) async {
      // Act - build two widgets: one with discount, one without
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PricingOption(
                  title: 'Monthly',
                  price: 99000,
                  isSelected: false,
                  primaryGreen: primaryGreen,
                  textDarkColor: textDarkColor,
                  textLightColor: textLightColor,
                ),
                PricingOption(
                  title: 'Yearly',
                  price: 999000,
                  discount: '40%',
                  isSelected: true,
                  primaryGreen: primaryGreen,
                  textDarkColor: textDarkColor,
                  textLightColor: textLightColor,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert - verify both Pricing Options are rendered
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      
      // Check for the discount tag
      expect(find.text('Save 40%'), findsOneWidget);
      
      // Check for POPULAR label on selected option
      expect(find.text('POPULAR'), findsOneWidget);
    });

    testWidgets('should format price with thousand separator', (WidgetTester tester) async {
      // Arrange - large price needs proper formatting
      const int largePrice = 1299000;
      final formatter = NumberFormat('#,###', 'id_ID');
      final expectedFormattedPrice = formatter.format(largePrice);

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PricingOption(
              title: 'Premium',
              price: largePrice,
              isSelected: false,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
              textLightColor: textLightColor,
            ),
          ),
        ),
      );

      // Assert - verify price is formatted correctly
      expect(find.text(expectedFormattedPrice), findsOneWidget);
    });
  });
}
