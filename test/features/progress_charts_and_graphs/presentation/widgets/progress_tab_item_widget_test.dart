import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/progress_tab_item_widget.dart';

void main() {
  late AppColors colors;
  
  setUp(() {
    colors = AppColors.defaultColors();
  });
  
  group('ProgressTabItemWidget', () {
    testWidgets('should render correctly with provided label', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      void onTap() {
        tapped = true;
      }
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ProgressTabItemWidget(
                  label: 'Weight',
                  index: 0,
                  isSelected: true,
                  onTap: onTap,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Weight'), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });
    
    testWidgets('should apply selected styles when isSelected is true', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      void onTap() {
        tapped = true;
      }
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ProgressTabItemWidget(
                  label: 'Nutrition',
                  index: 1,
                  isSelected: true,
                  onTap: onTap,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
      expect(decoration.boxShadow![0].color, equals(Colors.black.withOpacity(0.05)));
      expect(decoration.boxShadow![0].blurRadius, equals(4));
      expect(decoration.boxShadow![0].offset, equals(const Offset(0, 2)));
      
      final text = tester.widget<Text>(find.text('Nutrition'));
      expect(text.textAlign, equals(TextAlign.center));
      expect(text.style!.color, equals(colors.primaryPink));
      expect(text.style!.fontSize, equals(13));
      expect(text.style!.fontWeight, equals(FontWeight.w600));
    });
    
    testWidgets('should apply unselected styles when isSelected is false', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      void onTap() {
        tapped = true;
      }
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ProgressTabItemWidget(
                  label: 'Exercise',
                  index: 2,
                  isSelected: false,
                  onTap: onTap,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.transparent));
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
      expect(decoration.boxShadow, isNull);
      
      final text = tester.widget<Text>(find.text('Exercise'));
      expect(text.textAlign, equals(TextAlign.center));
      expect(text.style!.color, equals(Colors.black54));
      expect(text.style!.fontSize, equals(13));
      expect(text.style!.fontWeight, equals(FontWeight.w500));
    });
    
    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      void onTap() {
        tapped = true;
      }
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ProgressTabItemWidget(
                  label: 'Weight',
                  index: 0,
                  isSelected: true,
                  onTap: onTap,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Before tap
      expect(tapped, isFalse);
      
      // Perform tap
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      
      // After tap
      expect(tapped, isTrue);
    });
    
    testWidgets('should apply correct padding', (WidgetTester tester) async {
      // Arrange
      void onTap() {}
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ProgressTabItemWidget(
                  label: 'Weight',
                  index: 0,
                  isSelected: true,
                  onTap: onTap,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, equals(const EdgeInsets.symmetric(vertical: 8)));
    });
  });
}