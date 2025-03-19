import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_auth_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_firestore_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_stream_repository.dart';

// Import file mock yang akan digenerate
import 'user_repository_test.mocks.dart';

// Anotasi untuk menghasilkan mocks secara otomatis
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  User,
  UserAuthRepository,
  UserFirestoreRepository,
  UserStreamRepository
])
// File user_repository_test.mocks.dart akan digenerate dengan perintah: flutter pub run build_runner build

void main() {
  late UserRepositoryImpl userRepository;
  late MockUserAuthRepository mockAuthRepo;
  late MockUserFirestoreRepository mockFirestoreRepo;
  late MockUserStreamRepository mockStreamRepo;
  late MockUser mockUser;
  final StreamController<UserModel?> mockStreamController =
      StreamController<UserModel?>.broadcast();

  setUp(() {
    mockAuthRepo = MockUserAuthRepository();
    mockFirestoreRepo = MockUserFirestoreRepository();
    mockStreamRepo = MockUserStreamRepository();
    mockUser = MockUser();

    // Setup basic user data
    when(mockUser.uid).thenReturn('test-user-id');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
    when(mockUser.emailVerified).thenReturn(false);

    // Setup auth repo dengan mock user
    when(mockAuthRepo.currentUser).thenReturn(mockUser);
    when(mockAuthRepo.authStateChanges)
        .thenAnswer((_) => Stream.value(mockUser));

    // Setup mock data untuk firestore repo
    final userData = UserModel(
      uid: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      photoURL: 'https://example.com/photo.jpg',
      emailVerified: false,
      createdAt: DateTime.now(),
    );

    when(mockFirestoreRepo.getUserById('test-user-id'))
        .thenAnswer((_) async => userData);
    when(mockFirestoreRepo.saveUser(any)).thenAnswer((_) async {});
    when(mockFirestoreRepo.updateUser(any, any)).thenAnswer((_) async {});

    // Setup mock stream repo
    when(mockStreamRepo.userChanges)
        .thenAnswer((_) => mockStreamController.stream);
    when(mockStreamRepo.currentUserStream)
        .thenAnswer((_) => Stream.value(userData));
    when(mockStreamRepo.getUserStream('test-user-id'))
        .thenAnswer((_) => Stream.value(userData));

    // Buat repository dengan mock langsung menggunakan constructor baru
    userRepository = UserRepositoryImpl(
      authRepo: mockAuthRepo,
      firestoreRepo: mockFirestoreRepo,
      streamRepo: mockStreamRepo,
    );
  });

  tearDown(() {
    // Pastikan resource dibersihkan
    userRepository.dispose();
    mockStreamController.close();
  });

  group('UserRepository Core Functions', () {
    test('getCurrentUser should return current user', () async {
      // Act
      final result = await userRepository.getCurrentUser();

      // Assert
      expect(result, isNotNull);
      expect(result?.uid, equals('test-user-id'));
      verify(mockAuthRepo.currentUser).called(1);
      verify(mockFirestoreRepo.getUserById('test-user-id')).called(1);
    });

    test('getCurrentUser should return null when not logged in', () async {
      // Arrange
      when(mockAuthRepo.currentUser).thenReturn(null);

      // Act
      final result = await userRepository.getCurrentUser();

      // Assert
      expect(result, isNull);
      verify(mockAuthRepo.currentUser).called(1);
      verifyNever(mockFirestoreRepo.getUserById(any));
    });

    test('getUserById should return user when ID matches current user',
        () async {
      // Act
      final result = await userRepository.getUserById('test-user-id');

      // Assert
      expect(result, isNotNull);
      expect(result?.uid, equals('test-user-id'));
      verify(mockAuthRepo.validateUserAccess('test-user-id')).called(1);
      verify(mockFirestoreRepo.getUserById('test-user-id')).called(1);
    });

    test(
        'getUserById should throw exception when ID does not match current user',
        () async {
      // Arrange
      final exception = UserRepositoryException(
        'Access to another user\'s data is not allowed',
        code: 'permission-denied',
      );
      when(mockAuthRepo.validateUserAccess('another-user-id'))
          .thenThrow(exception);

      // Act & Assert
      expect(
          () => userRepository.getUserById('another-user-id'),
          throwsA(predicate((e) =>
              e is UserRepositoryException && e.code == 'permission-denied')));
      verify(mockAuthRepo.validateUserAccess('another-user-id')).called(1);
    });

    test('getUserById should throw exception when not logged in', () async {
      // Arrange
      final exception = UserRepositoryException(
        'No authenticated user found',
        code: 'unauthenticated',
      );
      when(mockAuthRepo.validateUserAccess('test-user-id'))
          .thenThrow(exception);

      // Act & Assert
      expect(
          () => userRepository.getUserById('test-user-id'),
          throwsA(predicate((e) =>
              e is UserRepositoryException && e.code == 'unauthenticated')));
      verify(mockAuthRepo.validateUserAccess('test-user-id')).called(1);
    });

    test('saveUser should update Firestore document', () async {
      // Arrange
      final newUser = UserModel(
        uid: 'test-user-id',
        email: 'new@example.com',
        displayName: 'New Name',
        photoURL: 'https://example.com/new.jpg',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      // Act
      await userRepository.saveUser(newUser);

      // Assert
      verify(mockFirestoreRepo.saveUser(newUser)).called(1);
    });

    test('updateUserProfile should update user profile data', () async {
      // Arrange
      final updatedUser = UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Updated Name',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: false,
        gender: 'Male',
        createdAt: DateTime.now(),
      );

      when(mockFirestoreRepo.getUserById('test-user-id'))
          .thenAnswer((_) async => updatedUser);

      // Act
      final result = await userRepository.updateUserProfile(
        userId: 'test-user-id',
        displayName: 'Updated Name',
        gender: 'Male',
      );

      // Assert
      expect(result, isTrue);

      // Verifikasi update auth profile
      verify(mockAuthRepo.updateUserProfile(
        displayName: 'Updated Name',
        photoURL: null,
      )).called(1);

      // Verifikasi update firestore
      verify(mockFirestoreRepo.updateUser(
          'test-user-id',
          argThat(predicate<Map<String, dynamic>>((map) =>
              map['displayName'] == 'Updated Name' &&
              map['gender'] == 'Male')))).called(1);

      // Verifikasi notifikasi perubahan
      verify(mockStreamRepo.notifyUserChanged(any)).called(1);
    });

    test('updateUserProfile should throw exception when updating another user',
        () async {
      // Arrange
      final exception = UserRepositoryException(
        'Access to another user\'s data is not allowed',
        code: 'permission-denied',
      );
      when(mockAuthRepo.validateUserAccess('another-user-id'))
          .thenThrow(exception);

      // Act & Assert
      expect(
          () => userRepository.updateUserProfile(
                userId: 'another-user-id',
                displayName: 'Some Name',
              ),
          throwsA(predicate((e) =>
              e is UserRepositoryException && e.code == 'permission-denied')));
    });

    test('updateEmailVerificationStatus should update emailVerified status',
        () async {
      // Arrange
      final updatedUser = UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      when(mockFirestoreRepo.getUserById('test-user-id'))
          .thenAnswer((_) async => updatedUser);

      // Act
      await userRepository.updateEmailVerificationStatus('test-user-id', true);

      // Verify validasi akses
      verify(mockAuthRepo.validateUserAccess('test-user-id')).called(1);

      // Verify update called with correct params
      verify(mockFirestoreRepo
          .updateUser('test-user-id', {'emailVerified': true})).called(1);

      // Verify notifikasi perubahan
      verify(mockStreamRepo.notifyUserChanged(any)).called(1);
    });

    test('updateEmailVerificationStatus should throw for another user',
        () async {
      // Arrange
      final exception = UserRepositoryException(
        'Access to another user\'s data is not allowed',
        code: 'permission-denied',
      );
      when(mockAuthRepo.validateUserAccess('another-user-id'))
          .thenThrow(exception);

      // Act & Assert
      expect(
          () => userRepository.updateEmailVerificationStatus(
              'another-user-id', true),
          throwsA(predicate((e) =>
              e is UserRepositoryException && e.code == 'permission-denied')));
    });

    test('isEmailAlreadyRegistered should validate and check email', () async {
      // Arrange
      when(mockAuthRepo.isEmailAlreadyRegistered('test@example.com'))
          .thenAnswer((_) async => true);
      when(mockAuthRepo.isEmailAlreadyRegistered('new@example.com'))
          .thenAnswer((_) async => false);

      final exception = UserRepositoryException(
        'Invalid email format',
        code: 'invalid-email',
      );
      when(mockAuthRepo.isEmailAlreadyRegistered('invalid-email'))
          .thenThrow(exception);

      // Act & Assert - already registered email
      final registeredResult =
          await userRepository.isEmailAlreadyRegistered('test@example.com');
      expect(registeredResult, isTrue);

      // Act & Assert - new email
      final newResult =
          await userRepository.isEmailAlreadyRegistered('new@example.com');
      expect(newResult, isFalse);

      // Act & Assert - invalid email
      expect(
        () => userRepository.isEmailAlreadyRegistered('invalid-email'),
        throwsA(predicate(
            (e) => e is UserRepositoryException && e.code == 'invalid-email')),
      );
    });
  });

  // Test untuk reactive programming
  group('UserRepository Reactive Programming', () {
    test('userStream should delegate to streamRepo', () {
      // Act
      final stream = userRepository.userStream('test-user-id');

      // Assert - verify delegation
      verify(mockStreamRepo.getUserStream('test-user-id')).called(1);
    });

    test('userStream should return error stream on exception', () {
      // Arrange
      final exception = UserRepositoryException(
        'Access to another user\'s data is not allowed',
        code: 'permission-denied',
      );
      when(mockStreamRepo.getUserStream('another-user-id'))
          .thenThrow(exception);

      // Act
      final stream = userRepository.userStream('another-user-id');

      // Assert - verify it's an error stream
      expectLater(
        stream,
        emitsError(predicate((e) =>
            e is UserRepositoryException && e.code == 'permission-denied')),
      );
    });

    test('currentUserStream should delegate to streamRepo', () {
      // Act
      final stream = userRepository.currentUserStream();

      // Assert - verify delegation
      verify(mockStreamRepo.currentUserStream).called(1);
    });
  });
}
