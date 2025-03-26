import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/presentation/widgets/macro_card_widget.dart';

void main() {
  group('MacroCardWidget', () {
    // Test data
    final testMacro = MacroNutrient(
      label: 'Protein',
      percentage: 25,
      detail: '75g/120g',
      color: const Color(0xFFFF6B6B), // Pink color
    );
    
    testWidgets('should render macro nutrient data correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroCardWidget(macro: testMacro),
          ),
        ),
      );
      
      // Assert - verify text elements are displayed correctly
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('75g/120g'), findsOneWidget);
      
      // Verify the LinearProgressIndicator exists
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should apply correct text styles', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroCardWidget(macro: testMacro),
          ),
        ),
      );
      
      // Verify label style
      final labelText = tester.widget<Text>(find.text('Protein'));
      expect(labelText.style?.color, equals(Colors.black54));
      expect(labelText.style?.fontSize, equals(14));
      
      // Verify percentage style
      final percentageText = tester.widget<Text>(find.text('25%'));
      expect(percentageText.style?.color, equals(testMacro.color));
      expect(percentageText.style?.fontSize, equals(24));
      expect(percentageText.style?.fontWeight, equals(FontWeight.bold));
      
      // Verify detail style
      final detailText = tester.widget<Text>(find.text('75g/120g'));
      expect(detailText.style?.color, equals(Colors.black54));
      expect(detailText.style?.fontSize, equals(12));
    });
    
    testWidgets('should have proper container styling', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroCardWidget(macro: testMacro),
          ),
        ),
      );
      
      // Find the main container
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      
      final container = tester.widget<Container>(containerFinder);
      
      // Verify padding
      expect(container.padding, equals(const EdgeInsets.all(16)));
      
      // Verify decoration properties
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
      
      // Verify box shadow
      expect(decoration.boxShadow?.length, equals(1));
      final shadow = decoration.boxShadow![0];
      expect(shadow.color.alpha, equals(Colors.black.withOpacity(0.05).alpha));
      expect(shadow.blurRadius, equals(10));
      expect(shadow.offset, equals(const Offset(0, 2)));
    });
    
    testWidgets('should set correct progress indicator properties', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroCardWidget(macro: testMacro),
          ),
        ),
      );
      
      // Find the LinearProgressIndicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      
      // Verify progress indicator value
      expect(progressIndicator.value, equals(testMacro.percentage / 100));
      
      // Verify background color
      expect(
        progressIndicator.backgroundColor, 
        equals(testMacro.color.withOpacity(0.1))
      );
      
      // Verify foreground color
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(testMacro.color));
      
      // Verify height
      expect(progressIndicator.minHeight, equals(6));
    });
    
    testWidgets('should apply ClipRRect with correct border radius to progress indicator', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroCardWidget(macro: testMacro),
          ),
        ),
      );
      
      // Find the ClipRRect
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      
      // Verify border radius
      expect(clipRRect.borderRadius, equals(BorderRadius.circular(4)));
    });
    
    testWidgets('should have correct column structure with spacing', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroCardWidget(macro: testMacro),
          ),
        ),
      );
      
      // Find the Column
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);
      
      // Verify SizedBox heights
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(sizedBoxes.length, equals(3));
      
      // There should be three SizedBoxes with heights 8, 4, and 8
      expect(sizedBoxes[0].height, equals(8));
      expect(sizedBoxes[1].height, equals(4));
      expect(sizedBoxes[2].height, equals(8));
    });
    
    testWidgets('should handle macro with 0% percentage', (WidgetTester tester) async {
      // Arrange
      final zeroMacro = MacroNutrient(
        label: 'Carbs',
        percentage: 0,
        detail: '0g/150g',
        color: const Color(0xFF4ECDC4), // Green color
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroCardWidget(macro: zeroMacro),
          ),
        ),
      );
      
      // Assert
      expect(find.text('0%'), findsOneWidget);
      
      // Find the LinearProgressIndicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      
      // Verify progress is 0
      expect(progressIndicator.value, equals(0.0));
    });
    
    testWidgets('should handle macro with 100% percentage', (WidgetTester tester) async {
      // Arrange
      final fullMacro = MacroNutrient(
        label: 'Fat',
        percentage: 100,
        detail: '65g/65g',
        color: const Color(0xFFFFB946), // Yellow color
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MacroCardWidget(macro: fullMacro),
          ),
        ),
      );
      
      // Assert
      expect(find.text('100%'), findsOneWidget);
      
      // Find the LinearProgressIndicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      
      // Verify progress is 1.0 (100%)
      expect(progressIndicator.value, equals(1.0));
    });
  });
}