import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/presentation/screens/login_page.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:pockeat/features/authentication/presentation/widgets/google_sign_in_button.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';

@GenerateMocks([LoginService, UserCredential, GoogleSignInService])
import 'login_page_google_signin_test.mocks.dart';

void main() {
  late MockLoginService mockLoginService;
  late MockUserCredential mockUserCredential;
  late MockGoogleSignInService mockGoogleSignInService;

  setUp(() {
    mockLoginService = MockLoginService();
    mockUserCredential = MockUserCredential();
    mockGoogleSignInService = MockGoogleSignInService();

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
      'Should show error snackbar when Google Sign In fails on login page',
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

    // Verify error snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Error:'), findsOneWidget);
  });
}
