// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
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

    testWidgets('should display correct title with proper styling', (WidgetTester tester) async {
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
      expect(find.text('Progress'), findsOneWidget);
      
      // Find the title text and verify its style matches the new implementation
      final titleText = tester.widget<Text>(find.text('Progress'));
      expect(titleText.style?.fontSize, 18);
      expect(titleText.style?.fontWeight, FontWeight.bold);
      expect(titleText.style?.color, Colors.black87);
    });

    testWidgets('should use white background with specified properties', (WidgetTester tester) async {
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
      
      // Verify the styling matches the updated implementation
      expect(sliverAppBar.backgroundColor, Colors.white);
      expect(sliverAppBar.foregroundColor, Colors.black87);
      expect(sliverAppBar.elevation, 0);
      expect(sliverAppBar.pinned, true);
      expect(sliverAppBar.floating, false);
      expect(sliverAppBar.toolbarHeight, 60);
      expect(sliverAppBar.centerTitle, true);
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
      expect(sliverAppBar.automaticallyImplyLeading, false);
    });
  });
}