import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, UserRepository, User])
import 'deep_link_service_impl_test.mocks.dart';

class MockAppLinks extends Mock implements AppLinks {
  final StreamController<Uri> _uriStreamController =
      StreamController<Uri>.broadcast();
  Uri? _initialLink;

  void addLink(Uri uri) {
    _uriStreamController.add(uri);
  }

  void setInitialLink(Uri? uri) {
    _initialLink = uri;
  }

  @override
  Future<Uri?> getInitialAppLink() async {
    return _initialLink;
  }

  @override
  Stream<Uri> get uriLinkStream => _uriStreamController.stream;
}

// Menggunakan class biasa bukan GlobalKey untuk menghindari masalah constructor
class FakeNavigatorKey {
  final NavigatorState _mockState = FakeNavigatorState();
  NavigatorState? get currentState => _mockState;
}

// Class sederhana untuk mock NavigatorState
class FakeNavigatorState implements NavigatorState {
  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    return null;
  }

  @override
  BuildContext get context => FakeBuildContext();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FakeNavigatorState';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Membuat fake ActionCodeInfo untuk testing
class FakeActionCodeInfo implements ActionCodeInfo {
  @override
  final ActionCodeInfoOperation operation;

  @override
  final Map<String, dynamic> data;

  // Override property setter
  @override
  set operation(ActionCodeInfoOperation _) => throw UnimplementedError();

  FakeActionCodeInfo({required this.operation, required this.data});
}

