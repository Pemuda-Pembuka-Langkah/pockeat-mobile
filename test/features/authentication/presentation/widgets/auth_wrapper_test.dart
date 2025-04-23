// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';
import 'auth_wrapper_test.mocks.dart';

@GenerateMocks([LoginService, GlobalKey, NavigatorState, HealthMetricsCheckService])

void main() {
  late MockLoginService mockLoginService;
  late MockHealthMetricsCheckService mockCheckService;
  final navigatorKey = GlobalKey<NavigatorState>();
  final authenticatedUser = UserModel(
    uid: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    emailVerified: true,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockLoginService = MockLoginService();
    mockCheckService = MockHealthMetricsCheckService();

    // Register mockLoginService in GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
    if (getIt.isRegistered<HealthMetricsCheckService>()) getIt.unregister<HealthMetricsCheckService>();
    getIt.registerSingleton<LoginService>(mockLoginService);
    getIt.registerSingleton<HealthMetricsCheckService>(mockCheckService);
  });

  tearDown(() {
    // Clean up GetIt registrations
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
  });

  group('AuthWrapper', () {
    testWidgets('should show child when requireAuth is false',
        (WidgetTester tester) async {
      // Build widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: false,
            child: Container(
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      // Verify the child is shown and loginService was not initialized
      expect(find.text('Child Widget'), findsOneWidget);
      verifyNever(mockLoginService.getCurrentUser());
    });

    testWidgets('should check auth when requireAuth is true',
        (WidgetTester tester) async {
      // Setup auth check
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => authenticatedUser);

      // Build widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: true,
            child: Container(
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      // Wait for futures to complete
      await tester.pumpAndSettle();

      // Verify the child is shown and loginService was checked
      expect(find.text('Child Widget'), findsOneWidget);
      verify(mockLoginService.getCurrentUser()).called(1);
    });

    testWidgets(
        'should show child when requireAuth is true and user is authenticated',
        (WidgetTester tester) async {
      // Setup current user
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => authenticatedUser);

      // Build widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: true,
            child: Container(
              child: const Text('Child Widget'),
            ),
          ),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );

      // Wait for futures to complete
      await tester.pumpAndSettle();

      // Verify the child is shown and not redirected to login
      expect(find.text('Child Widget'), findsOneWidget);
      expect(find.text('Login Page'), findsNothing);
    });

    testWidgets(
        'should redirect to login when requireAuth is true and user is not authenticated',
        (WidgetTester tester) async {
      // Setup current user to return null (not authenticated)
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);

      // Build widget tree with navigator observer to track redirects
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          home: AuthWrapper(
            requireAuth: true,
            child: Container(
              child: const Text('Child Widget'),
            ),
          ),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );

      // Wait for futures to complete and navigation to happen
      await tester.pumpAndSettle();

      // Verify redirect to login page
      expect(find.text('Login Page'), findsOneWidget);
      expect(find.text('Child Widget'), findsNothing);
    });

    testWidgets('should show child while waiting for auth check',
        (WidgetTester tester) async {
      // Setup auth check to never complete (loading state)
      final completer = Completer<UserModel?>();
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) => completer.future);

      // Build widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: true,
            child: Container(
              child: const Text('Child Widget'),
            ),
          ),
        ),
      );

      // Wait for widget to rebuild
      await tester.pump();

      // Verify the child is shown during loading
      expect(find.text('Child Widget'), findsOneWidget);
    });

    testWidgets('should handle auth check errors gracefully',
        (WidgetTester tester) async {
      // Setup auth check to throw an error
      when(mockLoginService.getCurrentUser())
          .thenThrow(Exception('Auth check failed'));

      // Build widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: true,
            child: Container(
              child: const Text('Child Widget'),
            ),
          ),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );

      // Wait for futures to complete and navigation to happen
      await tester.pumpAndSettle();

      // Verify redirect to login page on error
      expect(find.text('Login Page'), findsOneWidget);
    });
  });

  testWidgets('redirects to onboarding when not completed and not in progress', (tester) async {
  SharedPreferences.setMockInitialValues({'onboardingInProgress': false});
  when(mockLoginService.getCurrentUser()).thenAnswer((_) async => authenticatedUser);
  when(mockCheckService.hasCompletedOnboarding(any)).thenAnswer((_) async => false);

  await tester.pumpWidget(
    MaterialApp(
      routes: {
        '/onboarding/goal': (_) => const Scaffold(body: Text('Onboarding Page')),
      },
      home: AuthWrapper(
        requireAuth: true,
        child: const Text('Child Widget'),
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Onboarding Page'), findsOneWidget);
});

testWidgets('does not redirect if onboarding is in progress', (tester) async {
  SharedPreferences.setMockInitialValues({'onboardingInProgress': true});
  when(mockLoginService.getCurrentUser()).thenAnswer((_) async => authenticatedUser);
  when(mockCheckService.hasCompletedOnboarding(any)).thenAnswer((_) async => false);

  await tester.pumpWidget(
    MaterialApp(
      home: AuthWrapper(
        requireAuth: true,
        child: const Text('Child Widget'),
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Child Widget'), findsOneWidget);
});

testWidgets('does not redirect if already inside onboarding route', (tester) async {
  SharedPreferences.setMockInitialValues({'onboardingInProgress': false});
  when(mockLoginService.getCurrentUser()).thenAnswer((_) async => authenticatedUser);
  when(mockCheckService.hasCompletedOnboarding(any)).thenAnswer((_) async => false);

  await tester.pumpWidget(
    MaterialApp(
      initialRoute: '/onboarding/goal',
      routes: {
        '/onboarding/goal': (_) => AuthWrapper(
              requireAuth: true,
              child: const Text('Inside Onboarding'),
            ),
      },
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Inside Onboarding'), findsOneWidget);
});

}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
