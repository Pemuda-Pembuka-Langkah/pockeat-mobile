import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';
import 'package:pockeat/features/authentication/services/register_service_impl.dart';

// Implementasi mock sederhana untuk UserRepository
class FakeUserRepository implements UserRepository {
  bool emailRegistered = false;
  UserModel? savedUser;
  String? verifiedUserId;
  bool? verificationStatus;
  UserModel? profileUpdatedUser;
  Map<String, dynamic> profileUpdateData = {};

  @override
  Future<bool> isEmailAlreadyRegistered(String email) async {
    return emailRegistered;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    savedUser = user;
  }

  @override
  Future<void> updateEmailVerificationStatus(
      String userId, bool isVerified) async {
    verifiedUserId = userId;
    verificationStatus = isVerified;
  }

  @override
  Future<bool> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoURL,
    String? gender,
    DateTime? birthDate,
  }) async {
    profileUpdateData = {
      'userId': userId,
      'displayName': displayName,
      'photoURL': photoURL,
      'gender': gender,
      'birthDate': birthDate,
    };
    return true;
  }

  @override
  Stream<UserModel?> currentUserStream() {
    return Stream.value(
      UserModel(
        uid: 'test-user-id',
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return UserModel(
      uid: 'test-user-id',
      email: 'test@example.com',
      emailVerified: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    return UserModel(
      uid: userId,
      email: 'test@example.com',
      emailVerified: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Stream<UserModel?> userStream(String userId) {
    return Stream.value(
      UserModel(
        uid: userId,
        email: 'test@example.com',
        emailVerified: true,
        createdAt: DateTime.now(),
      ),
    );
  }
}

// Implementasi mock sederhana untuk FirebaseAuth
class FakeFirebaseAuth implements FirebaseAuth {
  FakeUser? _currentUser;
  bool throwAuthException = false;
  String? exceptionCode;

  @override
  User? get currentUser => _currentUser;

  void setCurrentUser(FakeUser? user) {
    _currentUser = user;
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (throwAuthException) {
      throw FirebaseAuthException(code: exceptionCode ?? 'unknown');
    }

    if (_currentUser == null) {
      _currentUser = FakeUser(
        uid: 'test-user-id',
        email: email,
        displayName: null,
        emailVerified: false,
      );
    }

    return FakeUserCredential(user: _currentUser!);
  }

  // Implementasi minimal yang diperlukan untuk pengujian
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

// Implementasi sederhana untuk User
class FakeUser implements User {
  final String _uid;
  final String _email;
  bool _emailVerified;
  String? _displayName;

  FakeUser({
    required String uid,
    required String email,
    required bool emailVerified,
    String? displayName,
  })  : _uid = uid,
        _email = email,
        _emailVerified = emailVerified,
        _displayName = displayName;

  @override
  String get uid => _uid;

  @override
  String get email => _email;

  @override
  bool get emailVerified => _emailVerified;

  @override
  String? get displayName => _displayName;

  @override
  Future<void> updateDisplayName(String? displayName) async {
    _displayName = displayName;
  }

  @override
  Future<void> sendEmailVerification(
      [ActionCodeSettings? actionCodeSettings]) async {
    // Simulasi pengiriman email
  }

  @override
  Future<void> reload() async {
    // Simulasi reload
  }

  void setEmailVerified(bool value) {
    _emailVerified = value;
  }

  // Implementasi minimal yang diperlukan untuk pengujian
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

// Implementasi sederhana untuk UserCredential
class FakeUserCredential implements UserCredential {
  @override
  final User user;

  FakeUserCredential({required this.user});

  // Implementasi minimal yang diperlukan untuk pengujian
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

void main() {
  late RegisterServiceImpl registerService;
  late FakeUserRepository fakeUserRepository;
  late FakeFirebaseAuth fakeFirebaseAuth;
  late FakeUser fakeUser;

  setUp(() {
    fakeUserRepository = FakeUserRepository();
    fakeFirebaseAuth = FakeFirebaseAuth();
    fakeUser = FakeUser(
      uid: 'test-user-id',
      email: 'test@example.com',
      emailVerified: false,
      displayName: null,
    );
    fakeFirebaseAuth.setCurrentUser(fakeUser);

    // Setup registerService dengan fake implementations
    registerService = RegisterServiceImpl(
      auth: fakeFirebaseAuth,
      userRepository: fakeUserRepository,
    );
  });

  group('RegisterService', () {
    test('register harus berhasil dengan input valid', () async {
      // Arrange
      const email = 'valid@example.com';
      const password = 'Password123';
      const displayName = 'Test User';

      // Act
      final result = await registerService.register(
        email: email,
        password: password,
        confirmPassword: password,
        termsAccepted: true,
        displayName: displayName,
      );

      // Assert
      expect(result, equals(RegisterResult.success));
      expect(fakeUserRepository.savedUser, isNotNull);
      expect(fakeUserRepository.savedUser?.email, equals(email));
    });

    test('register harus gagal jika email sudah terdaftar', () async {
      // Arrange
      const email = 'existing@example.com';
      const password = 'Password123';
      fakeUserRepository.emailRegistered = true;

      // Act
      final result = await registerService.register(
        email: email,
        password: password,
        confirmPassword: password,
        termsAccepted: true,
      );

      // Assert
      expect(result, equals(RegisterResult.emailAlreadyInUse));
      expect(fakeUserRepository.savedUser, isNull);
    });

    test('register harus gagal jika password tidak valid', () async {
      // Arrange
      const email = 'valid@example.com';
      const password = 'weak'; // Password terlalu lemah

      // Act
      final result = await registerService.register(
        email: email,
        password: password,
        confirmPassword: password,
        termsAccepted: true,
      );

      // Assert
      expect(result, equals(RegisterResult.weakPassword));
      expect(fakeUserRepository.savedUser, isNull);
    });

    test('sendEmailVerification harus berhasil', () async {
      // Act
      final result = await registerService.sendEmailVerification();

      // Assert
      expect(result, isTrue);
    });

    test('isEmailVerified harus berhasil dan update status di repository',
        () async {
      // Arrange
      fakeUser.setEmailVerified(true);

      // Act
      final result = await registerService.isEmailVerified();

      // Assert
      expect(result, isTrue);
      expect(fakeUserRepository.verifiedUserId, equals('test-user-id'));
      expect(fakeUserRepository.verificationStatus, isTrue);
    });

    test(
        'watchEmailVerificationStatus harus mengembalikan stream dari repository',
        () async {
      // Act
      final stream = registerService.watchEmailVerificationStatus();

      // Assert
      expect(await stream.first, isTrue);
    });

    test('updateUserProfile harus memanggil updateUserProfile di repository',
        () async {
      // Arrange
      final birthDate = DateTime(1990, 1, 1);

      // Act
      final result = await registerService.updateUserProfile(
        displayName: 'New Name',
        gender: 'male',
        birthDate: birthDate,
      );

      // Assert
      expect(result, isTrue);
      expect(fakeUserRepository.profileUpdateData['userId'],
          equals('test-user-id'));
      expect(fakeUserRepository.profileUpdateData['displayName'],
          equals('New Name'));
      expect(fakeUserRepository.profileUpdateData['gender'], equals('male'));
      expect(
          fakeUserRepository.profileUpdateData['birthDate'], equals(birthDate));
    });

    test('register harus menangani ketika firebase auth gagal', () async {
      // Arrange
      const email = 'valid@example.com';
      const password = 'Password123';
      fakeFirebaseAuth.throwAuthException = true;
      fakeFirebaseAuth.exceptionCode = 'operation-not-allowed';

      // Act
      final result = await registerService.register(
        email: email,
        password: password,
        confirmPassword: password,
        termsAccepted: true,
      );

      // Assert
      expect(result, equals(RegisterResult.operationNotAllowed));
    });

    test('isEmailVerified harus mengembalikan false ketika tidak ada user',
        () async {
      // Arrange
      fakeFirebaseAuth.setCurrentUser(null);

      // Act
      final result = await registerService.isEmailVerified();

      // Assert
      expect(result, isFalse);
      expect(fakeUserRepository.verifiedUserId, isNull);
      expect(fakeUserRepository.verificationStatus, isNull);
    });

    test('updateUserProfile harus mengembalikan false ketika tidak ada user',
        () async {
      // Arrange
      fakeFirebaseAuth.setCurrentUser(null);

      // Act
      final result = await registerService.updateUserProfile(
        displayName: 'New Name',
      );

      // Assert
      expect(result, isFalse);
      expect(fakeUserRepository.profileUpdateData.isEmpty, isTrue);
    });
  });
}
