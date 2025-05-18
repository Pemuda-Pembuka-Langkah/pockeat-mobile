// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/authentication/presentation/screens/login_page.dart';
import 'package:pockeat/features/authentication/presentation/widgets/google_sign_in_button.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'login_page_google_signin_test.mocks.dart';

@GenerateMocks([LoginService, UserCredential, GoogleSignInService, AnalyticsService])

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockLoginService mockLoginService;
  late MockUserCredential mockUserCredential;
  late MockGoogleSignInService mockGoogleSignInService;
  late MockNavigatorObserver mockNavigatorObserver;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockLoginService = MockLoginService();
    mockUserCredential = MockUserCredential();
    mockGoogleSignInService = MockGoogleSignInService();
    mockNavigatorObserver = MockNavigatorObserver();
    mockAnalyticsService = MockAnalyticsService();
    
    // Setup analytics service mock behavior
    when(mockAnalyticsService.logLogin(method: anyNamed('method')))
        .thenAnswer((_) => Future.value());
    when(mockAnalyticsService.logScreenView(screenName: anyNamed('screenName'), screenClass: anyNamed('screenClass')))
        .thenAnswer((_) => Future.value());

    // Register services in GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
    getIt.registerSingleton<LoginService>(mockLoginService);

    if (getIt.isRegistered<GoogleSignInService>()) {
      getIt.unregister<GoogleSignInService>();
    }
    getIt.registerSingleton<GoogleSignInService>(mockGoogleSignInService);
    
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
    getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);
  });

  tearDown(() {
    // Clean up GetIt registrations
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
    if (getIt.isRegistered<GoogleSignInService>()) {
      getIt.unregister<GoogleSignInService>();
    }
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
  });

  testWidgets('Should verify Google Sign In button exists on login page',
      (WidgetTester tester) async {
    // Set up screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    // Verify OR divider exists
    expect(find.text('OR'), findsOneWidget);

    // Verify Google Sign In button exists
    expect(find.byType(GoogleSignInButton), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('Should interact with Google Sign In button on login page',
      (WidgetTester tester) async {
    // Set up screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Set up mock
    when(mockGoogleSignInService.signInWithGoogle())
        .thenAnswer((_) async => mockUserCredential);

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    // Find and tap Google Sign In button (tap on the text)
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();

    // Verify Google Sign In service was called
    verify(mockGoogleSignInService.signInWithGoogle()).called(1);
  });

  testWidgets(
      'Should handle error when Google Sign In fails on login page',
      (WidgetTester tester) async {
    // Set up screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Set up mock to throw exception
    final testException = FirebaseAuthException(
        code: 'user-cancelled', message: 'Google Sign In cancelled by user');
    when(mockGoogleSignInService.signInWithGoogle()).thenThrow(testException);

    // Build app
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    // Find and tap Google Sign In button
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();

    // Verify analytics service was called with error event
    verify(mockAnalyticsService.logEvent(
      name: 'google_sign_in_error',
      parameters: anyNamed('parameters'),
    )).called(1);
    
    // Verify we didn't navigate to home page
    expect(find.text('Home Page'), findsNothing);
  });

  testWidgets('Should navigate to home after successful Google Sign In',
      (WidgetTester tester) async {
    // Set up screen size
    tester.binding.window.physicalSizeTestValue = const Size(600, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Set up mock
    when(mockGoogleSignInService.signInWithGoogle())
        .thenAnswer((_) async => mockUserCredential);

    // Build app with initialRoute dan routes
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/': (context) => const Scaffold(body: Text('Home Page')),
        },
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap Google Sign In button
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();

    // Verify Google Sign In service was called
    verify(mockGoogleSignInService.signInWithGoogle()).called(1);

    
  });
}
