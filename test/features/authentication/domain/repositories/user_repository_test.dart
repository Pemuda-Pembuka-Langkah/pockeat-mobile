import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_impl.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

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
])
// File user_repository_test.mocks.dart akan digenerate dengan perintah: flutter pub run build_runner build

void main() {
  late UserRepository userRepository;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
  late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
  late MockDocumentSnapshot<Map<String, dynamic>> mockUserSnapshot;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
    mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
    mockUserSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    // Setup basic user data
    when(mockUser.uid).thenReturn('test-user-id');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
    when(mockUser.emailVerified).thenReturn(false);

    // Setup auth dengan mock user
    when(mockAuth.currentUser).thenReturn(mockUser);

    // Setup Firestore dengan mock collection dan document
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('test-user-id')).thenReturn(mockUserDoc);
    when(mockUsersCollection.doc('another-user-id')).thenReturn(mockUserDoc);

    // Setup document data
    final userData = {
      'uid': 'test-user-id',
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoURL': 'https://example.com/photo.jpg',
      'emailVerified': false,
      'createdAt': Timestamp.now(),
    };
    when(mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);
    when(mockUserSnapshot.id).thenReturn('test-user-id');
    when(mockUserSnapshot.exists).thenReturn(true);
    when(mockUserSnapshot.data()).thenReturn(userData);

    // Stubs for update and set
    when(mockUserDoc.update(any)).thenAnswer((_) async {});
    when(mockUserDoc.set(any, any)).thenAnswer((_) async {});

    // Buat repository dengan mock
    userRepository = UserRepositoryImpl(
      auth: mockAuth,
      firestore: mockFirestore,
    );
  });

  group('UserRepository', () {
    test('getCurrentUser should return current user', () async {
      // Act
      final result = await userRepository.getCurrentUser();

      // Assert
      expect(result, isNotNull);
      expect(result?.uid, equals('test-user-id'));
      expect(result?.email, equals('test@example.com'));
    });

    test('getCurrentUser should return null when not logged in', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await userRepository.getCurrentUser();

      // Assert
      expect(result, isNull);
    });

    test('getUserById should return user when ID matches current user',
        () async {
      // Act
      final result = await userRepository.getUserById('test-user-id');

      // Assert
      expect(result, isNotNull);
      expect(result?.uid, equals('test-user-id'));
    });

    test(
        'getUserById should throw exception when ID does not match current user',
        () async {
      // Act & Assert
      expect(
          () => userRepository.getUserById('another-user-id'),
          throwsA(isA<UserRepositoryException>()
              .having((e) => e.code, 'code', 'permission-denied')));
    });

    test('getUserById should throw exception when not logged in', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
          () => userRepository.getUserById('test-user-id'),
          throwsA(isA<UserRepositoryException>()
              .having((e) => e.code, 'code', 'unauthenticated')));
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

      // Capture data yang dikirim ke Firestore
      await userRepository.saveUser(newUser);

      // Assert
      verify(mockUserDoc.set(argThat(isA<Map<String, dynamic>>()), any))
          .called(1);
    });

    test('updateUserProfile should update user profile data', () async {
      // Act
      final result = await userRepository.updateUserProfile(
        userId: 'test-user-id',
        displayName: 'Updated Name',
        gender: 'Male',
      );

      // Assert
      expect(result, isTrue);
      verify(mockUserDoc.update(argThat(predicate<Map<Object, Object?>>((map) =>
          map['displayName'] == 'Updated Name' &&
          map['gender'] == 'Male')))).called(1);
    });

    test('updateUserProfile should throw exception when updating another user',
        () async {
      // Arrange - simulasi user yang berbeda
      when(mockUser.uid).thenReturn('different-user-id');

      // Act & Assert
      expect(
          () => userRepository.updateUserProfile(
                userId: 'test-user-id',
                displayName: 'Some Name',
              ),
          throwsA(isA<UserRepositoryException>()
              .having((e) => e.code, 'code', 'permission-denied')));
    });

    test('updateEmailVerificationStatus should update emailVerified status',
        () async {
      // Act
      await userRepository.updateEmailVerificationStatus('test-user-id', true);

      // Verify update called with correct params
      verify(mockUserDoc.update({'emailVerified': true})).called(1);
    });

    test('updateEmailVerificationStatus should throw for another user',
        () async {
      // Arrange - simulasi user yang berbeda
      when(mockUser.uid).thenReturn('different-user-id');

      // Act & Assert
      expect(
          () => userRepository.updateEmailVerificationStatus(
              'test-user-id', true),
          throwsA(isA<UserRepositoryException>()
              .having((e) => e.code, 'code', 'permission-denied')));
    });

    // Untuk menguji isEmailAlreadyRegistered
    test('isEmailAlreadyRegistered should return true for registered email',
        () async {
      // Arrange
      when(mockAuth.fetchSignInMethodsForEmail('test@example.com'))
          .thenAnswer((_) async => ['password']);

      // Act
      final result =
          await userRepository.isEmailAlreadyRegistered('test@example.com');

      // Assert
      expect(result, isTrue);
    });

    test('isEmailAlreadyRegistered should return false for new email',
        () async {
      // Arrange
      when(mockAuth.fetchSignInMethodsForEmail('new@example.com'))
          .thenAnswer((_) async => []);

      // Act
      final result =
          await userRepository.isEmailAlreadyRegistered('new@example.com');

      // Assert
      expect(result, isFalse);
    });

    // Catatan: Untuk stream tests perlu implementasi yang lebih kompleks
    // dengan StreamController dan akan diimplementasikan terpisah
  });
}
