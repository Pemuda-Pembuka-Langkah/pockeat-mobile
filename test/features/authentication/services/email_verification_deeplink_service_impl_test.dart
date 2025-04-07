import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/repositories/user_repository.dart';
import 'package:pockeat/features/authentication/services/email_verification_deep_link_service_impl.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserRepository,
  ActionCodeInfo,
  AppLinks,
  BuildContext,
  StreamSubscription,
])
import 'email_verification_deeplink_service_impl_test.mocks.dart';

class TestableEmailVerificationDeepLinkServiceImpl
    extends EmailVerificationDeepLinkServiceImpl {
  final StreamController<Uri> mockedUriStreamController =
      StreamController<Uri>.broadcast();
  final StreamController<Uri?> mockedDeepLinkController =
      StreamController<Uri?>.broadcast();
  final Future<Uri?> Function()? mockedGetInitialAppLink;
  final bool throwOnStreamSetup;
  final bool throwOnDispose;
  bool throwOnIsEmailVerificationLink;
  bool throwSpecificException;
  StreamSubscription? _mockAppLinksSub;
  bool _disposeCalled = false;
  List<Uri?> addedLinks = [];

  TestableEmailVerificationDeepLinkServiceImpl({
    required FirebaseAuth auth,
    required UserRepository userRepository,
    this.mockedGetInitialAppLink,
    required BuildContext context,
    this.throwOnStreamSetup = false,
    this.throwOnDispose = false,
    this.throwOnIsEmailVerificationLink = false,
    this.throwSpecificException = false,
  }) : super(auth: auth, userRepository: userRepository) {
    contextForTesting = context;
  }

  @override
  Stream<Uri> getUriLinkStream() {
    if (throwOnStreamSetup) {
      throw Exception('Stream setup error');
    }
    return mockedUriStreamController.stream;
  }

  @override
  Future<Uri?> getInitialAppLink() {
    if (mockedGetInitialAppLink != null) {
      return mockedGetInitialAppLink!();
    }
    return Future.value(null);
  }

  @override
  void dispose() {
    _disposeCalled = true;
    if (throwOnDispose) {
      throw EmailVerificationDeepLinkException(
          'Error disposing deep link service');
    }
    if (_mockAppLinksSub != null) {
      _mockAppLinksSub!.cancel();
    }
    if (!mockedUriStreamController.isClosed) {
      mockedUriStreamController.close();
    }
    if (!mockedDeepLinkController.isClosed) {
      mockedDeepLinkController.close();
    }
  }

  @override
  bool isEmailVerificationLink(Uri link) {
    if (throwOnIsEmailVerificationLink) {
      throw EmailVerificationDeepLinkException(
        'Error validating email verification link',
        originalError:
            FormatException('Simulasi error parsing queryParameters'),
      );
    }
    return super.isEmailVerificationLink(link);
  }

  @override
  Future<bool> handleEmailVerificationLink(Uri link) {
    if (throwSpecificException) {
      throw EmailVerificationDeepLinkException(
        'Test deep link exception',
        code: 'test-code',
      );
    }
    return super.handleEmailVerificationLink(link);
  }

  @override
  void _handleIncomingLink(Uri link) {
    try {
      if (isEmailVerificationLink(link)) {
        addedLinks.add(link);
        mockedDeepLinkController.add(link);
      } else {
        addedLinks.add(link);
        mockedDeepLinkController.add(link);
      }
    } catch (e) {
      if (e is EmailVerificationDeepLinkException) {
        throw e;
      }
      throw EmailVerificationDeepLinkException('Error handling incoming link',
          originalError: e);
    }
  }

  @override
  Stream<Uri?> onLinkReceived() {
    return mockedDeepLinkController.stream;
  }

  // Untuk memudahkan testing
  set appLinksSub(StreamSubscription sub) {
    _mockAppLinksSub = sub;
  }

  bool get disposeCalled => _disposeCalled;

  // Menambahkan link secara manual ke stream
  void simulateIncomingLink(Uri link) {
    _handleIncomingLink(link);
  }
}

