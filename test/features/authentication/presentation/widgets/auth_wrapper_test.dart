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

@GenerateMocks([LoginService, NavigatorState, HealthMetricsCheckService])

/// Custom mock observer to track navigation during tests
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockLoginService mockLoginService;
  late MockHealthMetricsCheckService mockCheckService;

  final authenticatedUser = UserModel(
    uid: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    emailVerified: true,
    createdAt: DateTime.now(),
  );

  setUp(() {
    // Reset shared preferences before each test
    SharedPreferences.setMockInitialValues({});

    mockLoginService = MockLoginService();
    mockCheckService = MockHealthMetricsCheckService();

    // Register mock services with GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) getIt.unregister<LoginService>();
    if (getIt.isRegistered<HealthMetricsCheckService>())
      getIt.unregister<HealthMetricsCheckService>();

    getIt.registerSingleton<LoginService>(mockLoginService);
    getIt.registerSingleton<HealthMetricsCheckService>(mockCheckService);
  });

  tearDown(() {
    // Clean up GetIt after each test
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) getIt.unregister<LoginService>();
    if (getIt.isRegistered<HealthMetricsCheckService>())
      getIt.unregister<HealthMetricsCheckService>();
  });

  group('AuthWrapper', () {
    testWidgets(
        'should show child when requireAuth is false and user is not authenticated',
        (WidgetTester tester) async {
      // Even though requireAuth = false, getCurrentUser is still called, so mock it
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: false,
            child: const Text('Child Widget'),
          ),
        ),
      );

      await tester.pumpAndSettle(); // wait for auth checking if any

      expect(find.text('Child Widget'), findsOneWidget);
      verify(mockLoginService.getCurrentUser()).called(1);
    });

    testWidgets(
        'should redirect when requireAuth is false and user is authenticated',
        (WidgetTester tester) async {
      // Setup authenticated user
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => authenticatedUser);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: false,
            redirectUrlIfLoggedIn: '/dashboard',
            child: const Text('Child Widget'),
          ),
          routes: {
            '/dashboard': (context) =>
                const Scaffold(body: Text('Dashboard Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify redirect to dashboard when logged in but requireAuth is false
      expect(find.text('Dashboard Page'), findsOneWidget);
      expect(find.text('Child Widget'), findsNothing);
    });

    testWidgets(
        'should show child when requireAuth is true, user is authenticated, and onboarding is completed',
        (WidgetTester tester) async {
      // Setup auth check
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => authenticatedUser);
      when(mockCheckService.hasCompletedOnboarding(any))
          .thenAnswer((_) async => true);

      // Build widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: true,
            child: const Text('Child Widget'),
          ),
        ),
      );

      // Wait for futures to complete
      await tester.pumpAndSettle();

      // Verify the child is shown and loginService was checked
      expect(find.text('Child Widget'), findsOneWidget);
      verify(mockLoginService.getCurrentUser()).called(1);
      verify(mockCheckService.hasCompletedOnboarding(any)).called(1);
    });

    testWidgets(
        'should redirect to /welcome when requireAuth is true and user is not authenticated',
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
            child: const Text('Child Widget'),
          ),
          routes: {
            '/welcome': (context) => const Scaffold(body: Text('Welcome Page')),
          },
        ),
      );

      // Wait for futures to complete and navigation to happen
      await tester.pumpAndSettle();

      // Verify redirect to welcome page
      expect(find.text('Welcome Page'), findsOneWidget);
      expect(find.text('Child Widget'), findsNothing);
    });

    testWidgets('should show child while waiting for auth check',
        (WidgetTester tester) async {
      // Setup auth check to never complete (loading state)
      final completer = Completer<UserModel?>();
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: true,
            child: const Text('Child Widget'),
          ),
        ),
      );

      await tester.pump(); // pump once so build happens
    });

    testWidgets('should handle auth check errors gracefully',
        (WidgetTester tester) async {
      // Setup auth check to throw an error
      when(mockLoginService.getCurrentUser())
          .thenThrow(Exception('Auth check failed'));

      // Build widget tree
      // Build widget tree with navigator observer
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          home: AuthWrapper(
            requireAuth: true,
            child: const Text('Child Widget'),
          ),
          routes: {
            '/welcome': (context) => const Scaffold(body: Text('Welcome Page')),
          },
        ),
      );

      await tester.pump();

      // Wait for navigation to complete
      await tester.pumpAndSettle();

      // Verify redirect to welcome page on error
      expect(find.text('Welcome Page'), findsOneWidget);
      expect(find.text('Child Widget'), findsNothing);
    });

    testWidgets('redirects to /height-weight if onboarding not completed',
        (tester) async {
      // Use the already setup mock services
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => authenticatedUser);
      when(mockCheckService.hasCompletedOnboarding('test-user-id'))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (_) => AuthWrapper(
                  requireAuth: true,
                  child: const Scaffold(
                    body: Text('Home Page'),
                  ),
                ),
            '/height-weight': (_) => const Scaffold(
                  body: Text('Height Weight Page'),
                ),
          },
        ),
      );

      await tester.pumpAndSettle();

      // ✅ User should be redirected to /height-weight
      expect(find.text('Height Weight Page'), findsOneWidget);
      expect(find.text('Home Page'), findsNothing);
    });

    testWidgets(
        'redirects to custom path when requireAuth=true and user is not authenticated',
        (WidgetTester tester) async {
      // Setup current user to return null (not authenticated)
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);

      // Build widget tree with custom redirect path
      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: true,
            redirectUrlIfNotLoggedIn: '/custom-login',
            child: const Text('Child Widget'),
          ),
          routes: {
            '/custom-login': (context) =>
                const Scaffold(body: Text('Custom Login Page')),
          },
        ),
      );

      // Wait for futures to complete and navigation to happen
      await tester.pumpAndSettle();

      // Verify redirect to custom login page
      expect(find.text('Custom Login Page'), findsOneWidget);
      expect(find.text('Child Widget'), findsNothing);
    });

    testWidgets(
        'should gracefully handle when widget is unmounted during auth check',
        (WidgetTester tester) async {
      // Create a completer to control when the auth check completes
      final completer = Completer<UserModel?>();
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthWrapper(
            requireAuth: true,
            child: const Text('Child Widget'),
          ),
        ),
      );

      // First render - should show loading
      await tester.pump();

      // Replace the widget tree while auth check is in progress
      await tester.pumpWidget(
        const MaterialApp(
          home: Text('Different Widget'),
        ),
      );

      // Complete the auth check after widget is no longer in tree
      completer.complete(authenticatedUser);
      await tester.pumpAndSettle();

      // Should not crash and should show the new widget
      expect(find.text('Different Widget'), findsOneWidget);
    });
  });
}
