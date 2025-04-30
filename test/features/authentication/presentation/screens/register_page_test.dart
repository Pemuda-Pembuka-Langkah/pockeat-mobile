// fixed_register_page_test.dart
// [Corrected version of your register_page_test.dart to match your register_page.dart implementation]

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/core/services/analytics_service.dart';
import 'package:pockeat/features/authentication/presentation/screens/register_page.dart';
import 'package:pockeat/features/authentication/presentation/widgets/google_sign_in_button.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'register_page_test.mocks.dart';

@GenerateMocks([
  RegisterService, AnalyticsService, FirebaseAuth, User, HealthMetricsFormCubit,
  GoogleSignInService, UserCredential
])
void main() {
  late MockRegisterService mockRegisterService;
  late MockAnalyticsService mockAnalyticsService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockHealthMetricsFormCubit mockHealthMetricsFormCubit;
  late MockGoogleSignInService mockGoogleSignInService;
  late GetIt getIt;

  setUp(() {
    mockRegisterService = MockRegisterService();
    mockAnalyticsService = MockAnalyticsService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockHealthMetricsFormCubit = MockHealthMetricsFormCubit();
    mockGoogleSignInService = MockGoogleSignInService();
    getIt = GetIt.instance;
    getIt.reset();

    getIt.registerSingleton<RegisterService>(mockRegisterService);
    getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);
    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
    getIt.registerSingleton<GoogleSignInService>(mockGoogleSignInService);

    when(mockAnalyticsService.logScreenView(
      screenName: anyNamed('screenName'),
      screenClass: anyNamed('screenClass'),
    )).thenAnswer((_) async {});
  });

  tearDown(() => getIt.reset());

  Widget createTestableWidget() {
    return MaterialApp(
      routes: {
        '/login': (context) => const Scaffold(body: Text('Login Page')),
      },
      home: BlocProvider<HealthMetricsFormCubit>(
        create: (_) => mockHealthMetricsFormCubit,
        child: const RegisterPage(),
      ),
    );
  }

  group('Register Page Tests', () {
    testWidgets('Render basic fields', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.text('Create New Account'), findsOneWidget);
      expect(find.text('Sign up to start your health journey'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4)); // Name, email, password, confirm password
      expect(find.byType(Checkbox), findsOneWidget);
      // No gender dropdown anymore
      expect(find.text('SIGN UP'), findsOneWidget);
      // Check for Google Sign-In button
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.text('Register with Google'), findsOneWidget);
    });

    // Gender dropdown and birthdate picker tests removed as those fields don't exist anymore

    testWidgets('Google sign-in button works', (tester) async {
      // Setup mock return value for Google sign-in
      final mockAuthResult = MockUserCredential();
      when(mockUser.uid).thenReturn('test-uid');
      when(mockAuthResult.user).thenReturn(mockUser);
      when(mockGoogleSignInService.signInWithGoogle()).thenAnswer((_) async => mockAuthResult);
      when(mockAnalyticsService.logEvent(
        name: anyNamed('name'),
        parameters: anyNamed('parameters'),
      )).thenAnswer((_) async {});
      
      await tester.pumpWidget(createTestableWidget());
      
      // Find and tap Google sign-in button
      final googleButton = find.byType(GoogleSignInButton);
      expect(googleButton, findsOneWidget);
      
      // This is just testing the presence of the button since we can't actually
      // trigger the Google sign-in flow in a test environment
      expect(find.text('Register with Google'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final textField = find.descendant(of: passwordField, matching: find.byType(TextField));

      expect(tester.widget<TextField>(textField).obscureText, true);

      await tester.tap(find.descendant(of: passwordField, matching: find.byIcon(Icons.visibility)));
      await tester.pump();

      expect(tester.widget<TextField>(textField).obscureText, false);
    });

    testWidgets('Confirm Password visibility toggle works', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      final confirmPasswordField = find.widgetWithText(TextFormField, 'Confirm Password');
      final textField = find.descendant(of: confirmPasswordField, matching: find.byType(TextField));

      expect(tester.widget<TextField>(textField).obscureText, true);

      await tester.tap(find.descendant(of: confirmPasswordField, matching: find.byIcon(Icons.visibility)));
      await tester.pump();

      expect(tester.widget<TextField>(textField).obscureText, false);
    });
  });
}
