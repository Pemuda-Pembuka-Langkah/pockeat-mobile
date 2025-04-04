import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/presentation/widgets/google_sign_in_button.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';

@GenerateMocks([GoogleSignInService, UserCredential])
import 'google_sign_in_button_test.mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockGoogleSignInService mockGoogleSignInService;
  late MockUserCredential mockUserCredential;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockGoogleSignInService = MockGoogleSignInService();
    mockUserCredential = MockUserCredential();
    mockNavigatorObserver = MockNavigatorObserver();

    // Reset GetIt before registering to ensure clean environment
    GetIt.I.reset();
    GetIt.I.registerSingleton<GoogleSignInService>(mockGoogleSignInService);
  });

  testWidgets('renders correctly with Google text',
      (WidgetTester tester) async {
    // Build our widget dengan isUnderTest = true
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: Center(
            child: GoogleSignInButton(isUnderTest: true),
          ),
        ),
      ),
    );

    // Tunggu widget selesai build
    await tester.pumpAndSettle();

    // Verifikasi text dan gambar dummy
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('G'), findsOneWidget);

    // Test text styling
    final text = tester.widget<Text>(find.text('Sign in with Google'));
    expect(text.style?.fontSize, 16);
    expect(text.style?.fontWeight, FontWeight.w500);
  });

  testWidgets('calls signInWithGoogle when pressed',
      (WidgetTester tester) async {
    // Set up mock to return UserCredential
    when(mockGoogleSignInService.signInWithGoogle())
        .thenAnswer((_) async => mockUserCredential);

    // Build our widget dengan isUnderTest = true dan Scaffold,
    // langsung menyediakan service
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GoogleSignInButton(
              isUnderTest: true,
              googleAuthService: mockGoogleSignInService,
            ),
          ),
        ),
      ),
    );

    // Tunggu widget selesai build
    await tester.pumpAndSettle();

    // Tap button yang mengandung teks "Sign in with Google"
    final textButtonFinder = find.text('Sign in with Google');
    expect(textButtonFinder, findsOneWidget);
    await tester.tap(textButtonFinder);

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify the method was called
    verify(mockGoogleSignInService.signInWithGoogle()).called(1);
  });

  testWidgets('shows error snackbar when sign in fails',
      (WidgetTester tester) async {
    // Set up mock to throw exception
    final testException = Exception('Sign in failed');
    when(mockGoogleSignInService.signInWithGoogle()).thenThrow(testException);

    // Build our widget dengan isUnderTest = true dan langsung menyediakan service
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GoogleSignInButton(
              isUnderTest: true,
              googleAuthService: mockGoogleSignInService,
            ),
          ),
        ),
      ),
    );

    // Tunggu widget selesai build
    await tester.pumpAndSettle();

    // Tap button yang mengandung teks "Sign in with Google"
    final textButtonFinder = find.text('Sign in with Google');
    expect(textButtonFinder, findsOneWidget);
    await tester.tap(textButtonFinder);

    // Wait for async operations and animations to complete
    await tester.pumpAndSettle();

    // Verify error snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Error:'), findsOneWidget);

    // Verify snackbar styling
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, Colors.red);
  });

  testWidgets('navigates to home page after successful sign in',
      (WidgetTester tester) async {
    // Set up mock to return UserCredential
    when(mockGoogleSignInService.signInWithGoogle())
        .thenAnswer((_) async => mockUserCredential);

    // Build our widget dengan isUnderTest = true, scaffold dan routes
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/button-test',
        routes: {
          '/button-test': (context) => Scaffold(
                body: Center(
                  child: GoogleSignInButton(
                    isUnderTest: true,
                    googleAuthService: mockGoogleSignInService,
                  ),
                ),
              ),
          '/': (context) => const Scaffold(body: Text('Home Page')),
        },
      ),
    );

    // Tunggu widget selesai build
    await tester.pumpAndSettle();

    // Tap button yang mengandung teks "Sign in with Google"
    final textButtonFinder = find.text('Sign in with Google');
    expect(textButtonFinder, findsOneWidget);
    await tester.tap(textButtonFinder);

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify the method was called
    verify(mockGoogleSignInService.signInWithGoogle()).called(1);

    // Verify we're on the Home Page after navigation
    expect(find.text('Home Page'), findsOneWidget);
  });
}
