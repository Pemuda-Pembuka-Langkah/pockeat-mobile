import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';

@GenerateMocks([LoginService, GlobalKey, NavigatorState])
import 'auth_wrapper_test.mocks.dart';

void main() {
  late MockLoginService mockLoginService;
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
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
