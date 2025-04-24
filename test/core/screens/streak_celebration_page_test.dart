// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import 'package:pockeat/core/screens/streak_celebration_page.dart';

// Custom finder untuk Lottie animations jika 
//diperlukan di masa depan

void main() {
  // Group 1: Test UI Elements and Layout
  group('UI Elements and Layout Tests', () {
    testWidgets('Page shows correct app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: 10),
        ),
      );
      
      expect(find.text('Streak Achievement'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
    
    testWidgets('Page shows streak number prominently', (WidgetTester tester) async {
      const testStreak = 42;
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: testStreak),
        ),
      );
      
      // Should find the exact streak number
      expect(find.text('42'), findsOneWidget);
      
      // The text should be large (we can verify the style in the widget)
      final textWidget = tester.widget<Text>(find.text('42'));
      expect(textWidget.style?.fontSize, greaterThan(40));
    });
    
    testWidgets('Page has card containing streak information', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: 10),
        ),
      );
      
      // Check card is present
      expect(find.byType(Card), findsOneWidget);
      
      // Verify card contains the streak content
      final cardFinder = find.byType(Card);
      expect(find.descendant(of: cardFinder, matching: find.text('10')), findsOneWidget);
    });
    
    testWidgets('Page has continue button with correct style', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: 10),
        ),
      );
      
      // Button exists with text 'Continue'
      expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
      
      // Button has the correct style (we can check some properties)
      final buttonFinder = find.byType(ElevatedButton);
      final button = tester.widget<ElevatedButton>(buttonFinder);
      
      // Check the button's style is not null
      expect(button.style, isNotNull);
    });
  });
  
  // Group 2: Test streak messages for different streak levels
  group('Streak Message Tests', () {
    testWidgets('Regular streak (< 7 days) shows correct message', (WidgetTester tester) async {
      const testStreak = 3;
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: testStreak),
        ),
      );
      
      expect(find.text('3 Day Streak! 👏'), findsOneWidget);
      expect(find.text('Keep up the good habit today!'), findsOneWidget);
    });
    
    testWidgets('Weekly streak (7-29 days) shows correct message', (WidgetTester tester) async {
      const testStreak = 14;
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: testStreak),
        ),
      );
      
      expect(find.text('7+ Day Streak! 🔥'), findsOneWidget);
      expect(find.text('You have maintained a 14 day streak! Keep going!'), findsOneWidget);
    });
    
    testWidgets('Monthly streak (30-99 days) shows correct message', (WidgetTester tester) async {
      const testStreak = 45;
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: testStreak),
        ),
      );
      
      expect(find.text('30+ Day Streak! 🌟'), findsOneWidget);
      expect(find.text('Amazing! You have been consistent for 45 days!'), findsOneWidget);
    });
    
    testWidgets('Century streak (100+ days) shows correct message', (WidgetTester tester) async {
      const testStreak = 120;
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: testStreak),
        ),
      );
      
      expect(find.text('WOW! 100+ Day Streak! 🏆'), findsOneWidget);
      expect(find.text('Spectacular achievement! 120 consecutive days!'), findsOneWidget);
    });
    
    testWidgets('Edge case: zero streak shows regular message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: 0),
        ),
      );
      
      expect(find.text('0 Day Streak! 👏'), findsOneWidget);
    });
  });
  
  // Group 3: Test Animations
  group('Animation Tests', () {
    testWidgets('Lottie animation is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: 10),
        ),
      );
      
      // Check if Lottie widget is present
      expect(find.byType(Lottie), findsOneWidget);
    });
    

  });
  
  // Group 4: Test Navigation
  group('Navigation Tests', () {
    testWidgets('Button exists in the UI', (WidgetTester tester) async {
      // RED phase - mencari tombol yang seharusnya ada
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: 10),
        ),
      );
      
      // Memastikan animasi dan semua widget selesai dirender
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // GREEN phase - verifikasi button ada
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // REFACTOR phase - gunakan pendekatan yang lebih robust
      final buttonWidget = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttonWidget.onPressed, isNotNull);
    });
  });
  
  // Group 5: Edge Cases and Error Handling
  group('Edge Cases and Error Handling', () {
    testWidgets('Very large streak number still displays correctly', (WidgetTester tester) async {
      const largeStreak = 9999;
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: largeStreak),
        ),
      );
      
      expect(find.text('9999'), findsOneWidget);
      expect(find.text('WOW! 100+ Day Streak! 🏆'), findsOneWidget);
    });
    
    testWidgets('Streak is rendered correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StreakCelebrationPage(streak: 10),
        ),
      );
      
      // Elements should be visible
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Streak Achievement'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
  });
}
