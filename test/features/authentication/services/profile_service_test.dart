import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/profile_service.dart';
import 'package:pockeat/features/authentication/services/profile_service_impl.dart';

// Mock untuk Firebase Auth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Mock untuk User
class MockUser extends Mock implements User {}

// Mock untuk UserInfo
class MockUserInfo extends Mock implements UserInfo {}

// Mock untuk UserRepository
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late ProfileService profileService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserRepository mockUserRepository;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserRepository = MockUserRepository();
    mockUser = MockUser();

    // Setup ProfileService dengan mock
    profileService = ProfileServiceImpl(
      auth: mockFirebaseAuth,
      userRepository: mockUserRepository,
    );
  });

  group('ProfileService Tests', () {
    test('getCurrentUser should return user from repository', () async {
      // Arrange
      final testUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      when(() => mockUserRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await profileService.getCurrentUser();

      // Assert
      expect(result, equals(testUser));
      verify(() => mockUserRepository.getCurrentUser()).called(1);
    });

    test('getCurrentUser should return null when repository throws an error',
        () async {
      // Arrange
      when(() => mockUserRepository.getCurrentUser())
          .thenThrow(Exception('Repository error'));

      // Act
      final result = await profileService.getCurrentUser();

      // Assert
      expect(result, isNull);
      verify(() => mockUserRepository.getCurrentUser()).called(1);
    });

    test('updateUserProfile should update user profile via repository',
        () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUserRepository.updateUserProfile(
            userId: 'test-uid',
            displayName: 'New Name',
            photoURL: 'https://example.com/photo.jpg',
          )).thenAnswer((_) async => true);

      // Act
      final result = await profileService.updateUserProfile(
        displayName: 'New Name',
        photoURL: 'https://example.com/photo.jpg',
      );

      // Assert
      expect(result, isTrue);
      verify(() => mockUserRepository.updateUserProfile(
            userId: 'test-uid',
            displayName: 'New Name',
            photoURL: 'https://example.com/photo.jpg',
          )).called(1);
    });

    test('updateUserProfile should return false when no user is logged in',
        () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await profileService.updateUserProfile(
        displayName: 'New Name',
      );

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockUserRepository.updateUserProfile(
            userId: any(named: 'userId'),
            displayName: any(named: 'displayName'),
          ));
    });

    test('updateUserProfile should return false when repository throws',
        () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUserRepository.updateUserProfile(
            userId: 'test-uid',
            displayName: 'New Name',
            photoURL: null,
          )).thenThrow(Exception('Repository error'));

      // Act
      final result = await profileService.updateUserProfile(
        displayName: 'New Name',
      );

      // Assert
      expect(result, isFalse);
      verify(() => mockUserRepository.updateUserProfile(
            userId: 'test-uid',
            displayName: 'New Name',
            photoURL: null,
          )).called(1);
    });

    test('sendEmailVerification should send verification email', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});

      // Act
      final result = await profileService.sendEmailVerification();

      // Assert
      expect(result, isTrue);
      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test('sendEmailVerification should return false when no user is logged in',
        () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await profileService.sendEmailVerification();

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockUser.sendEmailVerification());
    });

    test('sendEmailVerification should return false when operation throws',
        () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification())
          .thenThrow(FirebaseAuthException(code: 'error'));

      // Act
      final result = await profileService.sendEmailVerification();

      // Assert
      expect(result, isFalse);
      verify(() => mockUser.sendEmailVerification()).called(1);
    });
  });
}
