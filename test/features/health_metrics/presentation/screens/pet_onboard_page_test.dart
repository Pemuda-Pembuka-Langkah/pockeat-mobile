// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/presentation/screens/pet_onboard_page.dart';

// Mock Navigator Observer for testing navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PetOnboardPage renders correctly', (WidgetTester tester) async {
    // Build the PetOnboardPage
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
        routes: {
          '/review': (context) => const Scaffold(
                body: Center(child: Text('Review Page')),
              ),
        },
      ),
    );

    // Initial rendering verification
    // Verify page title and description
    expect(find.text('Meet Your Pet Companion'), findsOneWidget);
    expect(find.text('Your friendly panda companion will help motivate you throughout your health journey'), findsOneWidget);
    
    // Verify text for pet name
    expect(find.text("Give your pet companion a name!"), findsOneWidget);
    
    // Verify input field hint
    expect(find.text('Enter pet name'), findsOneWidget);
    
    // Verify button text
    expect(find.text('Continue'), findsOneWidget);
    
    // Verify Lottie animation widget
    expect(find.byType(Lottie), findsOneWidget);
    
    // Verify container with green background
    final containerFinder = find.descendant(
      of: find.byType(Container),
      matching: find.byWidgetPredicate((widget) => 
        widget is Container && 
        widget.decoration is BoxDecoration && 
        (widget.decoration as BoxDecoration).color != null
      ),
    );
    expect(containerFinder, findsWidgets); // Should find at least one
  });

  testWidgets('Continue button is disabled when no name is entered',
      (WidgetTester tester) async {
    // Build the PetOnboardPage
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
        routes: {
          '/review': (context) => const Scaffold(
                body: Center(child: Text('Review Page')),
              ),
        },
      ),
    );

    // Find the continue button
    final continueButtonFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButtonFinder, findsOneWidget);

    // Check if button is disabled initially
    final button = tester.widget<ElevatedButton>(continueButtonFinder);
    expect(button.enabled, isFalse);
  });

  testWidgets('Continue button is enabled when name is entered',
      (WidgetTester tester) async {
    // Build the PetOnboardPage
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
        routes: {
          '/review': (context) => const Scaffold(
                body: Center(child: Text('Review Page')),
              ),
        },
      ),
    );

    // Enter a name
    await tester.enterText(find.byType(TextFormField), 'TestPet');
    await tester.pump();

    // Find the continue button
    final continueButtonFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButtonFinder, findsOneWidget);

    // Check if button is enabled after text input
    final button = tester.widget<ElevatedButton>(continueButtonFinder);
    expect(button.enabled, isTrue);
  });

  testWidgets('Continue button navigates to review page and saves pet name',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    // Build the PetOnboardPage
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
        routes: {
          '/review': (context) => const Scaffold(
                body: Center(child: Text('Review Page')),
              ),
        },
      ),
    );

    // Enter a name
    await tester.enterText(find.byType(TextFormField), 'TestPet');
    await tester.pump();

    // Tap the continue button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // Check if navigated to review page
    expect(find.text('Review Page'), findsOneWidget);

    // Verify preference was saved
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('petName'), 'TestPet');
  });

  // Testing AppBar existence and styling
  testWidgets('AppBar is properly rendered with transparent background', (WidgetTester tester) async {
    // Build the PetOnboardPage
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );
    
    // Verify AppBar exists and has correct properties
    expect(find.byType(AppBar), findsOneWidget);
    
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(appBar.elevation, 0);
    
    // Verify back button exists in AppBar
    expect(find.byType(IconButton), findsOneWidget);
  });
  
  // Test entering text in the input field
  testWidgets('Input field accepts text input', (WidgetTester tester) async {
    // Build the PetOnboardPage
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );
    
    // Get text field and enter text
    final textFieldFinder = find.byType(TextFormField);
    await tester.enterText(textFieldFinder, 'BambooEater');
    await tester.pump();
    
    // Verify text was entered
    expect(find.text('BambooEater'), findsOneWidget);
    
    // Verify button is now enabled after entering text
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.enabled, isTrue);
  });
  
  // Test animation related widgets
  testWidgets('Animation related widgets are present', (WidgetTester tester) async {
    // Build the PetOnboardPage
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );
    
    // Verify that animation related widgets exist
    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(ScaleTransition), findsWidgets);
    
    // Verify main content container exists
    expect(
      find.descendant(
        of: find.byType(Container),
        matching: find.byWidgetPredicate((widget) => 
          widget is Container && 
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.white
        )
      ),
      findsWidgets
    );
  });
}
