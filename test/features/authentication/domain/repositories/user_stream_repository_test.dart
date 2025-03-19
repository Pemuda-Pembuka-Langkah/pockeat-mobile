import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_auth_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_firestore_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_base.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_stream_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_stream_repository_test.mocks.dart';

@GenerateMocks([
  UserAuthRepository,
  UserFirestoreRepository,
  User,
  FirebaseAuth,
  FirebaseFirestore,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockTypedCollectionReference,
  ),
])
// Jalankan: flutter pub run build_runner build
void main() {
  // Setup kelas mock
  late MockUserAuthRepository mockAuthRepo;
  late MockUserFirestoreRepository mockFirestoreRepo;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late UserStreamRepository streamRepository;
  late MockUser mockUser;
  late MockTypedCollectionReference mockCollection;

  // Stream controllers
  late StreamController<User?> authStateController;
  late StreamController<UserModel?> firestoreUserController;

  // Data model
  late UserModel testUserModel;

  setUp(() {
    // Inisialisasi mock
    mockAuthRepo = MockUserAuthRepository();
    mockFirestoreRepo = MockUserFirestoreRepository();
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockCollection = MockTypedCollectionReference();

    // Buat stream controllers
    authStateController = StreamController<User?>.broadcast();
    firestoreUserController = StreamController<UserModel?>.broadcast();

    // Setup model user
    testUserModel = UserModel(
      uid: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      photoURL: 'https://example.com/photo.jpg',
      emailVerified: false,
      createdAt: DateTime.now(),
    );

    // Setup mock behavior
    when(mockUser.uid).thenReturn('test-user-id');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');

    // Setup auth mock
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockAuth.authStateChanges())
        .thenAnswer((_) => authStateController.stream);

    // Setup Firestore collection
    when(mockFirestore.collection('users')).thenReturn(mockCollection);

    // Setup auth repo
    when(mockAuthRepo.currentUser).thenReturn(mockUser);
    when(mockAuthRepo.authStateChanges)
        .thenAnswer((_) => authStateController.stream);
    when(mockAuthRepo.createUserModelFromAuth(any)).thenReturn(testUserModel);

    // Setup firestore repo
    when(mockFirestoreRepo.getUserById('test-user-id'))
        .thenAnswer((_) async => testUserModel);
    when(mockFirestoreRepo.userChangesStream('test-user-id'))
        .thenAnswer((_) => firestoreUserController.stream);

    // Buat repository asli dengan mock
    streamRepository = UserStreamRepository(
      authRepo: mockAuthRepo,
      firestoreRepo: mockFirestoreRepo,
      auth: mockAuth,
      firestore: mockFirestore,
    );

    // Harus menambahkan event ke auth stream pada init
    authStateController.add(null);
  });

  tearDown(() {
    streamRepository.dispose();
    authStateController.close();
    firestoreUserController.close();
  });

  group('UserStreamRepository', () {
    test('userChanges harus return stream', () {
      // Act
      final stream = streamRepository.userChanges;

      // Assert
      expect(stream, isA<Stream<UserModel?>>());
    });

    test('notifyUserChanged harus mengirim event ke userChanges stream',
        () async {
      // Arrange
      final testModel = UserModel(
        uid: 'test-user-id',
        email: 'updated@example.com',
        displayName: 'Updated User',
        photoURL: 'https://example.com/updated.jpg',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      // Tangkap events
      final events = <UserModel?>[];
      final subscription = streamRepository.userChanges.listen(events.add);

      // Act
      streamRepository.notifyUserChanged(testModel);

      // Tunggu events
      await Future.delayed(Duration(milliseconds: 100));
      await subscription.cancel();

      // Assert
      expect(events, hasLength(1));
      expect(events.first?.email, equals('updated@example.com'));
    });

    test('getUserStream harus mendelegasikan ke firestoreRepo', () {
      // Act
      streamRepository.getUserStream('test-user-id');

      // Assert - verifikasi firestoreRepo.userChangesStream dipanggil
      verify(mockFirestoreRepo.userChangesStream('test-user-id')).called(1);
    });
  });
}
