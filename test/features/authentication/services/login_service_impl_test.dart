// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/login_service_impl.dart';
import 'login_service_impl_test.mocks.dart';

@GenerateMocks(
    [FirebaseAuth, UserCredential, UserRepository, NavigatorObserver, User])

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserRepository mockUserRepository;
  late LoginServiceImpl loginService;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserRepository = MockUserRepository();
    navigatorKey = GlobalKey<NavigatorState>();
    loginService = LoginServiceImpl(
      auth: mockFirebaseAuth,
      userRepository: mockUserRepository,
    );
  });

  tearDown(() {
    loginService.dispose();
  });

  group('LoginServiceImpl', () {
    test('initialize should return stream from UserRepository', () {
      // Arrange
      final userStream = Stream<UserModel?>.fromIterable([
        UserModel(
          uid: 'test-user-id',
          email: 'test@example.com',
          displayName: 'Test User',
          emailVerified: true,
          createdAt: DateTime.now(),
        ),
      ]);

      when(mockUserRepository.currentUserStream())
          .thenAnswer((_) => userStream);

      // Act
      final result = loginService.initialize();

      // Assert
      expect(result, equals(userStream));
      verify(mockUserRepository.currentUserStream()).called(1);
    });

    test('initialize should subscribe to user stream', () {
      // Arrange
      final userStream = Stream<UserModel?>.fromIterable([
        UserModel(
          uid: 'test-user-id',
          email: 'test@example.com',
          displayName: 'Test User',
          emailVerified: true,
          createdAt: DateTime.now(),
        ),
      ]);

      when(mockUserRepository.currentUserStream())
          .thenAnswer((_) => userStream);

      // Act
      final result = loginService.initialize();

      // Assert - only verify that the method was called and returns the expected stream
      expect(result, equals(userStream));
      verify(mockUserRepository.currentUserStream()).called(1);
    });

    test('loginByEmail should call signInWithEmailAndPassword', () async {
      // Arrange
      final mockCredential = MockUserCredential();
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockCredential);

      // Act
      final result = await loginService.loginByEmail(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, equals(mockCredential));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('loginByEmail should throw FirebaseAuthException on error', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrong-password',
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'test@example.com',
          password: 'wrong-password',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('loginByEmail should return specific error message for user-not-found',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'nonexistent@example.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: 'Original Firebase error message',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'nonexistent@example.com',
          password: 'password123',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'user-not-found')
              .having(
                (e) => e.message,
                'message',
                'Email not registered. Please check your email or register first.',
              ),
        ),
      );
    });

    test('loginByEmail should return specific error message for wrong-password',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrong-pass',
      )).thenThrow(FirebaseAuthException(
        code: 'wrong-password',
        message: 'Original Firebase error message',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'test@example.com',
          password: 'wrong-pass',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'wrong-password')
              .having(
                (e) => e.message,
                'message',
                'Incorrect password. Please check your password.',
              ),
        ),
      );
    });

    test(
        'loginByEmail should return specific error message for invalid-credential',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'pass123',
      )).thenThrow(FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Original Firebase error message',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'test@example.com',
          password: 'pass123',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'invalid-credential')
              .having(
                (e) => e.message,
                'message',
                'Invalid email or password. Please check your credentials.',
              ),
        ),
      );
    });

    test('loginByEmail should return specific error message for user-disabled',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'disabled@example.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(
        code: 'user-disabled',
        message: 'Original Firebase error message',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'disabled@example.com',
          password: 'password123',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'user-disabled')
              .having(
                (e) => e.message,
                'message',
                'This account has been disabled. Please contact admin.',
              ),
        ),
      );
    });

    test(
        'loginByEmail should return specific error message for too-many-requests',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(
        code: 'too-many-requests',
        message: 'Original Firebase error message',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'too-many-requests')
              .having(
                (e) => e.message,
                'message',
                'Too many login attempts. Please try again later.',
              ),
        ),
      );
    });

    test(
        'loginByEmail should return specific error message for network-request-failed',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Original Firebase error message',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'network-request-failed')
              .having(
                (e) => e.message,
                'message',
                'Network problem occurred. Please check your internet connection.',
              ),
        ),
      );
    });

    test('loginByEmail should wrap other exceptions in FirebaseAuthException',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<FirebaseAuthException>().having(
          (e) => e.code,
          'code',
          'unknown-error',
        )),
      );
    });

    test('getCurrentUser should return UserModel when user is authenticated',
        () async {
      // Arrange
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(mockUser.emailVerified).thenReturn(true);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      
      // Setup mock untuk getUserById yang sekarang digunakan oleh getCurrentUser
      final testUserModel = UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      when(mockUserRepository.getUserById('test-user-id')).thenAnswer((_) async => testUserModel);

      // Act
      final result = await loginService.getCurrentUser();

      // Assert
      expect(result, isNotNull);
      expect(result?.uid, equals('test-user-id'));
      expect(result?.email, equals('test@example.com'));
      expect(result?.displayName, equals('Test User'));
      expect(result?.photoURL, equals('https://example.com/photo.jpg'));
      expect(result?.emailVerified, isTrue);
      verify(mockFirebaseAuth.currentUser).called(1);
      verify(mockUserRepository.getUserById('test-user-id')).called(1);
    });

    test('getCurrentUser should return null when no user is authenticated',
        () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await loginService.getCurrentUser();

      // Assert
      expect(result, isNull);
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('getCurrentUser should return null when exception occurs', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenThrow(Exception('Test error'));

      // Act
      final result = await loginService.getCurrentUser();

      // Assert
      expect(result, isNull);
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('dispose should cancel the stream subscription', () {
      // Arrange
      final controller = StreamController<UserModel?>();
      when(mockUserRepository.currentUserStream())
          .thenAnswer((_) => controller.stream);

      // Act
      loginService.initialize();
      loginService.dispose();

      // Cleanup
      controller.close();

      // No explicit assert needed - we're testing that no exception occurs
    });

    test('loginByEmail should return specific error message for invalid-email',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'invalid-email',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(
        code: 'invalid-email',
        message: 'Original Firebase error message',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'invalid-email',
          password: 'password123',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'invalid-email')
              .having(
                (e) => e.message,
                'message',
                'Invalid email format. Please check your email.',
              ),
        ),
      );
    });

    test(
        'loginByEmail should return specific error message for operation-not-allowed',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Original Firebase error message',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'operation-not-allowed')
              .having(
                (e) => e.message,
                'message',
                'Login with email and password is not allowed. Please use another login method.',
              ),
        ),
      );
    });

    test(
        'loginByEmail should return generic error message for unknown error codes',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(
        code: 'some-unknown-code',
        message: 'Unknown error',
      ));

      // Act & Assert
      expect(
        () => loginService.loginByEmail(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'some-unknown-code')
              .having(
                (e) => e.message,
                'message',
                'Login failed: Unknown error',
              ),
        ),
      );
    });
  });
}
