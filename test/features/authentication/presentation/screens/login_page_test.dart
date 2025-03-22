import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/presentation/screens/login_page.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

@GenerateMocks([LoginService, UserCredential])
import 'login_page_test.mocks.dart';

void main() {
  late MockLoginService mockLoginService;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockLoginService = MockLoginService();
    mockUserCredential = MockUserCredential();

    // Register mockLoginService in GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
    getIt.registerSingleton<LoginService>(mockLoginService);
  });

  tearDown(() {
    // Clean up GetIt registrations
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
  });

  testWidgets('Should render login form correctly',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Verify UI components
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(
        find.text('Sign in to continue your health journey'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);

    // Find text with RichText widget since it's not directly accessible with find.text
    expect(
      find.byWidgetPredicate((widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('Don\'t have an account?')),
      findsOneWidget,
    );

    expect(
      find.byWidgetPredicate((widget) =>
          widget is RichText && widget.text.toPlainText().contains('Sign Up')),
      findsOneWidget,
    );
  });

  testWidgets('Should validate form correctly', (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Try to submit empty form
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    // Verify validation errors
    expect(find.text('Email cannot be empty'), findsOneWidget);
    expect(find.text('Password cannot be empty'), findsOneWidget);
  });

  testWidgets('Should validate email format', (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Enter invalid email
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    // Verify validation error
    expect(find.text('Invalid email format'), findsOneWidget);
  });

  testWidgets('Should login successfully with valid credentials',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Setup mock
    when(mockLoginService.loginByEmail(
      email: 'test@example.com',
      password: 'Password123',
    )).thenAnswer((_) async => mockUserCredential);

    // Build app with mock navigator observer to track navigation
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginPage(),
        navigatorObservers: [mockObserver],
        routes: {
          '/home': (context) => const Scaffold(body: Text('Home Page')),
        },
      ),
    );

    // Fill form with valid data
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');

    // Submit form
    await tester.tap(find.text('SIGN IN'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(seconds: 2)); // Finish loading

    // Verify login service was called
    verify(mockLoginService.loginByEmail(
      email: 'test@example.com',
      password: 'Password123',
    )).called(1);
  });

  testWidgets('Should show error message on login failure',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Setup mock to throw exception
    when(mockLoginService.loginByEmail(
      email: 'test@example.com',
      password: 'WrongPassword',
    )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Fill form with data that will cause an error
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'WrongPassword');

    // Submit form
    await tester.tap(find.text('SIGN IN'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(seconds: 2)); // Finish loading

    // Verify error message is shown
    expect(find.text('Incorrect password. Please try again.'), findsOneWidget);
  });

  testWidgets('Should toggle password visibility', (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Enter some text in the password field to make it easier to find
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'test123');
    await tester.pump();

    // Find the visibility toggle button inside the password field
    final visibilityToggle = find.byIcon(Icons.visibility);
    expect(visibilityToggle, findsOneWidget);

    // Get TextField before toggle
    final passwordField = find.widgetWithText(TextField, 'test123');
    final isInitiallyObscured =
        tester.widget<TextField>(passwordField).obscureText;
    expect(isInitiallyObscured, isTrue); // Password should be hidden initially

    // Tap the visibility toggle
    await tester.tap(visibilityToggle);
    await tester.pump();

    // Check if password visibility changed
    final passwordFieldAfterToggle = find.widgetWithText(TextField, 'test123');
    final isObscuredAfterToggle =
        tester.widget<TextField>(passwordFieldAfterToggle).obscureText;
    expect(isObscuredAfterToggle, isFalse); // Password should be visible now
  });

  testWidgets('Should attempt to navigate to registration page',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app with mock navigator observer to track navigation
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginPage(),
        navigatorObservers: [mockObserver],
        routes: {
          '/register': (context) => const Scaffold(body: Text('Register Page')),
        },
      ),
    );

    // Find sign up text in RichText
    final signUpFinder = find.byWidgetPredicate((widget) =>
        widget is RichText && widget.text.toPlainText().contains('Sign Up'));
    expect(signUpFinder, findsOneWidget);

    // Tap on the RichText containing "Sign Up"
    await tester.tap(signUpFinder);
    await tester.pumpAndSettle();
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
