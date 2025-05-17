// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/authentication/presentation/widgets/google_sign_in_button.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';
import 'google_sign_in_button_test.mocks.dart';

@GenerateMocks([
  GoogleSignInService,
  UserCredential,
  AnalyticsService,
  User,
  HealthMetricsFormCubit,
  UserPreferencesService
])
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockGoogleSignInService mockGoogleSignInService;
  late MockUserCredential mockUserCredential;
  late MockNavigatorObserver mockNavigatorObserver;
  late MockAnalyticsService mockAnalyticsService;
  late MockUser mockUser;
  late MockHealthMetricsFormCubit mockHealthMetricsFormCubit;
  late MockUserPreferencesService mockUserPreferencesService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockGoogleSignInService = MockGoogleSignInService();
    mockUserCredential = MockUserCredential();
    mockNavigatorObserver = MockNavigatorObserver();
    mockAnalyticsService = MockAnalyticsService();
    mockUser = MockUser();
    mockHealthMetricsFormCubit = MockHealthMetricsFormCubit();
    mockUserPreferencesService = MockUserPreferencesService();

    // Set up mock user
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUserCredential.user).thenReturn(mockUser);

    // Set up cubit
    when(mockHealthMetricsFormCubit.setUserId(any)).thenReturn(null);
    when(mockHealthMetricsFormCubit.submit()).thenAnswer((_) async {});

    // Set up UserPreferencesService
    when(mockUserPreferencesService.synchronizePreferencesAfterLogin())
        .thenAnswer((_) async {});

    // Reset GetIt before registering to ensure clean environment
    GetIt.I.reset();
    GetIt.I.registerSingleton<GoogleSignInService>(mockGoogleSignInService);
    GetIt.I.registerSingleton<AnalyticsService>(mockAnalyticsService);
    GetIt.I
        .registerSingleton<UserPreferencesService>(mockUserPreferencesService);
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

  testWidgets('calls signInWithGoogle and logs analytics when pressed',
      (WidgetTester tester) async {
    // Set up mock to return UserCredential
    when(mockGoogleSignInService.signInWithGoogle())
        .thenAnswer((_) async => mockUserCredential);
    when(mockAnalyticsService.logEvent(
            name: anyNamed('name'), parameters: anyNamed('parameters')))
        .thenAnswer((_) async {});

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

    // Verify the methods were called
    verify(mockGoogleSignInService.signInWithGoogle()).called(1);

    // Verify analytics events were logged
    verify(mockAnalyticsService.logEvent(
            name: 'google_sign_in_attempt', parameters: null))
        .called(1);
    verify(mockAnalyticsService.logEvent(
        name: 'google_sign_in_success',
        parameters: {'uid': 'test-uid'})).called(1);

    // Verify UserPreferencesService method was called
    verify(mockUserPreferencesService.synchronizePreferencesAfterLogin())
        .called(1);
  });

  testWidgets('shows error snackbar when sign in fails',
      (WidgetTester tester) async {
    // Set up mock to throw exception
    final testException = Exception('Sign in failed');
    when(mockGoogleSignInService.signInWithGoogle()).thenThrow(testException);
    when(mockAnalyticsService.logEvent(
            name: anyNamed('name'), parameters: anyNamed('parameters')))
        .thenAnswer((_) async {});

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

    // Verify analytics attempt event was logged
    verify(mockAnalyticsService.logEvent(
            name: 'google_sign_in_attempt', parameters: null))
        .called(1);

    // Verify error snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Error:'), findsOneWidget);

    // Verify snackbar styling
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, Colors.red);

    // Verify success event was not logged
    verifyNever(mockAnalyticsService.logEvent(
        name: 'google_sign_in_success', parameters: anyNamed('parameters')));
  });

  testWidgets('navigates to home page after successful sign in',
      (WidgetTester tester) async {
    // Set up mock to return UserCredential
    when(mockGoogleSignInService.signInWithGoogle())
        .thenAnswer((_) async => mockUserCredential);
    when(mockAnalyticsService.logEvent(
            name: anyNamed('name'), parameters: anyNamed('parameters')))
        .thenAnswer((_) async {});

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

    // Verify analytics events were logged
    verify(mockAnalyticsService.logEvent(
            name: 'google_sign_in_attempt', parameters: null))
        .called(1);
    verify(mockAnalyticsService.logEvent(
        name: 'google_sign_in_success',
        parameters: {'uid': 'test-uid'})).called(1);

    // Verify UserPreferencesService method was called
    verify(mockUserPreferencesService.synchronizePreferencesAfterLogin())
        .called(1);

    // Verify we're on the Home Page after navigation
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets(
      'renders register button with correct text when isRegister is true',
      (WidgetTester tester) async {
    // Build our widget dengan isUnderTest = true dan isRegister = true
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: Center(
            child: GoogleSignInButton(isUnderTest: true, isRegister: true),
          ),
        ),
      ),
    );

    // Tunggu widget selesai build
    await tester.pumpAndSettle();

    // Verifikasi text
    expect(find.text('Register with Google'), findsOneWidget);
    expect(find.text('G'), findsOneWidget);
  });
  testWidgets('logs analytics events for registration with form submission',
      (WidgetTester tester) async {
    // Set up mock to return UserCredential
    when(mockGoogleSignInService.signInWithGoogle())
        .thenAnswer((_) async => mockUserCredential);
    when(mockAnalyticsService.logEvent(
            name: anyNamed('name'), parameters: anyNamed('parameters')))
        .thenAnswer((_) async {});

    // Set up mockHealthMetricsFormCubit to handle stream for BlocProvider
    final mockStream = Stream<HealthMetricsFormState>.empty();
    when(mockHealthMetricsFormCubit.stream).thenAnswer((_) => mockStream);
    when(mockHealthMetricsFormCubit.state).thenReturn(HealthMetricsFormState());

    // Build our widget with isRegister = true and provide BlocProvider for FormCubit
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HealthMetricsFormCubit>.value(
          value: mockHealthMetricsFormCubit,
          child: Scaffold(
            body: Center(
              child: GoogleSignInButton(
                isUnderTest: true,
                isRegister: true,
                googleAuthService: mockGoogleSignInService,
              ),
            ),
          ),
        ),
      ),
    );

    // Tunggu widget selesai build
    await tester.pumpAndSettle();

    // Tap button yang mengandung teks "Register with Google"
    final textButtonFinder = find.text('Register with Google');
    expect(textButtonFinder, findsOneWidget);
    await tester.tap(textButtonFinder);

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify methods were called
    verify(mockGoogleSignInService.signInWithGoogle()).called(1);

    // Verify analytics event was logged for registration attempt
    verify(mockAnalyticsService.logEvent(
            name: 'google_sign_up_attempt', parameters: null))
        .called(1);

    // Verify FormCubit methods were called
    verify(mockHealthMetricsFormCubit.setUserId('test-uid')).called(1);
    verify(mockHealthMetricsFormCubit.submit()).called(1);

    // Verify UserPreferencesService method was called
    verify(mockUserPreferencesService.synchronizePreferencesAfterLogin())
        .called(1);
  });
}
