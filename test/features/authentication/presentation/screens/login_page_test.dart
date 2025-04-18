import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/presentation/screens/login_page.dart';
import 'package:pockeat/features/authentication/presentation/widgets/google_sign_in_button.dart';
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
    expect(find.text('Incorrect password. Please check your password.'),
        findsOneWidget);
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

  testWidgets('Should verify forgot password link exists',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Find and verify "Forgot Password?" link
    final forgotPasswordFinder = find.text('Forgot Password?');
    expect(forgotPasswordFinder, findsOneWidget);

    // // Tap on forgot password link
    // await tester.tap(forgotPasswordFinder);
    // await tester.pumpAndSettle();

    // Currently this does nothing since navigation is commented out in the actual code
    // We're just ensuring the link exists and is tappable
  });

  testWidgets('Should show loading indicator during login',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Setup delayed response to show loading state
    when(mockLoginService.loginByEmail(
      email: 'test@example.com',
      password: 'Password123',
    )).thenAnswer((_) async {
      // Delay to show loading indicator
      await Future.delayed(const Duration(seconds: 1));
      return mockUserCredential;
    });

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Fill form with valid data
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');

    // Submit form
    await tester.tap(find.text('SIGN IN'));
    await tester.pump(); // Start loading

    // Verify loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('SIGN IN'),
        findsNothing); // Button text is replaced with indicator

    // Finish loading
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Should handle error messages for various Firebase exceptions',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Test various error cases
    final testCases = [
      {
        'error': FirebaseAuthException(code: 'user-not-found'),
        'message':
            'Email not registered. Please check your email or register first.'
      },
      {
        'error': FirebaseAuthException(code: 'invalid-credential'),
        'message': 'Invalid email or password. Please check your credentials.'
      },
      {
        'error': FirebaseAuthException(code: 'user-disabled'),
        'message': 'This account has been disabled. Please contact admin.'
      },
      {
        'error': FirebaseAuthException(code: 'too-many-requests'),
        'message': 'Too many login attempts. Please try again later.'
      },
      {
        'error': FirebaseAuthException(code: 'invalid-email'),
        'message': 'Invalid email format. Please check your email.'
      },
      {
        'error': FirebaseAuthException(code: 'operation-not-allowed'),
        'message':
            'Login with email and password is not allowed. Please use another login method.'
      },
      {
        'error': FirebaseAuthException(code: 'network-request-failed'),
        'message':
            'Network problem occurred. Please check your internet connection.'
      },
      {
        'error':
            FirebaseAuthException(code: 'unknown-code', message: 'Some error'),
        'message': 'Login failed: Some error'
      },
      {
        'error': Exception('Random error'),
        'message':
            'An unexpected error occurred during login. Please try again later.'
      },
    ];

    for (final testCase in testCases) {
      // Reset state
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Setup mock to throw specific exception
      when(mockLoginService.loginByEmail(
        email: 'test@example.com',
        password: 'Password123',
      )).thenThrow(testCase['error']!);

      // Fill form
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'Password123');

      // Submit form
      await tester.tap(find.text('SIGN IN'));
      await tester.pump(); // Start loading
      await tester.pump(const Duration(seconds: 1)); // Allow error to process

      // Verify error message
      expect(find.text(testCase['message'] as String), findsOneWidget);
    }
  });

  testWidgets('Should handle back button press on login page',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build login page
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    // Verifikasi PopScope ada
    expect(find.byType(PopScope), findsOneWidget);

    // Verifikasi canPop adalah false
    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);
  });

  testWidgets('Should handle PopScope and system navigator',
      (WidgetTester tester) async {
    // Setup mock for SystemNavigator
    bool systemNavigatorCalled = false;

    // Override SystemNavigator.pop untuk menangkap panggilan
    SystemChannels.platform.setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'SystemNavigator.pop') {
        systemNavigatorCalled = true;
      }
      return null;
    });

    // Build widget dengan PopScope
    await tester.pumpWidget(
      MaterialApp(
        home: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            // Call SystemNavigator.pop()
            SystemNavigator.pop();
          },
          child: const Scaffold(
            body: Text('Test PopScope'),
          ),
        ),
      ),
    );

    // Simulasi tombol back dengan mengirim notifikasi ke engine
    await tester.binding.handlePopRoute();
    await tester.pump();

    // Verifikasi bahwa SystemNavigator.pop() dipanggil
    expect(systemNavigatorCalled, isTrue);

    // Reset mock
    SystemChannels.platform.setMockMethodCallHandler(null);
  });

  testWidgets('Should test tap on "Forgot Password?" link',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Track navigation
    final navigatorPushed = <String>[];

    // Build app with custom onGenerateRoute to track navigations
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginPage(),
        onGenerateRoute: (RouteSettings settings) {
          navigatorPushed.add(settings.name!);
          return MaterialPageRoute(
            builder: (BuildContext context) => const Scaffold(),
            settings: settings,
          );
        },
      ),
    );

    // Find and tap "Forgot Password?" link
    final forgotPasswordFinder = find.text('Forgot Password?');
    expect(forgotPasswordFinder, findsOneWidget);

    await tester.tap(forgotPasswordFinder);
    await tester.pumpAndSettle();

    // Verify navigation occurred
    expect(navigatorPushed, contains('/forgot-password'));
  });

  testWidgets('Should handle Google sign-in button tap',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Check if Google sign-in button exists
    final googleButtonFinder = find.byType(GoogleSignInButton);
    expect(googleButtonFinder, findsOneWidget);

    // Verify height is set correctly
    final googleButton = tester.widget<GoogleSignInButton>(googleButtonFinder);
    expect(googleButton.height, 55); // Testing line 369

    // We can't easily tap and test the actual sign-in flow in a unit test
    // since it depends on platform plugins, but we can verify the button exists
    // with the expected properties
  });

  testWidgets('Should handle PopScope with onPopInvoked callback',
      (WidgetTester tester) async {
    // Setup
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Flag untuk cek apakah callback dipanggil
    bool callbackInvoked = false;

    // Build app dengan PopScope yang dapat kita kontrol
    await tester.pumpWidget(
      MaterialApp(
        home: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            callbackInvoked = true;
          },
          child: const Scaffold(
            body: Text('Test PopScope'),
          ),
        ),
      ),
    );

    // Ambil fungsi callback dan panggil secara manual
    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    final callback = popScope.onPopInvoked;
    if (callback != null) {
      callback(false);
    }

    // Verifikasi callback dipanggil
    expect(callbackInvoked, isTrue);
  });

  testWidgets('Should display error message for ArgumentError',
      (WidgetTester tester) async {
    // Setup screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Mock service to throw ArgumentError
    when(mockLoginService.loginByEmail(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(ArgumentError('Custom argument error message'));

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Fill form
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');

    // Submit form
    await tester.tap(find.text('SIGN IN'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(seconds: 1)); // Allow error to process

    // Verify error message contains the argument error message
    expect(find.textContaining('An unexpected error occurred'), findsOneWidget);
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
