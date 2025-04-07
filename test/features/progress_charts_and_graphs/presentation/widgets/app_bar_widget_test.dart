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

      // Assert
      expect(find.text('Analytics'), findsOneWidget);
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

    testWidgets('should display calendar button', (WidgetTester tester) async {
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
      expect(find.byIcon(CupertinoIcons.calendar), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Icon &&
            widget.icon == CupertinoIcons.calendar &&
            widget.color == Colors.black87),
        findsOneWidget,
      );
    });

    testWidgets('should call onCalendarPressed when calendar button is pressed',
        (WidgetTester tester) async {
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

      // Act - tap on the calendar button
      await tester.tap(find.byIcon(CupertinoIcons.calendar));
      await tester.pump();

      // Assert
      expect(calendarPressed, isTrue);
    });

    testWidgets('should display avatar with letter A', (WidgetTester tester) async {
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
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      
      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.backgroundColor, equals(Colors.white));
      expect(circleAvatar.radius, equals(16));
      
      final avatarText = tester.widget<Text>(find.text('A'));
      expect(avatarText.style?.color, equals(Colors.black87));
      expect(avatarText.style?.fontWeight, equals(FontWeight.w500));
      expect(avatarText.style?.fontSize, equals(13));
    });

    testWidgets('should have correct container decoration for avatar', (WidgetTester tester) async {
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
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(CircleAvatar),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.decoration, isA<BoxDecoration>());
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
      expect(decoration.color, equals(Colors.white));
      
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
      expect(decoration.boxShadow![0].color, equals(Colors.black12));
      expect(decoration.boxShadow![0].blurRadius, equals(4));
      expect(decoration.boxShadow![0].offset, equals(const Offset(0, 2)));
    });
  });
}