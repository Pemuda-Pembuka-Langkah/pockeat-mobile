import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository_base.dart';

import 'user_repository_base_test.mocks.dart';

// Implementasi konkrit untuk testing
class ConcreteUserRepository extends UserRepositoryBase {
  ConcreteUserRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : super(auth: auth, firestore: firestore);
}

// Custom mock untuk Firebase User
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';

  @override
  String? get email => 'test@example.com';

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    return FakeIdTokenResult();
  }
}

// Fake IdTokenResult untuk mocking
class FakeIdTokenResult implements IdTokenResult {
  @override
  Map<String, dynamic>? get claims => {};

  @override
  String get token => 'fake-token';

  @override
  DateTime? get authTime => DateTime.now();

  @override
  DateTime? get expirationTime => DateTime.now().add(Duration(hours: 1));

  @override
  DateTime? get issuedAtTime => DateTime.now();

  @override
  String? get signInProvider => 'password';

  @override
  Map<String, dynamic>? get parameters => {};
}

// Custom mock untuk CollectionReference dengan tipe generic
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
])
// Jalankan: flutter pub run build_runner build

void main() {
  late ConcreteUserRepository repository;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUser = MockUser();

    // Setup collection reference
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);

    // Setup auth dengan mock user
    when(mockAuth.currentUser).thenReturn(mockUser);

    // Buat repository dengan mock
    repository = ConcreteUserRepository(
      auth: mockAuth,
      firestore: mockFirestore,
    );
  });

  tearDown(() {
    repository.dispose();
  });

  group('UserRepositoryBase', () {
    test('should initialize with Firebase instances', () {
      // Assert
      expect(repository.auth, equals(mockAuth));
      expect(repository.firestore, equals(mockFirestore));

      // Verify collection was initialized
      verify(mockFirestore.collection('users')).called(1);
    });

    test('validateUserAccess should do nothing when accessing own data', () {
      // Act & Assert - should not throw
      repository.validateUserAccess('test-user-id');

      // Verify
      verify(mockAuth.currentUser).called(1);
    });

    test('validateUserAccess should throw when not logged in', () {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.validateUserAccess('test-user-id'),
        throwsA(predicate(
          (e) => e is UserRepositoryException && e.code == 'unauthenticated',
        )),
      );
    });

    test('validateUserAccess should throw when accessing another user data',
        () {
      // Act & Assert
      expect(
        () => repository.validateUserAccess('another-user-id'),
        throwsA(predicate(
          (e) => e is UserRepositoryException && e.code == 'permission-denied',
        )),
      );
    });

    test('notifyUserChanged should add model to stream', () async {
      // Arrange
      final userModel = UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      // Capture events
      final events = <UserModel?>[];
      final subscription =
          repository.userChangesController.stream.listen(events.add);

      // Act
      repository.notifyUserChanged(userModel);

      // Wait for events
      await Future.delayed(Duration(milliseconds: 100));
      await subscription.cancel();

      // Assert
      expect(events, hasLength(1));
      expect(events.first?.uid, equals('test-user-id'));
    });

    test('dispose should close stream controller', () {
      // Act
      repository.dispose();

      // Assert
      expect(repository.userChangesController.isClosed, isTrue);
    });

    test('UserRepositoryException should format message with code', () {
      // Arrange
      final exception = UserRepositoryException(
        'Test message',
        code: 'test-code',
      );

      // Act
      final message = exception.toString();

      // Assert
      expect(message, contains('Test message'));
      expect(message, contains('test-code'));
    });
  });
}
