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
import 'package:pockeat/features/authentication/services/register_service.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';
import 'register_page_test.mocks.dart';

@GenerateMocks([
  RegisterService, AnalyticsService, FirebaseAuth, User, HealthMetricsFormCubit
])
void main() {
  late MockRegisterService mockRegisterService;
  late MockAnalyticsService mockAnalyticsService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockHealthMetricsFormCubit mockHealthMetricsFormCubit;
  late GetIt getIt;

  setUp(() {
    mockRegisterService = MockRegisterService();
    mockAnalyticsService = MockAnalyticsService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockHealthMetricsFormCubit = MockHealthMetricsFormCubit();
    getIt = GetIt.instance;
    getIt.reset();

    getIt.registerSingleton<RegisterService>(mockRegisterService);
    getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);
    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);

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
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('SIGN UP'), findsOneWidget);
    });

    testWidgets('Gender dropdown selection', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Select your gender'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Female').last);
      await tester.pumpAndSettle();

      expect(find.text('Female'), findsOneWidget);
    });

    testWidgets('Birthdate picker selection', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      await tester.tap(find.widgetWithText(TextFormField, 'Birth Date (Optional)'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
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
