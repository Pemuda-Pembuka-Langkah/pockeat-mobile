import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_firestore_repository.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_base.dart';

import 'user_firestore_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockTypedCollectionReference,
  ),
  MockSpec<DocumentReference<Map<String, dynamic>>>(
    as: #MockTypedDocumentReference,
  ),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(
    as: #MockTypedDocumentSnapshot,
  ),
  MockSpec<Query<Map<String, dynamic>>>(
    as: #MockTypedQuery,
  ),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(
    as: #MockTypedQuerySnapshot,
  ),
])
// Jalankan: flutter pub run build_runner build
void main() {
  late UserFirestoreRepository firestoreRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockTypedCollectionReference mockUsersCollection;
  late MockTypedDocumentReference mockUserDoc;
  late MockTypedDocumentSnapshot mockUserSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUsersCollection = MockTypedCollectionReference();
    mockUserDoc = MockTypedDocumentReference();
    mockUserSnapshot = MockTypedDocumentSnapshot();

    // Setup Firestore mock chain
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('test-user-id')).thenReturn(mockUserDoc);

    // Setup dokumen user
    final userData = {
      'uid': 'test-user-id',
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoURL': 'https://example.com/photo.jpg',
      'emailVerified': false,
      'createdAt': Timestamp.now(),
    };

    when(mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);
    when(mockUserSnapshot.exists).thenReturn(true);
    when(mockUserSnapshot.data()).thenReturn(userData);
    when(mockUserSnapshot.id).thenReturn('test-user-id');

    // Setup snapshot stream
    when(mockUserDoc.snapshots())
        .thenAnswer((_) => Stream.value(mockUserSnapshot));

    // Buat repository dengan mock
    firestoreRepository = UserFirestoreRepository(
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  tearDown(() {
    firestoreRepository.dispose();
  });

  group('UserFirestoreRepository', () {
    test('getUserById should return user model from Firestore', () async {
      // Act
      final result = await firestoreRepository.getUserById('test-user-id');

      // Assert
      expect(result, isNotNull);
      expect(result?.uid, equals('test-user-id'));
      expect(result?.email, equals('test@example.com'));
      expect(result?.displayName, equals('Test User'));

      verify(mockFirestore.collection('users')).called(1);
      verify(mockUsersCollection.doc('test-user-id')).called(1);
      verify(mockUserDoc.get()).called(1);
    });

    test('getUserById should return null when document does not exist',
        () async {
      // Arrange
      when(mockUserSnapshot.exists).thenReturn(false);

      // Act
      final result = await firestoreRepository.getUserById('test-user-id');

      // Assert
      expect(result, isNull);
    });

    test('saveUser should set document with merge', () async {
      // Arrange
      when(mockUserDoc.set(any, any)).thenAnswer((_) async {});

      final userModel = UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      // Act
      await firestoreRepository.saveUser(userModel);

      // Assert
      verify(mockUserDoc.set(
        argThat(isA<Map<String, dynamic>>()),
        argThat(isA<SetOptions>()),
      )).called(1);
    });

    test('updateUser should call update with correct data', () async {
      // Arrange
      when(mockUserDoc.update(any)).thenAnswer((_) async {});

      final updateData = {
        'displayName': 'Updated Name',
        'gender': 'Male',
      };

      // Act
      await firestoreRepository.updateUser('test-user-id', updateData);

      // Assert
      verify(mockUserDoc.update(updateData)).called(1);
    });

    test('userChangesStream should map document snapshots to user models', () {
      // Act
      final stream = firestoreRepository.userChangesStream('test-user-id');

      // Assert
      expect(stream, isA<Stream<UserModel?>>());

      // Verifikasi bahwa firestore.collection dan doc.snapshots dipanggil
      verify(mockFirestore.collection('users')).called(greaterThanOrEqualTo(1));
      verify(mockUsersCollection.doc('test-user-id'))
          .called(greaterThanOrEqualTo(1));
      verify(mockUserDoc.snapshots()).called(1);
    });
  });
}