void main() {
  group('DeepLinkServiceImpl', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUserRepository mockUserRepository;
    late MockUser mockUser;
    late MockAppLinks mockAppLinks;
    late DeepLinkServiceImpl deepLinkService;
    late FakeNavigatorKey fakeNavigatorKey;

    Uri createVerificationUrl({String? oobCode}) {
      return Uri.parse(
          'pockeat://auth?mode=verifyEmail&oobCode=${oobCode ?? 'testCode'}');
    }

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUserRepository = MockUserRepository();
      mockUser = MockUser();
      mockAppLinks = MockAppLinks();
      fakeNavigatorKey = FakeNavigatorKey();

      // Setup deep link service dengan mocks
      deepLinkService = DeepLinkServiceImpl(
        auth: mockFirebaseAuth,
        userRepository: mockUserRepository,
      );

      // Default setup
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('testUid');
      when(mockUser.email).thenReturn('test@example.com');
    });

    group('isEmailVerificationLink', () {
      test('should identify valid email verification links', () {
        // Setup
        final validLink = createVerificationUrl();

        // Execute & Verify
        expect(deepLinkService.isEmailVerificationLink(validLink), true);
      });

      test('should reject links without required params', () {
        // Setup
        final invalid1 = Uri.parse('pockeat://auth?someparam=value');
        final invalid2 =
            Uri.parse('pockeat://auth?mode=verifyEmail'); // missing oobCode
        final invalid3 =
            Uri.parse('pockeat://auth?oobCode=testCode'); // missing mode
        final invalid4 = Uri.parse(
            'https://example.com?mode=verifyEmail&oobCode=testCode'); // wrong scheme

        // Execute & Verify
        expect(deepLinkService.isEmailVerificationLink(invalid1), false);
        expect(deepLinkService.isEmailVerificationLink(invalid2), false);
        expect(deepLinkService.isEmailVerificationLink(invalid3), false);
        expect(deepLinkService.isEmailVerificationLink(invalid4), false);
      });
    });

    group('handleEmailVerificationLink', () {
      test('should verify email successfully', () async {
        // Setup
        final testLink = createVerificationUrl();
        final actionCodeInfo = FakeActionCodeInfo(
          operation: ActionCodeInfoOperation.verifyEmail,
          data: {'email': 'test@example.com'},
        );

        when(mockFirebaseAuth.checkActionCode(any))
            .thenAnswer((_) async => actionCodeInfo);
        when(mockFirebaseAuth.applyActionCode(any)).thenAnswer((_) async {});
        when(mockUser.reload()).thenAnswer((_) async {});
        when(mockUser.emailVerified).thenReturn(true);
        when(mockUserRepository.updateEmailVerificationStatus(any, any))
            .thenAnswer((_) async {});

        // Execute
        final result =
            await deepLinkService.handleEmailVerificationLink(testLink);

        // Verify
        expect(result, true);
        verify(mockFirebaseAuth.checkActionCode('testCode')).called(1);
        verify(mockFirebaseAuth.applyActionCode('testCode')).called(1);
        verify(mockUser.reload()).called(1);
        verify(mockUserRepository.updateEmailVerificationStatus(
                'testUid', true))
            .called(1);
      });

      test('should handle missing oobCode', () async {
        // Setup
        final invalidLink = Uri.parse('pockeat://auth?mode=verifyEmail');

        // Execute
        final result =
            await deepLinkService.handleEmailVerificationLink(invalidLink);

        // Verify
        expect(result, false);
      });

      test('should handle invalid verification link', () async {
        // Setup
        final invalidLink = Uri.parse('pockeat://something-else');

        // Execute
        final result =
            await deepLinkService.handleEmailVerificationLink(invalidLink);

        // Verify
        expect(result, false);
      });

      test('should handle Firebase auth exceptions', () async {
        // Setup
        final testLink = createVerificationUrl();
        when(mockFirebaseAuth.checkActionCode(any))
            .thenThrow(FirebaseAuthException(code: 'invalid-action-code'));

        // Execute
        final result =
            await deepLinkService.handleEmailVerificationLink(testLink);

        // Verify
        expect(result, false);
      });

      test('should handle Firestore update failure but still return success',
          () async {
        // Setup
        final testLink = createVerificationUrl();
        final actionCodeInfo = FakeActionCodeInfo(
          operation: ActionCodeInfoOperation.verifyEmail,
          data: {'email': 'test@example.com'},
        );

        when(mockFirebaseAuth.checkActionCode(any))
            .thenAnswer((_) async => actionCodeInfo);
        when(mockFirebaseAuth.applyActionCode(any)).thenAnswer((_) async {});
        when(mockUser.reload()).thenAnswer((_) async {});
        when(mockUser.emailVerified).thenReturn(true);
        when(mockUserRepository.updateEmailVerificationStatus(any, any))
            .thenThrow(Exception('Firestore error'));

        // Execute
        final result =
            await deepLinkService.handleEmailVerificationLink(testLink);

        // Verify - should still return true even if Firestore update fails
        expect(result, true);
      });

      test('should handle case when user is null', () async {
        // Setup
        final testLink = createVerificationUrl();
        final actionCodeInfo = FakeActionCodeInfo(
          operation: ActionCodeInfoOperation.verifyEmail,
          data: {'email': 'test@example.com'},
        );

        when(mockFirebaseAuth.currentUser).thenReturn(null);
        when(mockFirebaseAuth.checkActionCode(any))
            .thenAnswer((_) async => actionCodeInfo);
        when(mockFirebaseAuth.applyActionCode(any)).thenAnswer((_) async {});

        // Execute
        final result =
            await deepLinkService.handleEmailVerificationLink(testLink);

        // Verify - should return false if user is null
        expect(result, false);
        verify(mockFirebaseAuth.checkActionCode('testCode')).called(1);
        verify(mockFirebaseAuth.applyActionCode('testCode')).called(1);
        verifyNever(mockUserRepository.updateEmailVerificationStatus(any, any));
      });

      test('should handle case when email is not verified', () async {
        // Setup
        final testLink = createVerificationUrl();
        final actionCodeInfo = FakeActionCodeInfo(
          operation: ActionCodeInfoOperation.verifyEmail,
          data: {'email': 'test@example.com'},
        );

        when(mockFirebaseAuth.checkActionCode(any))
            .thenAnswer((_) async => actionCodeInfo);
        when(mockFirebaseAuth.applyActionCode(any)).thenAnswer((_) async {});
        when(mockUser.reload()).thenAnswer((_) async {});
        when(mockUser.emailVerified).thenReturn(false);

        // Execute
        final result =
            await deepLinkService.handleEmailVerificationLink(testLink);

        // Verify - should return false if email is not verified
        expect(result, false);
        verify(mockFirebaseAuth.checkActionCode('testCode')).called(1);
        verify(mockFirebaseAuth.applyActionCode('testCode')).called(1);
        verify(mockUser.reload()).called(1);
        verifyNever(mockUserRepository.updateEmailVerificationStatus(any, any));
      });

      test('should handle case when operation is not verifyEmail', () async {
        // Setup
        final testLink = createVerificationUrl();
        final actionCodeInfo = FakeActionCodeInfo(
          operation: ActionCodeInfoOperation.passwordReset,
          data: {'email': 'test@example.com'},
        );

        when(mockFirebaseAuth.checkActionCode(any))
            .thenAnswer((_) async => actionCodeInfo);
        // Pastikan currentUser tidak dipanggil
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Execute
        final result =
            await deepLinkService.handleEmailVerificationLink(testLink);

        // Verify - should return false if operation is not verifyEmail
        expect(result, false);
        verify(mockFirebaseAuth.checkActionCode('testCode')).called(1);
        // Jangan verifikasi panggilan lain karena implementasi mungkin berbeda
      });
    });

    group('onLinkReceived', () {
      test('should return a stream', () async {
        // Memastikan bahwa method mengembalikan Stream
        expect(deepLinkService.onLinkReceived(), isA<Stream<Uri?>>());
      });
    });

    test('dispose should complete without errors', () {
      // Memastikan dispose berjalan tanpa error
      expect(() => deepLinkService.dispose(), returnsNormally);
    });
  });
}
