import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_auth_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_auth_repository_test.mocks.dart';

// Membuat interface untuk tipe CollectionReference yang dibutuhkan
abstract class TestCollectionReference
    implements CollectionReference<Map<String, dynamic>> {}

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  CollectionReference,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockTypedCollectionReference,
  ),
])
// Jalankan: flutter pub run build_runner build
void main() {
  late UserAuthRepository authRepository;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockTypedCollectionReference mockCollection;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockTypedCollectionReference();
    mockUser = MockUser();

    // Setup mock user data
    when(mockUser.uid).thenReturn('test-user-id');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
    when(mockUser.emailVerified).thenReturn(false);

    // Setup Firestore mock
    when(mockFirestore.collection('users')).thenReturn(mockCollection);

    // Setup mock auth
    when(mockAuth.currentUser).thenReturn(mockUser);

    // Mock untuk updateUserProfile
    when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});
    when(mockUser.updatePhotoURL(any)).thenAnswer((_) async {});

    // Buat repository dengan mock
    authRepository =
        UserAuthRepository(auth: mockAuth, firestore: mockFirestore);
  });

  tearDown(() {
    authRepository.dispose();
  });

  group('UserAuthRepository', () {
    test('currentUser should return the current Firebase user', () {
      // Act
      final result = authRepository.currentUser;

      // Assert
      expect(result, isNotNull);
      expect(result, equals(mockUser));
      verify(mockAuth.currentUser).called(1);
    });

    test('authStateChanges should relay auth state changes stream', () {
      // Arrange
      when(mockAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));

      // Act
      final stream = authRepository.authStateChanges;

      // Assert
      expect(stream, isA<Stream<User?>>());
      verify(mockAuth.authStateChanges()).called(1);
    });

    test('updateUserProfile should update displayName and photoURL', () async {
      // Act
      await authRepository.updateUserProfile(
        displayName: 'New Name',
        photoURL: 'https://example.com/new.jpg',
      );

      // Assert
      verify(mockUser.updateDisplayName('New Name')).called(1);
      verify(mockUser.updatePhotoURL('https://example.com/new.jpg')).called(1);
    });

    test('updateUserProfile should handle FirebaseAuthException', () async {
      // Arrange
      final exception = FirebaseAuthException(code: 'user-not-found');
      when(mockUser.updateDisplayName(any)).thenThrow(exception);

      // Act & Assert
      expect(
        () => authRepository.updateUserProfile(displayName: 'New Name'),
        throwsA(predicate(
          (e) =>
              e is UserRepositoryException &&
              e.code == 'user-not-found' &&
              e.message == 'Failed to update auth profile',
        )),
      );
    });

    test('updateUserProfile should handle general exceptions', () async {
      // Arrange
      final exception = Exception('General error');
      when(mockUser.updateDisplayName(any)).thenThrow(exception);

      // Act & Assert
      expect(
        () => authRepository.updateUserProfile(displayName: 'New Name'),
        throwsA(predicate(
          (e) =>
              e is UserRepositoryException &&
              e.message == 'Unexpected error while updating auth profile',
        )),
      );
    });

    test('updateUserProfile should throw when user is not logged in', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => authRepository.updateUserProfile(displayName: 'New Name'),
        throwsA(predicate(
          (e) =>
              e is UserRepositoryException &&
              e.message == 'Unexpected error while updating auth profile',
        )),
      );
    });

    test('isEmailAlreadyRegistered should return true for registered email',
        () async {
      // Arrange
      when(mockAuth.fetchSignInMethodsForEmail('test@example.com'))
          .thenAnswer((_) async => ['password']);

      // Act
      final result =
          await authRepository.isEmailAlreadyRegistered('test@example.com');

      // Assert
      expect(result, isTrue);
      verify(mockAuth.fetchSignInMethodsForEmail('test@example.com')).called(1);
    });

    test('isEmailAlreadyRegistered should return false for new email',
        () async {
      // Arrange
      when(mockAuth.fetchSignInMethodsForEmail('new@example.com'))
          .thenAnswer((_) async => []);

      // Act
      final result =
          await authRepository.isEmailAlreadyRegistered('new@example.com');

      // Assert
      expect(result, isFalse);
      verify(mockAuth.fetchSignInMethodsForEmail('new@example.com')).called(1);
    });

    test('isEmailAlreadyRegistered should validate email format', () async {
      // Act & Assert
      expect(
        () => authRepository.isEmailAlreadyRegistered('invalid-email'),
        throwsA(predicate(
          (e) => e is UserRepositoryException && e.code == 'invalid-email',
        )),
      );

      verifyNever(mockAuth.fetchSignInMethodsForEmail(any));
    });

    test('isEmailAlreadyRegistered should handle FirebaseAuthException',
        () async {
      // Arrange
      final exception = FirebaseAuthException(code: 'network-request-failed');
      when(mockAuth.fetchSignInMethodsForEmail('test@example.com'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => authRepository.isEmailAlreadyRegistered('test@example.com'),
        throwsA(predicate(
          (e) =>
              e is UserRepositoryException &&
              e.code == 'network-request-failed' &&
              e.message == 'Error checking email registration status',
        )),
      );
    });

    test('isEmailAlreadyRegistered should handle general exceptions', () async {
      // Arrange
      final exception = Exception('Unexpected error');
      when(mockAuth.fetchSignInMethodsForEmail('test@example.com'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => authRepository.isEmailAlreadyRegistered('test@example.com'),
        throwsA(predicate(
          (e) =>
              e is UserRepositoryException &&
              e.message == 'Unexpected error checking email registration',
        )),
      );
    });

    test('createUserModelFromAuth should create UserModel from Firebase user',
        () {
      // Act
      final userModel = authRepository.createUserModelFromAuth(mockUser);

      // Assert
      expect(userModel.uid, equals('test-user-id'));
      expect(userModel.email, equals('test@example.com'));
      expect(userModel.displayName, equals('Test User'));
      expect(userModel.photoURL, equals('https://example.com/photo.jpg'));
      expect(userModel.emailVerified, isFalse);
    });
  });
}
