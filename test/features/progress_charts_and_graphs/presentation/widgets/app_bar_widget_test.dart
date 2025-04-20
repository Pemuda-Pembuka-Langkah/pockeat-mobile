import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/app_bar_widget.dart';

void main() {
  group('AppBarWidget', () {
    // Mock callback for calendar button
    bool calendarPressed = false;
    void onCalendarPressed() {
      calendarPressed = true;
    }

    // Reset the callback flag before each test
    setUp(() {
      calendarPressed = false;
    });

    testWidgets('should display correct title', (WidgetTester tester) async {
      // Arrange
      final colors = AppColors.defaultColors();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AppBarWidget(
                  colors: colors,
                  onCalendarPressed: onCalendarPressed,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert - Title changed from "Analytics" to "Progress" to match actual implementation
      expect(find.text('Progress'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.style?.fontSize == 18 &&
            widget.style?.fontWeight == FontWeight.w600 &&
            widget.style?.color == Colors.black87),
        findsOneWidget,
      );
    });

    testWidgets('should use primaryYellow as background color', (WidgetTester tester) async {
      // Arrange
      final colors = AppColors.defaultColors();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AppBarWidget(
                  colors: colors,
                  onCalendarPressed: onCalendarPressed,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.backgroundColor, equals(colors.primaryYellow));
      expect(sliverAppBar.elevation, equals(0));
      expect(sliverAppBar.pinned, isTrue);
      expect(sliverAppBar.floating, isFalse);
      expect(sliverAppBar.toolbarHeight, equals(60));
    });

    testWidgets('should have automaticallyImplyLeading set to false', (WidgetTester tester) async {
      // Arrange
      final colors = AppColors.defaultColors();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AppBarWidget(
                  colors: colors,
                  onCalendarPressed: onCalendarPressed,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.automaticallyImplyLeading, isFalse);
    });
  });
}