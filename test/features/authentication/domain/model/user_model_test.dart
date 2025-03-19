import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

// Mock untuk Firebase User
class MockFirebaseUser extends Mock implements auth.User {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  String? get photoURL => 'https://example.com/photo.jpg';

  @override
  bool get emailVerified => false;
}

// Mock untuk DocumentSnapshot
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final Map<String, dynamic>? _data;

  MockDocumentSnapshot(this._data);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => 'test-uid';
}

void main() {
  group('UserModel', () {
    final mockFirebaseUser = MockFirebaseUser();
    final createdAt = DateTime(2023, 1, 1);
    final lastLoginAt = DateTime(2023, 1, 2);
    final birthDate = DateTime(1990, 1, 1);

    test('konstruktor harus membuat UserModel valid', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: true,
        gender: 'Pria',
        birthDate: birthDate,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );

      expect(user.uid, equals('test-uid'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.photoURL, equals('https://example.com/photo.jpg'));
      expect(user.emailVerified, isTrue);
      expect(user.gender, equals('Pria'));
      expect(user.birthDate, equals(birthDate));
      expect(user.createdAt, equals(createdAt));
      expect(user.lastLoginAt, equals(lastLoginAt));
    });

    test('fromFirebaseUser harus membuat UserModel dari Firebase User', () {
      final user = UserModel.fromFirebaseUser(
        mockFirebaseUser,
        gender: 'Pria',
        birthDate: birthDate,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );

      expect(user.uid, equals('test-uid'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.photoURL, equals('https://example.com/photo.jpg'));
      expect(user.emailVerified, isFalse);
      expect(user.gender, equals('Pria'));
      expect(user.birthDate, equals(birthDate));
      expect(user.createdAt, equals(createdAt));
      expect(user.lastLoginAt, equals(lastLoginAt));
    });

    test(
        'fromFirebaseUser harus menggunakan nilai default untuk createdAt dan lastLoginAt',
        () {
      final user = UserModel.fromFirebaseUser(
        mockFirebaseUser,
      );

      expect(user.createdAt, isNotNull);
      expect(user.lastLoginAt, isNotNull);
    });

    test('fromFirestore harus membuat UserModel dari DocumentSnapshot', () {
      final mockData = {
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoURL': 'https://example.com/photo.jpg',
        'emailVerified': true,
        'gender': 'Pria',
        'birthDate': Timestamp.fromDate(birthDate),
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      };

      final mockSnapshot = MockDocumentSnapshot(mockData);
      final user = UserModel.fromFirestore(mockSnapshot);

      expect(user.uid, equals('test-uid'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.photoURL, equals('https://example.com/photo.jpg'));
      expect(user.emailVerified, isTrue);
      expect(user.gender, equals('Pria'));
      expect(user.birthDate, equals(birthDate));
      expect(user.createdAt, equals(createdAt));
      expect(user.lastLoginAt, equals(lastLoginAt));
    });

    test('fromFirestore harus menangani nilai null dengan benar', () {
      final mockData = {
        'email': 'test@example.com',
        'emailVerified': false,
        'createdAt': Timestamp.fromDate(createdAt),
      };

      final mockSnapshot = MockDocumentSnapshot(mockData);
      final user = UserModel.fromFirestore(mockSnapshot);

      expect(user.displayName, isNull);
      expect(user.photoURL, isNull);
      expect(user.emailVerified, isFalse);
      expect(user.gender, isNull);
      expect(user.birthDate, isNull);
      expect(user.lastLoginAt, isNull);
    });

    test('fromFirestore harus menggunakan default untuk createdAt jika null',
        () {
      final mockData = {
        'email': 'test@example.com',
        'emailVerified': false,
      };

      final mockSnapshot = MockDocumentSnapshot(mockData);
      final user = UserModel.fromFirestore(mockSnapshot);

      expect(user.createdAt, isNotNull);
    });

    test('fromFirestore harus throw Exception jika data null', () {
      final mockSnapshot = MockDocumentSnapshot(null);

      expect(() => UserModel.fromFirestore(mockSnapshot), throwsException);
    });

    test('toMap harus mengkonversi UserModel ke Map', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: true,
        gender: 'Pria',
        birthDate: birthDate,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );

      final map = user.toMap();

      expect(map['email'], equals('test@example.com'));
      expect(map['displayName'], equals('Test User'));
      expect(map['photoURL'], equals('https://example.com/photo.jpg'));
      expect(map['emailVerified'], isTrue);
      expect(map['gender'], equals('Pria'));
      expect(map['birthDate'], isA<Timestamp>());
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['lastLoginAt'], isA<Timestamp>());

      expect((map['birthDate'] as Timestamp).toDate(), equals(birthDate));
      expect((map['createdAt'] as Timestamp).toDate(), equals(createdAt));
      expect((map['lastLoginAt'] as Timestamp).toDate(), equals(lastLoginAt));
    });

    test('toMap harus menangani nilai null dengan benar', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        emailVerified: false,
        createdAt: createdAt,
      );

      final map = user.toMap();

      expect(map['displayName'], isNull);
      expect(map['photoURL'], isNull);
      expect(map['gender'], isNull);
      expect(map['birthDate'], isNull);
      expect(map['lastLoginAt'], isNull);
    });

    test('copyWith harus membuat salinan dengan nilai yang diperbarui', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: false,
        gender: 'Pria',
        birthDate: birthDate,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );

      final updatedUser = user.copyWith(
        displayName: 'New Name',
        emailVerified: true,
        gender: 'Wanita',
      );

      expect(updatedUser.uid, equals('test-uid'));
      expect(updatedUser.email, equals('test@example.com'));
      expect(updatedUser.displayName, equals('New Name'));
      expect(updatedUser.photoURL, equals('https://example.com/photo.jpg'));
      expect(updatedUser.emailVerified, isTrue);
      expect(updatedUser.gender, equals('Wanita'));
      expect(updatedUser.birthDate, equals(birthDate));
      expect(updatedUser.createdAt, equals(createdAt));
      expect(updatedUser.lastLoginAt, equals(lastLoginAt));
    });

    test('copyWith harus mempertahankan nilai yang tidak diperbarui', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        emailVerified: false,
        gender: 'Pria',
        birthDate: birthDate,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );

      final updatedUser = user.copyWith();

      expect(updatedUser.uid, equals(user.uid));
      expect(updatedUser.email, equals(user.email));
      expect(updatedUser.displayName, equals(user.displayName));
      expect(updatedUser.photoURL, equals(user.photoURL));
      expect(updatedUser.emailVerified, equals(user.emailVerified));
      expect(updatedUser.gender, equals(user.gender));
      expect(updatedUser.birthDate, equals(user.birthDate));
      expect(updatedUser.createdAt, equals(user.createdAt));
      expect(updatedUser.lastLoginAt, equals(user.lastLoginAt));
    });

    test('toString harus mengembalikan string yang berisi informasi user', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
        createdAt: createdAt,
      );

      final string = user.toString();

      expect(string, contains('test-uid'));
      expect(string, contains('test@example.com'));
      expect(string, contains('Test User'));
      expect(string, contains('true'));
    });
  });
}
