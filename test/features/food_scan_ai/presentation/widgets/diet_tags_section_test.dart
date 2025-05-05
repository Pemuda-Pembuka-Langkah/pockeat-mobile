// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/food_scan_ai/presentation/widgets/diet_tags_section.dart';

void main() {
  const primaryGreen = Color(0xFF4ECDC4);
  const warningYellow = Color(0xFFF4D03F);

  group('DietTagsSection', () {
    testWidgets('displays safety tag when warnings list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietTagsSection(
              warnings: const [],
              primaryGreen: primaryGreen,
              warningYellow: warningYellow,
            ),
          ),
        ),
      );

      // Verify section title is displayed
      expect(find.text('Warnings'), findsOneWidget);

      // Verify safety tag is displayed
      expect(find.text('No nutritional concerns detected'), findsOneWidget);

      // Verify check icon is displayed
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Verify no warning tags are displayed
      expect(find.byIcon(Icons.warning_amber), findsNothing);
      expect(find.byIcon(Icons.water_drop), findsNothing);
      expect(find.byIcon(Icons.icecream), findsNothing);
    });

    testWidgets('displays warning tags when warnings list is not empty',
        (WidgetTester tester) async {
      final warnings = [
        'High sodium content',
        'High sugar content',
        'High cholesterol content',
        'High saturated fat content',
        'Generic warning'
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietTagsSection(
              warnings: warnings,
              primaryGreen: primaryGreen,
              warningYellow: warningYellow,
            ),
          ),
        ),
      );

      // Verify section title is displayed
      expect(find.text('Warnings'), findsOneWidget);

      // Verify safety tag is NOT displayed
      expect(find.text('No nutritional concerns detected'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Verify all warning tags are displayed
      for (final warning in warnings) {
        expect(find.text(warning), findsOneWidget);
      }

      // Check that specific icons are used for different warning types
      expect(find.byIcon(Icons.water_drop), findsOneWidget); // sodium
      expect(find.byIcon(Icons.icecream), findsOneWidget); // sugar
      expect(find.byIcon(Icons.medical_information), findsOneWidget); // cholesterol
      expect(find.byIcon(Icons.opacity), findsOneWidget); // fat
      expect(find.byIcon(Icons.warning_amber), findsOneWidget); // generic
    });

    testWidgets('uses correct colors for safety tag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietTagsSection(
              warnings: const [],
              primaryGreen: primaryGreen,
              warningYellow: warningYellow,
            ),
          ),
        ),
      );

      // Find the safety tag container
      final safetyContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('No nutritional concerns detected'),
          matching: find.byType(Container),
        ),
      );

      // Verify container decoration uses primaryGreen
      final decoration = safetyContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(primaryGreen.withOpacity(0.1)));
      expect(
          decoration.border,
          equals(Border.all(color: primaryGreen.withOpacity(0.3))));
    });

    testWidgets('uses correct colors for warning tags',
        (WidgetTester tester) async {
      final warnings = ['High sodium content'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietTagsSection(
              warnings: warnings,
              primaryGreen: primaryGreen,
              warningYellow: warningYellow,
            ),
          ),
        ),
      );

      // Find the warning tag container
      final warningContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('High sodium content'),
          matching: find.byType(Container),
        ),
      );

      // Verify container decoration uses warningYellow
      final decoration = warningContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(warningYellow.withOpacity(0.1)));
      expect(
          decoration.border,
          equals(Border.all(color: warningYellow.withOpacity(0.3))));
    });

    testWidgets('handles multiple warning tags with proper layout',
        (WidgetTester tester) async {
      final warnings = List.generate(5, (index) => 'Warning ${index + 1}');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DietTagsSection(
                warnings: warnings,
                primaryGreen: primaryGreen,
                warningYellow: warningYellow,
              ),
            ),
          ),
        ),
      );

      // Verify all warning tags are displayed
      for (final warning in warnings) {
        expect(find.text(warning), findsOneWidget);
      }

      // Verify Wrap widget is used for layout
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('has correct padding and spacing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietTagsSection(
              warnings: const [],
              primaryGreen: primaryGreen,
              warningYellow: warningYellow,
            ),
          ),
        ),
      );

      // Find the main padding widget directly under DietTagsSection
      final paddingWidget = tester.widget<Padding>(
        find.ancestor(
          of: find.text('Warnings'),
          matching: find.byType(Padding),
        ),
      );

      // Verify padding values
      expect(
          paddingWidget.padding,
          equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));

      // Find the specific SizedBox between title and content using descendant finder
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(SizedBox),
        ).first,
      );
      
      // Verify the height of this SizedBox
      expect(sizedBox.height, equals(12));
    });

    testWidgets('has correct text styles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietTagsSection(
              warnings: const [],
              primaryGreen: primaryGreen,
              warningYellow: warningYellow,
            ),
          ),
        ),
      );

      // Verify title text style
      final titleText = tester.widget<Text>(find.text('Warnings'));
      expect(titleText.style?.fontSize, equals(20));
      expect(titleText.style?.fontWeight, equals(FontWeight.w600));
      expect(titleText.style?.color, equals(Colors.black87));

      // Verify safety tag text style
      final safetyText = tester.widget<Text>(
          find.text('No nutritional concerns detected'));
      expect(safetyText.style?.fontSize, equals(14));
      expect(safetyText.style?.fontWeight, equals(FontWeight.w500));
      expect(safetyText.style?.color, equals(Colors.black87));
    });
  });
}
