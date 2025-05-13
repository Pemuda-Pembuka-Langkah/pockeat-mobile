// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/authentication/presentation/screens/welcome_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock for SystemNavigator
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    return null;
  });

  group('WelcomePage', () {
    testWidgets('renders taglines and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Check for RichText widgets that contain the taglines
      expect(find.byType(RichText), findsAtLeastNWidgets(2));
      
      // Verify the specific TextSpan content using predicates
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is RichText) {
            final span = widget.text as TextSpan;
            return span.children?.any((element) => 
              element is TextSpan && element.text == 'Matters') ?? false;
          }
          return false;
        }),
        findsOneWidget,
        reason: 'Should find RichText with "Matters" TextSpan',
      );
      
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is RichText) {
            final span = widget.text as TextSpan;
            return span.children?.any((element) => 
              element is TextSpan && element.text == 'Counts') ?? false;
          }
          return false;
        }),
        findsOneWidget,
        reason: 'Should find RichText with "Counts" TextSpan',
      );
      
      // Check subtitle
      expect(
        find.text('AI-Driven Smart Companion for Seamless Calorie & Health Tracking'),
        findsOneWidget,
      );
    });

    testWidgets('shows feature cards and page indicators', (WidgetTester tester) async {
      // Set up a larger size to avoid overflow issues
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Check for at least one feature card structure
      expect(find.byType(PageView), findsOneWidget);
      
      // Check that there are container widgets for the card design
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      
      // Check for page indicators
      expect(find.byType(AnimatedContainer), findsAtLeastNWidgets(1));
      
      // Reset the test window size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('shows Get Started button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Check for main CTA button
      expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);
    });
    
    // Helper function to extract all text from a TextSpan hierarchy
    String extractTextFromSpan(TextSpan span) {
      String text = span.text ?? '';
      if (span.children != null) {
        for (var child in span.children!) {
          if (child is TextSpan) {
            text += extractTextFromSpan(child);
          }
        }
      }
      return text;
    }

    testWidgets('shows login text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Check for TextButton
      expect(find.byType(TextButton), findsOneWidget);
      
      // Check for RichText component that might contain login related text
      final loginRelatedText = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final span = widget.text as TextSpan;
          final allText = extractTextFromSpan(span);
          return allText.contains('account') || allText.contains('Log in');
        }
        return false;
      });
      
      expect(loginRelatedText, findsOneWidget);
    });

    testWidgets('has PopScope to handle back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Just verify the PopScope widget is present to handle back navigation
      expect(find.byType(PopScope), findsOneWidget);
    });

    testWidgets('has login button that triggers navigation', (WidgetTester tester) async {
      bool navigatedToLogin = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const WelcomePage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/login') {
              navigatedToLogin = true;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Login Page')),
              );
            }
            return null;
          },
        ),
      );

      // Just find and tap the TextButton which should handle login
      final buttonFinder = find.byType(TextButton);
      expect(buttonFinder, findsOneWidget);
      
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(navigatedToLogin, isTrue, reason: 'Should navigate to login page');
    });

    testWidgets('navigates to onboarding when Get Started is tapped', (WidgetTester tester) async {
      bool navigatedToOnboarding = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const WelcomePage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/onboarding') {
              navigatedToOnboarding = true;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Onboarding')),
              );
            }
            return null;
          },
        ),
      );

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(navigatedToOnboarding, isTrue);
    });


    testWidgets('has components for auto-scrolling feature cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Check that PageView exists for the feature cards
      expect(find.byType(PageView), findsOneWidget);
      
      // Verify that page indicators exist for the auto-scroll functionality
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      expect(find.byType(AnimatedContainer), findsAtLeastNWidgets(1));
    });

    testWidgets('contains decorative visual elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Verify the existence of Stack widget which contains visual elements
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      
      // Verify containers exist (likely decorative elements)
      expect(find.byType(Container), findsAtLeastNWidgets(1)); 
      
      // Verify some decorative elements with circular shape
      final decorativeElements = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration != null) {
          final decoration = widget.decoration as BoxDecoration?;
          return decoration?.shape == BoxShape.circle;
        }
        return false;
      });
      
      expect(decorativeElements, findsAtLeastNWidgets(1));
    });
  });
}


