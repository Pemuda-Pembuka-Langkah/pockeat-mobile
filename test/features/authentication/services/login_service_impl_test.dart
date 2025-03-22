import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/login_service_impl.dart';

@GenerateMocks(
    [FirebaseAuth, UserCredential, UserRepository, NavigatorObserver])
import 'login_service_impl_test.mocks.dart';

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
      final result = loginService.initialize(navigatorKey);

      // Assert
      expect(result, equals(userStream));
      verify(mockUserRepository.currentUserStream()).called(1);
    });

    test('initialize should subscribe to user stream', () async {
      // Arrange
      final controller = StreamController<UserModel?>();

      when(mockUserRepository.currentUserStream())
          .thenAnswer((_) => controller.stream);

      // Act
      loginService.initialize(navigatorKey);

      // Cleanup
      await controller.close();

      // Verify stream subscription was created (indirectly)
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

    test('dispose should cancel the stream subscription', () {
      // Arrange
      final controller = StreamController<UserModel?>();
      when(mockUserRepository.currentUserStream())
          .thenAnswer((_) => controller.stream);

      // Act
      loginService.initialize(navigatorKey);
      loginService.dispose();

      // Cleanup
      controller.close();

      // No explicit assert needed - we're testing that no exception occurs
    });
  });
}
