// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/health_metrics/presentation/widgets/user_information_card.dart';

void main() {
  group('UserInformationCard', () {
    late HealthMetricsFormState mockState;
    final primaryGreen = Colors.green;
    final textDarkColor = Colors.black87;

    // Mock functions that are required by the widget
    int calculateAge(DateTime? birthDate) {
      return birthDate != null ? DateTime.now().year - birthDate.year : 0;
    }

    String formatActivityLevel(String? activityLevel) {
      if (activityLevel == null) return 'Not specified';
      
      switch (activityLevel) {
        case 'sedentary':
          return 'Sedentary (little or no exercise)';
        case 'lightly_active':
          return 'Lightly active (light exercise 1-3 days/week)';
        case 'moderately_active':
          return 'Moderately active (moderate exercise 3-5 days/week)';
        case 'very_active':
          return 'Very active (hard exercise 6-7 days/week)';
        case 'extra_active':
          return 'Extra active (very hard exercise & physical job)';
        default:
          return activityLevel;
      }
    }

    setUp(() {
      // Setup a mock state with complete user information
      mockState = HealthMetricsFormState(
        height: 175,
        weight: 70,
        gender: 'Male',
        birthDate: DateTime(1990, 1, 1),
        activityLevel: 'moderately_active',
        dietType: 'Balanced',
        desiredWeight: 65,
        weeklyGoal: 0.5,
        selectedGoals: ['Lose weight', 'Improve fitness'],
      );
    });

    testWidgets('should render all sections correctly', (WidgetTester tester) async {
      // Arrange
      final goalsDisplay = mockState.selectedGoals.join(', ');

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserInformationCard(
              goalsDisplay: goalsDisplay,
              state: mockState,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
              calculateAge: calculateAge,
              formatActivityLevel: formatActivityLevel,
            ),
          ),
        ),
      );

      // Assert - verify all sections are displayed
      expect(find.text('Your Information'), findsOneWidget);
      expect(find.text('Goals'), findsOneWidget);
      expect(find.text('Body Measurements'), findsOneWidget);
      expect(find.text('Activity & Diet'), findsOneWidget);
      expect(find.text('Target Goals'), findsOneWidget);
      
      // Debug: Print out all text widgets
      tester.widgetList<Text>(find.byType(Text)).forEach((widget) {
        print('TEXT: "${widget.data}"');
      });
      
      // Check that all the correct data is displayed
      expect(find.text('Lose weight, Improve fitness'), findsOneWidget);
      
      // Test with exact formats including decimal points
      expect(find.text('Height: 175.0 cm'), findsOneWidget);
      expect(find.text('Weight: 70.0 kg'), findsOneWidget);
      expect(find.text('Gender: Male'), findsOneWidget);
      
      // Check the calculated age (assuming test year is after 1990)
      final expectedAge = DateTime.now().year - 1990;
      expect(find.text('Age: $expectedAge'), findsOneWidget);
      
      // Check activity level and diet type
      expect(find.text('Activity Level: Moderately active (moderate exercise 3-5 days/week)'), findsOneWidget);
      expect(find.text('Diet Type: Balanced'), findsOneWidget);
      
      // Check target goals
      expect(find.text('Desired Weight: 65.0 kg'), findsOneWidget);
      expect(find.text('Weekly Goal: 0.5 kg/week'), findsOneWidget);
    });

    testWidgets('should handle missing or null data gracefully', (WidgetTester tester) async {
      // Arrange - create a state with missing data
      final incompleteState = HealthMetricsFormState();
      final goalsDisplay = '';

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserInformationCard(
              goalsDisplay: goalsDisplay,
              state: incompleteState,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
              calculateAge: calculateAge,
              formatActivityLevel: formatActivityLevel,
            ),
          ),
        ),
      );

      // Assert - verify placeholders are displayed for missing data
      expect(find.text('Height: -'), findsOneWidget);
      expect(find.text('Weight: -'), findsOneWidget);
      expect(find.text('Gender: -'), findsOneWidget);
      expect(find.text('Age: 0'), findsOneWidget);
      expect(find.text('Activity Level: Not specified'), findsOneWidget);
      expect(find.text('Diet Type: -'), findsOneWidget);
      expect(find.text('Desired Weight: -'), findsOneWidget);
      expect(find.text('Weekly Goal: -'), findsOneWidget);
    });

    testWidgets('should use the provided colors for styling', (WidgetTester tester) async {
      // Arrange
      final customGreen = Colors.blue; // Custom color to test
      final customTextColor = Colors.red; // Custom color to test
      final goalsDisplay = mockState.selectedGoals.join(', ');

      // Act - build widget with custom colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserInformationCard(
              goalsDisplay: goalsDisplay,
              state: mockState,
              primaryGreen: customGreen,
              textDarkColor: customTextColor,
              calculateAge: calculateAge,
              formatActivityLevel: formatActivityLevel,
            ),
          ),
        ),
      );

      // Assert - verify icons have the custom color
      final icon = tester.widget<Icon>(find.byIcon(Icons.assignment));
      expect(icon.color, equals(customGreen));
      
      // Verify the main title text has the custom color
      final mainTitle = tester.widget<Text>(find.text('Your Information'));
      expect(mainTitle.style?.color, equals(customTextColor));
      
      // Verify section titles have the custom color
      final sectionTitle = tester.widget<Text>(find.text('Goals'));
      expect(sectionTitle.style?.color, equals(customTextColor));
    });

    testWidgets('should handle different activity levels correctly', (WidgetTester tester) async {
      // Arrange - create a state with different activity level
      final activeState = HealthMetricsFormState(
        activityLevel: 'very_active',
      );
      final goalsDisplay = '';

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserInformationCard(
              goalsDisplay: goalsDisplay,
              state: activeState,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
              calculateAge: calculateAge,
              formatActivityLevel: formatActivityLevel,
            ),
          ),
        ),
      );

      // Debug output all text widgets to find exact format
      print('Debug activity level test:');
      tester.widgetList<Text>(find.byType(Text)).forEach((widget) {
        print('TEXT: "${widget.data}"');
      });
      
      // Assert - verify activity level is formatted correctly
      expect(find.text('Activity Level: Very active (hard exercise 6-7 days/week)'), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Arrange
      final goalsDisplay = mockState.selectedGoals.join(', ');

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserInformationCard(
              goalsDisplay: goalsDisplay,
              state: mockState,
              primaryGreen: primaryGreen,
              textDarkColor: textDarkColor,
              calculateAge: calculateAge,
              formatActivityLevel: formatActivityLevel,
            ),
          ),
        ),
      );

      // Assert - verify widget hierarchy and structure
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Expanded), findsWidgets);
      
      // Find the main container and verify its decoration
      final mainContainer = tester.widget<Container>(find.byType(Container).first);
      final decoration = mainContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.border, isA<Border>());
    });

    testWidgets('should apply consistent padding and spacing', (WidgetTester tester) async {
      // Arrange
      final goalsDisplay = mockState.selectedGoals.join(', ');

      // Act - build widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserInformationCard(
                goalsDisplay: goalsDisplay,
                state: mockState,
                primaryGreen: primaryGreen,
                textDarkColor: textDarkColor,
                calculateAge: calculateAge,
                formatActivityLevel: formatActivityLevel,
              ),
            ),
          ),
        ),
      );

      // Assert - verify spacing widgets are present
      expect(find.byType(SizedBox), findsWidgets);
      
      // Find container padding
      final mainContainer = tester.widget<Container>(find.byType(Container).first);
      expect(mainContainer.padding, equals(const EdgeInsets.all(20)));
    });
  });
}