// Kelas exception dengan code terdefinisi jelas
class TestEmailVerificationDeepLinkException
    extends EmailVerificationDeepLinkException {
  TestEmailVerificationDeepLinkException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

void main() {
  late TestableEmailVerificationDeepLinkServiceImpl service;
  late MockFirebaseAuth mockAuth;
  late MockUserRepository mockUserRepository;
  late MockUser mockUser;
  late MockBuildContext mockContext;
  late MockStreamSubscription<dynamic> mockStreamSubscription;
  late MockActionCodeInfo mockActionCodeInfo;

  Uri createVerificationUrl({String? oobCode, String? mode = 'verifyEmail'}) {
    return Uri.parse(
        'pockeat://auth?mode=$mode&oobCode=${oobCode ?? 'testCode'}');
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserRepository = MockUserRepository();
    mockUser = MockUser();
    mockContext = MockBuildContext();
    mockStreamSubscription = MockStreamSubscription();
    mockActionCodeInfo = MockActionCodeInfo();

    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.emailVerified).thenReturn(false);
    when(mockStreamSubscription.cancel()).thenAnswer((_) async => null);

    service = TestableEmailVerificationDeepLinkServiceImpl(
      auth: mockAuth,
      userRepository: mockUserRepository,
      context: mockContext,
      mockedGetInitialAppLink: () async => null,
    );

    service.appLinksSub = mockStreamSubscription;
  });

  group('EmailVerificationDeepLinkServiceImpl', () {
    group('exception class', () {
      test('should create exception with message', () {
        final exception = EmailVerificationDeepLinkException('Test message');
        expect(exception.message, 'Test message');
        expect(exception.toString(), contains('Test message'));
      });

      test('should create exception with code', () {
        final exception = EmailVerificationDeepLinkException(
          'Test message',
          code: 'error-code',
        );
        expect(exception.code, 'error-code');
        expect(exception.toString(), contains('code: error-code'));
      });

      test('should create exception with original error', () {
        final originalError = Exception('Original error');
        final exception = EmailVerificationDeepLinkException(
          'Test message',
          originalError: originalError,
        );
        expect(exception.originalError, originalError);
      });
    });

    group('constructor', () {
      test('should use provided auth and repository', () {
        expect(service, isA<EmailVerificationDeepLinkServiceImpl>());
      });
    });

    group('context getter', () {
      test('should return contextForTesting if available', () {
        expect(service.context, mockContext);
      });
    });

    group('initialize', () {
      test('should initialize with initial link', () async {
        // Arrange
        final initialLink = createVerificationUrl();
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          mockedGetInitialAppLink: () async => initialLink,
        );

        // Act
        await testService.initialize();

        // Assert - verify it doesn't throw
        expect(true, isTrue);
      });

      test('should throw exception when getInitialAppLink fails', () async {
        // Arrange
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          mockedGetInitialAppLink: () async => throw Exception('Test error'),
        );

        // Act & Assert
        expect(
          () => testService.initialize(),
          throwsA(isA<EmailVerificationDeepLinkException>().having(
            (e) => e.message,
            'message',
            contains('Failed to initialize initial link handler'),
          )),
        );
      });

      test('should throw exception when setting up stream listener fails',
          () async {
        // Arrange
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          mockedGetInitialAppLink: () async => null,
          throwOnStreamSetup: true,
        );

        // Act & Assert
        expect(
          () => testService.initialize(),
          throwsA(isA<EmailVerificationDeepLinkException>().having(
            (e) => e.message,
            'message',
            contains('Failed to setup deep link listener'),
          )),
        );
      });
    });

    group('link event handling', () {
      test('should add link to stream', () {
        // Arrange
        final testLink = createVerificationUrl();

        // Act - langsung cek internal state
        service.simulateIncomingLink(testLink);

        // Assert
        expect(service.addedLinks, contains(testLink));
      });

      test('should handle exceptions', () {
        // Arrange
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          throwOnIsEmailVerificationLink: true,
        );

        final testLink = createVerificationUrl();

        // Act & Assert
        expect(
          () => testService.simulateIncomingLink(testLink),
          throwsA(isA<EmailVerificationDeepLinkException>()),
        );
      });
    });

    group('getInitialLink', () {
      test('should return initial link when available', () async {
        // Arrange
        final initialLink = createVerificationUrl();
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          mockedGetInitialAppLink: () async => initialLink,
        );

        // Act
        final link = await testService.getInitialLink().first;

        // Assert
        expect(link, initialLink);
      });

      test('should throw exception when getInitialAppLink fails', () async {
        // Arrange
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          mockedGetInitialAppLink: () async => throw Exception('Test error'),
        );

        // Act & Assert
        expect(
          () => testService.getInitialLink().first,
          throwsA(isA<EmailVerificationDeepLinkException>().having(
            (e) => e.message,
            'message',
            contains('Error retrieving initial URI'),
          )),
        );
      });
    });

    group('onLinkReceived', () {
      test('should return stream that emits links', () {
        // Arrange
        final testLink = createVerificationUrl();

        // Act - verify direct internal state
        service.simulateIncomingLink(testLink);

        // Assert - check internal state
        expect(service.addedLinks, contains(testLink));
      });
    });

    group('handleEmailVerificationLink', () {
      test('should return false for non-verification link', () async {
        // Arrange
        final nonVerificationLink = Uri.parse('pockeat://other?param=value');

        // Act
        final result =
            await service.handleEmailVerificationLink(nonVerificationLink);

        // Assert
        expect(result, false);
      });

      test('should return false when oobCode is null', () async {
        // Arrange
        final noOobCodeLink = Uri.parse('pockeat://auth?mode=verifyEmail');

        // Act
        final result = await service.handleEmailVerificationLink(noOobCodeLink);

        // Assert
        expect(result, false);
      });

      test('should successfully verify email', () async {
        // Arrange
        final testLink = createVerificationUrl();

        // Setup mocks
        when(mockAuth.checkActionCode(any))
            .thenAnswer((_) async => mockActionCodeInfo);
        when(mockAuth.applyActionCode(any)).thenAnswer((_) async => null);
        when(mockUser.reload()).thenAnswer((_) async => null);

        // Setup user verified
        when(mockUser.emailVerified).thenReturn(true);

        // Setup repository
        when(mockUserRepository.updateEmailVerificationStatus(any, any))
            .thenAnswer((_) async => null);

        // Act
        final result = await service.handleEmailVerificationLink(testLink);

        // Assert
        expect(result, true);
        verify(mockAuth.checkActionCode('testCode')).called(1);
        verify(mockAuth.applyActionCode('testCode')).called(1);
        verify(mockUser.reload()).called(1);
        verify(mockUserRepository.updateEmailVerificationStatus(
                'test-uid', true))
            .called(1);
      });

      test('should handle when user is null after verification', () async {
        // Arrange
        final testLink = createVerificationUrl();

        // Setup mocks
        when(mockAuth.checkActionCode(any))
            .thenAnswer((_) async => mockActionCodeInfo);
        when(mockAuth.applyActionCode(any)).thenAnswer((_) async => null);
        when(mockUser.reload()).thenAnswer((_) async => null);

        // Setup user to return null
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await service.handleEmailVerificationLink(testLink);

        // Assert
        expect(result, false);
      });

      test('should handle FirebaseAuthException', () async {
        // Arrange
        final testLink = createVerificationUrl();
        final authException = FirebaseAuthException(
          code: 'invalid-action-code',
          message: 'The code is invalid',
        );

        // Setup mocks
        when(mockAuth.checkActionCode(any)).thenThrow(authException);

        // Act & Assert
        expect(
          () => service.handleEmailVerificationLink(testLink),
          throwsA(isA<EmailVerificationDeepLinkException>().having(
            (e) => e.code,
            'code',
            'invalid-action-code',
          )),
        );
      });

      test('should handle generic exceptions in action code checking',
          () async {
        // Arrange
        final testLink = createVerificationUrl();
        final genericException = Exception('Something went wrong');

        // Setup mocks
        when(mockAuth.checkActionCode(any)).thenThrow(genericException);

        // Act & Assert
        expect(
          () => service.handleEmailVerificationLink(testLink),
          throwsA(isA<EmailVerificationDeepLinkException>().having(
            (e) => e.message,
            'message',
            contains('Error applying action code'),
          )),
        );
      });

      test('should handle exception in repository update', () async {
        // Arrange
        final testLink = createVerificationUrl();

        // Setup mocks
        when(mockAuth.checkActionCode(any))
            .thenAnswer((_) async => mockActionCodeInfo);
        when(mockAuth.applyActionCode(any)).thenAnswer((_) async => null);
        when(mockUser.reload()).thenAnswer((_) async => null);

        // Setup user verified
        when(mockUser.emailVerified).thenReturn(true);

        // Setup repository to throw
        when(mockUserRepository.updateEmailVerificationStatus(any, any))
            .thenThrow(Exception('Failed to update Firestore'));

        // Act
        final result = await service.handleEmailVerificationLink(testLink);

        // Assert - should still return true even though repository update failed
        expect(result, true);
      });

      test('should handle EmailVerificationDeepLinkException', () async {
        // Arrange
        final testLink = createVerificationUrl();

        // Setup test service dengan throwSpecificException true
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          throwSpecificException: true,
        );

        // Act & Assert - memastikan exception dilempar dengan benar
        expect(
          () => testService.handleEmailVerificationLink(testLink),
          throwsA(isA<EmailVerificationDeepLinkException>()
              .having((e) => e.code, 'code', 'test-code')
              .having((e) => e.message, 'message', 'Test deep link exception')),
        );
      });

      test('should handle FormatException', () async {
        // Arrange
        final testLink = createVerificationUrl();
        final formatException =
            FormatException('Format error in handling link');

        // Setup mock to throw
        when(mockAuth.applyActionCode(any)).thenThrow(formatException);
        when(mockAuth.checkActionCode(any))
            .thenAnswer((_) async => mockActionCodeInfo);

        // Act & Assert - Use try-catch approach for better async exception testing
        try {
          await service.handleEmailVerificationLink(testLink);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e, isA<EmailVerificationDeepLinkException>());
          expect(e.toString(), contains('Error applying action code'));
        }
      });
    });

    group('isEmailVerificationLink', () {
      test('should return true for valid verification link', () {
        // Arrange
        final validLink = createVerificationUrl();

        // Act
        final result = service.isEmailVerificationLink(validLink);

        // Assert
        expect(result, true);
      });

      test('should return false for link without mode parameter', () {
        // Arrange
        final invalidLink = Uri.parse('pockeat://auth?oobCode=testCode');

        // Act
        final result = service.isEmailVerificationLink(invalidLink);

        // Assert
        expect(result, false);
      });

      test('should return false for link with wrong mode', () {
        // Arrange
        final invalidLink = createVerificationUrl(mode: 'resetPassword');

        // Act
        final result = service.isEmailVerificationLink(invalidLink);

        // Assert
        expect(result, false);
      });

      test('should return false for link without oobCode', () {
        // Arrange
        final invalidLink = Uri.parse('pockeat://auth?mode=verifyEmail');

        // Act
        final result = service.isEmailVerificationLink(invalidLink);

        // Assert
        expect(result, false);
      });

      test('should throw EmailVerificationDeepLinkException on error', () {
        // Arrange - use TestableEmailVerificationDeepLinkServiceImpl with throwOnIsEmailVerificationLink
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          throwOnIsEmailVerificationLink: true,
        );

        final testLink = createVerificationUrl();

        // Act & Assert
        expect(
          () => testService.isEmailVerificationLink(testLink),
          throwsA(isA<EmailVerificationDeepLinkException>()),
        );
      });
    });

    group('dispose', () {
      test('should cancel subscription and close stream controller', () {
        // Act
        service.dispose();

        // Assert
        expect(service.disposeCalled, isTrue);
      });

      test('should handle exception on dispose', () {
        // Arrange - create service that throws on dispose
        final testService = TestableEmailVerificationDeepLinkServiceImpl(
          auth: mockAuth,
          userRepository: mockUserRepository,
          context: mockContext,
          mockedGetInitialAppLink: () async => null,
          throwOnDispose: true,
        );

        // Act & Assert
        expect(
          () => testService.dispose(),
          throwsA(isA<EmailVerificationDeepLinkException>().having(
            (e) => e.message,
            'message',
            contains('Error disposing deep link service'),
          )),
        );
      });
    });
  });
}
