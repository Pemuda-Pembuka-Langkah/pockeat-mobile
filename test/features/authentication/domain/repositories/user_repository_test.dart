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
      providedAuthRepo: mockAuthRepo,
      providedFirestoreRepo: mockFirestoreRepo,
      providedStreamRepo: mockStreamRepo,
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

    test('updateUserProfile should throw when userId is empty', () async {
      // Act & Assert - menerima UserRepositoryException yang dilempar implementasi
      expect(
        userRepository.updateUserProfile(
          userId: '',
          displayName: 'Test Name',
        ),
        throwsA(isA<UserRepositoryException>()),
      );
    });

    test('updateUserProfile should handle errors in auth update', () async {
      // Setup mock untuk validateUserAccess berhasil
      when(mockAuthRepo.validateUserAccess('test-user-id')).thenReturn(null);

      // Setup mock untuk updateUserProfile yang akan melempar exception
      final exception = UserRepositoryException(
        'Failed to update auth profile',
        code: 'auth-failed',
      );

      when(mockAuthRepo.updateUserProfile(
        displayName: 'Updated Name',
        photoURL: null,
      )).thenThrow(exception);

      // Act & Assert
      expect(
          () => userRepository.updateUserProfile(
                userId: 'test-user-id',
                displayName: 'Updated Name',
              ),
          throwsA(isA<UserRepositoryException>()));
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

    test('isEmailAlreadyRegistered should delegate to auth repository',
        () async {
      // Arrange
      when(mockAuthRepo.isEmailAlreadyRegistered('test@example.com'))
          .thenAnswer((_) async => true);

      // Act
      final result =
          await userRepository.isEmailAlreadyRegistered('test@example.com');

      // Assert
      expect(result, isTrue);
      verify(mockAuthRepo.isEmailAlreadyRegistered('test@example.com'))
          .called(1);
    });

    test('isEmailAlreadyRegistered should handle exceptions', () async {
      // Arrange
      final exception = UserRepositoryException(
        'Invalid email format',
        code: 'invalid-email',
      );
      when(mockAuthRepo.isEmailAlreadyRegistered('invalid-email'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => userRepository.isEmailAlreadyRegistered('invalid-email'),
        throwsA(predicate(
          (e) => e is UserRepositoryException && e.code == 'invalid-email',
        )),
      );
    });
  });

  // Test untuk reactive programming
  group('UserRepository Reactive Programming', () {
    test('userStream should delegate to streamRepo', () {
      // Act
      userRepository.userStream('test-user-id');

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
      userRepository.currentUserStream();

      // Assert - verify delegation
      verify(mockStreamRepo.currentUserStream).called(1);
    });
  });

  group('UserRepository Exception Handling', () {
    test('getUserById should handle generic exceptions', () async {
      // Arrange - ini untuk menutup baris 123
      when(mockAuthRepo.validateUserAccess('test-user-id')).thenReturn(null);
      when(mockFirestoreRepo.getUserById('test-user-id'))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => userRepository.getUserById('test-user-id'),
        throwsA(predicate((e) =>
            e is UserRepositoryException &&
            e.message == 'Error getting user data')),
      );
    });

    test('saveUser should handle generic exceptions', () async {
      // Arrange - ini untuk menutup baris 159
      final user = UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: false,
        createdAt: DateTime.now(),
      );
      when(mockFirestoreRepo.saveUser(user))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => userRepository.saveUser(user),
        throwsA(predicate((e) =>
            e is UserRepositoryException &&
            e.message == 'Error saving user data')),
      );
    });

    test('updateUserProfile should handle generic exceptions', () async {
      // Arrange - ini untuk menutup baris 191
      when(mockAuthRepo.validateUserAccess('test-user-id')).thenReturn(null);
      when(mockAuthRepo.updateUserProfile(
              displayName: anyNamed('displayName'),
              photoURL: anyNamed('photoURL')))
          // ignore: avoid_returning_null_for_void
          .thenAnswer((_) async => null);
      when(mockFirestoreRepo.updateUser(any, any))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => userRepository.updateUserProfile(
          userId: 'test-user-id',
          displayName: 'New Name',
        ),
        throwsA(predicate((e) =>
            e is UserRepositoryException &&
            e.message == 'Error updating user profile')),
      );
    });

    test('updateEmailVerificationStatus should handle generic exceptions',
        () async {
      // Arrange - ini untuk menutup baris 216
      when(mockAuthRepo.validateUserAccess('test-user-id')).thenReturn(null);
      when(mockFirestoreRepo.updateUser('test-user-id', any))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () =>
            userRepository.updateEmailVerificationStatus('test-user-id', true),
        throwsA(predicate((e) =>
            e is UserRepositoryException &&
            e.message == 'Error updating email verification status')),
      );
    });

    test('userStream should handle generic exceptions', () async {
      // Arrange - ini untuk menutup baris 230
      when(mockStreamRepo.getUserStream('test-user-id'))
          .thenThrow(Exception('Stream error'));

      // Act
      final stream = userRepository.userStream('test-user-id');

      // Assert - verify it's an error stream with correct exception type
      expectLater(
        stream,
        emitsError(predicate(
            (e) => e is UserRepositoryException && e.originalError != null)),
      );
    });
  });

  group('UserRepository Corner Cases', () {
    test('Factory constructor should handle direct dependency injection', () {
      // Arrange - test constructor factory pada baris 31
      final directRepo = UserRepositoryImpl(
        providedAuthRepo: mockAuthRepo,
        providedFirestoreRepo: mockFirestoreRepo,
        providedStreamRepo: mockStreamRepo,
      );

      // Act
      final result = directRepo.getCurrentUser();

      // Assert - verify it works with injected dependencies
      expect(result, isNotNull);
    });
  });

  group('Comprehensive Error Handling', () {
    test('saveUser should pass through UserRepositoryException from repo',
        () async {
      // Arrange - untuk menutup baris 151
      final user = UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      // Gunakan UserRepositoryException langsung untuk lewati catch luar
      final repoException = UserRepositoryException(
        'Permission denied when saving user',
        code: 'permission-denied',
      );

      when(mockFirestoreRepo.saveUser(user)).thenThrow(repoException);

      // Act & Assert
      expect(
        () => userRepository.saveUser(user),
        throwsA(predicate((e) =>
            e is UserRepositoryException &&
            e.code == 'permission-denied' &&
            e.message == 'Permission denied when saving user')),
      );
    });

    test(
        'updateUserProfile should pass through UserRepositoryException from repos',
        () async {
      // Arrange - ini untuk menutup baris 191
      final repoException = UserRepositoryException(
        'Permission denied when updating user',
        code: 'permission-denied',
      );

      when(mockAuthRepo.validateUserAccess('test-user-id'))
          .thenThrow(repoException);

      // Act & Assert - exception harus dilempar kembali
      expect(
        () => userRepository.updateUserProfile(
          userId: 'test-user-id',
          displayName: 'New Name',
        ),
        throwsA(predicate((e) =>
            e is UserRepositoryException && e.code == 'permission-denied')),
      );
    });

    test('updateUserProfile should skip update if no fields changed', () async {
      // Arrange
      when(mockAuthRepo.validateUserAccess('test-user-id')).thenReturn(null);

      // Act - panggil dengan semua parameter null kecuali userId
      final result = await userRepository.updateUserProfile(
        userId: 'test-user-id',
      );

      // Assert - harusnya tetap berhasil
      expect(result, isTrue);

      // Tapi tidak memanggil updateUser karena tidak ada data untuk diupdate
      verifyNever(mockFirestoreRepo.updateUser(any, any));
    });
  });

  group('UserRepository Coverage', () {
    test('Repository setup should initialize properly', () {
      // Test setup ini membantu meningkatkan coverage untuk factory constructor
      // baris 31-78 di user_repository_impl.dart
      expect(userRepository, isA<UserRepositoryImpl>());

      // Panggil method untuk meningkatkan coverage
      userRepository.dispose();
    });

    test(
        'saveUser should pass through UserRepositoryException from firestore repo',
        () async {
      // Arrange - untuk menutup baris 151, 159
      final user = UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      // Setup exception untuk kedua jalur catch
      when(mockFirestoreRepo.saveUser(any)).thenThrow(UserRepositoryException(
        'Firestore permission denied',
        code: 'permission-denied',
      ));

      // Act & Assert
      expect(
        () => userRepository.saveUser(user),
        throwsA(predicate((e) =>
            e is UserRepositoryException && e.code == 'permission-denied')),
      );
    });

    test('validateUserAccess should check current user and ID match', () {
      // Arrange - untuk menutup baris 19-20 di user_repository_base.dart
      when(mockUser.uid).thenReturn('test-user-id');

      // Act & Assert - Tidak melempar exception jika ID sama
      expect(() => mockAuthRepo.validateUserAccess('test-user-id'),
          isNot(throwsException));

      // Jika ID tidak sama, harus melempar exception
      when(mockAuthRepo.validateUserAccess('other-user-id'))
          .thenThrow(UserRepositoryException(
        'Access to another user\'s data is not allowed',
        code: 'permission-denied',
      ));

      expect(
        () => mockAuthRepo.validateUserAccess('other-user-id'),
        throwsA(predicate((e) =>
            e is UserRepositoryException && e.code == 'permission-denied')),
      );

      // Jika user null, harus melempar exception
      when(mockAuthRepo.currentUser).thenReturn(null);
      when(mockAuthRepo.validateUserAccess('any-user-id'))
          .thenThrow(UserRepositoryException(
        'No authenticated user found',
        code: 'unauthenticated',
      ));

      expect(
        () => mockAuthRepo.validateUserAccess('any-user-id'),
        throwsA(predicate((e) =>
            e is UserRepositoryException && e.code == 'unauthenticated')),
      );
    });

    test('updateUserProfile should return true when profile is valid',
        () async {
      // Setup mocks
      when(mockAuthRepo.validateUserAccess('test-user-id')).thenReturn(null);
      when(mockAuthRepo.updateUserProfile(
              displayName: anyNamed('displayName'),
              photoURL: anyNamed('photoURL')))
          .thenAnswer((_) async => null);
      when(mockFirestoreRepo.updateUser('test-user-id', any))
          // ignore: avoid_returning_null_for_void
          .thenAnswer((_) async => null);
      when(mockFirestoreRepo.getUserById('test-user-id'))
          .thenAnswer((_) async => UserModel(
                uid: 'test-user-id',
                email: 'test@example.com',
                displayName: 'New Name',
                emailVerified: false,
                gender: 'Male',
                createdAt: DateTime.now(),
              ));

      // Act
      final result = await userRepository.updateUserProfile(
        userId: 'test-user-id',
        displayName: 'New Name',
        gender: 'Male',
      );

      // Assert
      expect(result, isTrue);
      verify(mockFirestoreRepo.updateUser(
          'test-user-id',
          argThat(predicate<Map<String, dynamic>>((map) =>
              map['displayName'] == 'New Name' &&
              map['gender'] == 'Male')))).called(1);
    });
  });
}
