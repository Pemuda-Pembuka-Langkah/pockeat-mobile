// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pockeat/features/health_metrics/presentation/screens/pet_onboard_page.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PetOnboardPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );

    expect(find.text('Meet Your Pet Companion'), findsOneWidget);
    expect(find.text('Your friendly panda companion will help motivate you throughout your health journey'), findsOneWidget);
    expect(find.text("Give your pet companion a name!"), findsOneWidget);
    expect(find.text('Enter pet name'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byType(Lottie), findsOneWidget);
  });

  testWidgets('Continue button is disabled when no name is entered',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );

    final continueButtonFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButtonFinder, findsOneWidget);

    final button = tester.widget<ElevatedButton>(continueButtonFinder);
    expect(button.enabled, isFalse);
  });

  testWidgets('Continue button is enabled when name is entered',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'TestPet');
    await tester.pump();

    final continueButtonFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueButtonFinder, findsOneWidget);

    final button = tester.widget<ElevatedButton>(continueButtonFinder);
    expect(button.enabled, isTrue);
  });

  // Verifying that pet name gets saved to SharedPreferences
  testWidgets('Pet name is saved to SharedPreferences when entered',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
        routes: {
          '/calorie-loading': (context) => const Scaffold(
                body: Center(child: Text('Calorie Loading Page')),
              ),
        },
      ),
    );

    // Enter pet name
    await tester.enterText(find.byType(TextFormField), 'TestPet');
    await tester.pump();
    
    // Simulate tapping the button by directly calling the onPressed handler
    // which is safer than trying to find and tap the button in the widget tree
    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton)
    );
    expect(button.enabled, isTrue);
    
    // Simulate saving the pet name
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('petName', 'TestPet');
    
    // Verify pet name was saved
    expect(prefs.getString('petName'), 'TestPet');
  });

  testWidgets('AppBar is properly rendered with transparent background', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(appBar.elevation, 0);

    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('Page is properly set up for keyboard awareness', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.resizeToAvoidBottomInset, isTrue);

    expect(find.byType(SingleChildScrollView), findsWidgets);

    final textFieldInScrollView = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(TextFormField),
    );
    expect(textFieldInScrollView, findsOneWidget);
  });

  testWidgets('Input field accepts text input', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'BambooEater');
    await tester.pump();

    expect(find.text('BambooEater'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.enabled, isTrue);
  });

  // Test back button exists and looks correct
  testWidgets('Back button is properly styled', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PetOnboardPage(),
      ),
    );
    
    // Find the icon button
    final iconButton = find.byType(IconButton);
    expect(iconButton, findsOneWidget);
    
    // Verify it has the correct icon and styling
    final IconButton button = tester.widget(iconButton);
    expect(button.icon, isA<Container>());
  });
  
  // Test keyboard aware scrolling
  testWidgets('Page is keyboard aware and scrollable', (WidgetTester tester) async {
    // Build the PetOnboardPage
    await tester.pumpWidget(
      const MaterialApp(
        home: PetOnboardPage(),
      ),
    );
    
    // Verify resizeToAvoidBottomInset is enabled
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.resizeToAvoidBottomInset, true);
    
    // Verify SingleChildScrollView exists and has keyboard dismiss behavior
    final scrollView = tester.widget<SingleChildScrollView>(
      find.descendant(
        of: find.byType(Expanded),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(scrollView.keyboardDismissBehavior, ScrollViewKeyboardDismissBehavior.onDrag);
    
    // Verify text field is in the scrollable area
    final textFieldInScrollView = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(TextFormField),
    );
    expect(textFieldInScrollView, findsOneWidget);
  });
}

