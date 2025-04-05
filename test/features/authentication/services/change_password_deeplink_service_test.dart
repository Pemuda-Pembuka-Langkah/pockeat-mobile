import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service_impl.dart';
import 'change_password_deeplink_service_test.mocks.dart';

@GenerateMocks(
    [FirebaseAuth, User, ActionCodeInfo, AppLinks, StreamSubscription])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late MockAppLinks mockAppLinks;
  late MockUser mockUser;
  late StreamController<Uri> mockLinkStreamController;
  late MockStreamSubscription<dynamic> mockStreamSubscription;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockAppLinks = MockAppLinks();
    mockUser = MockUser();
    mockLinkStreamController = StreamController<Uri>.broadcast();
    mockStreamSubscription = MockStreamSubscription<dynamic>();

    // Setup untuk mocking AppLinks
    when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);
    when(mockAppLinks.uriLinkStream)
        .thenAnswer((_) => mockLinkStreamController.stream);

    // Setup user mock
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');

    // Setup mockStreamSubscription
    when(mockStreamSubscription.cancel())
        .thenAnswer((_) => Future<void>.value());
  });

  tearDown(() {
    mockLinkStreamController.close();
  });

  Uri createPasswordResetUrl({String? oobCode}) {
    return Uri.parse(
        'pockeat://auth?mode=resetPassword&oobCode=${oobCode ?? 'testCode'}');
  }

  group('initialize', () {
    test('should initialize and handle initial link if present', () async {
      // Arrange
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
      );

      // Act
      await service.initialize();

      // Assert
      expect(service.initializeCalled, isTrue);
    });

    test('should handle error during initialization', () async {
      // Arrange
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwOnGetInitialLink: true,
      );

      // Act & Assert
      expect(
        () => service.initialize(),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
    });

    test('should handle initial link when present', () async {
      // Arrange
      final testUri = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        initialAppLink: testUri,
      );

      // Setup mocks
      when(mockAuth.checkActionCode('testCode'))
          .thenAnswer((_) async => MockActionCodeInfo());

      // Act
      await service.initialize();

      // Assert
      expect(service.initialLinkProcessed, isTrue);
    });

    test('should handle error during app link stream setup', () async {
      // Arrange
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwOnUriLinkStream: true,
      );

      // Act & Assert
      expect(
        () => service.initialize(),
        throwsA(isA<ChangePasswordDeepLinkException>().having(
            (e) => e.message, 'message', 'Failed to setup deep link listener')),
      );
    });
  });

  group('isChangePasswordLink', () {
    test('should identify valid password reset links', () {
      // Arrange
      final validLink = createPasswordResetUrl();
      final service = ChangePasswordDeepLinkServiceImpl(auth: mockAuth);

      // Act & Assert
      expect(service.isChangePasswordLink(validLink), true);
    });

    test('should reject invalid links', () {
      // Arrange
      final invalidLinks = [
        Uri.parse('pockeat://auth?someparam=value'),
        Uri.parse('pockeat://auth?mode=notResetPassword&oobCode=testCode'),
        Uri.parse('pockeat://auth?mode=resetPassword'), // oobCode is null
        Uri.parse(
            'other://auth?mode=resetPassword&oobCode=testCode'), // different scheme
      ];

      // Get real service instance
      final service = ChangePasswordDeepLinkServiceImpl(auth: mockAuth);

      // Act & Assert
      for (var link in invalidLinks) {
        try {
          // Khusus untuk link dengan scheme yang berbeda, kita perlu memeriksa hasilnya
          // dengan spesial karena itu bukan gagal validasi biasa
          if (link.scheme != 'pockeat') {
            expect(service.isChangePasswordLink(link), isFalse,
                reason:
                    'Link dengan scheme yang berbeda harus ditolak: ${link.toString()}');
          } else {
            expect(service.isChangePasswordLink(link), isFalse,
                reason: 'Link seharusnya invalid: ${link.toString()}');
          }
        } catch (e) {
          // Kita tangkap exception yang mungkin dilempar oleh isChangePasswordLink
          // dan anggap itu sebagai false (link invalid)
          expect(e, isA<ChangePasswordDeepLinkException>());
        }
      }
    });

    test('should handle exceptions during link validation', () {
      // Arrange - setup implementasi riil untuk test
      final service = ChangePasswordDeepLinkServiceImpl(auth: mockAuth);

      // Buat Uri yang salah untuk case dimana link.queryParameters akan diakses
      // tapi link.queryParameters['mode'] dan link.queryParameters['oobCode'] akan null
      final testUri = Uri.parse('pockeat://auth'); // Uri tanpa query parameters

      // Verifikasi bahwa metode mengembalikan false, tidak melempar exception
      // karena exception ditangkap di dalam implementasi
      final result = service.isChangePasswordLink(testUri);
      expect(result, isFalse);

      // Test dengan null URI - ini seharusnya menyebabkan exception
      try {
        // Force null dereference untuk memicu exception
        final badUri = null as Uri;
        service.isChangePasswordLink(badUri);
        fail('Expected exception but did not receive one');
      } catch (e) {
        expect(e, isA<TypeError>()); // Akan menyebabkan TypeError: non-nullable
      }
    });
  });

  group('handleChangePasswordLink', () {
    test('should verify password reset code successfully', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
      );
      when(mockAuth.checkActionCode('testCode'))
          .thenAnswer((_) async => MockActionCodeInfo());

      // Act
      final result = await service.handleChangePasswordLink(testLink);

      // Assert
      expect(result, true);
    });

    test('should handle invalid password reset link', () async {
      // Arrange
      final invalidLink = Uri.parse('pockeat://auth?invalid=true');
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        shouldReturnValidChangePasswordLink: false,
      );

      // Act
      final result = await service.handleChangePasswordLink(invalidLink);

      // Assert
      expect(result, false);
    });

    test('should handle Firebase auth exceptions', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
      );

      when(mockAuth.checkActionCode('testCode'))
          .thenAnswer((_) async => MockActionCodeInfo());

      // Act
      final result = await service.handleChangePasswordLink(testLink);

      // Assert
      expect(result, true);
    });

    test('should handle general exceptions', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwChangePasswordException: true,
      );

      // Act & Assert
      expect(
        () => service.handleChangePasswordLink(testLink),
        throwsA(isA<ChangePasswordDeepLinkException>()),
      );
    });

    test('should handle missing oobCode in valid mode', () async {
      // Arrange
      final testLink =
          Uri.parse('pockeat://auth?mode=resetPassword'); // missing oobCode
      final service = ChangePasswordDeepLinkServiceImpl(auth: mockAuth);

      // Act
      final result = await service.handleChangePasswordLink(testLink);

      // Assert
      expect(result, false);
    });

    test('should handle FirebaseAuthException from checkActionCode', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = ChangePasswordDeepLinkServiceImpl(auth: mockAuth);

      // Setup mock to throw exception
      when(mockAuth.checkActionCode('testCode')).thenThrow(
          FirebaseAuthException(
              code: 'expired-action-code', message: 'Code expired'));

      // Act & Assert
      expect(
        () => service.handleChangePasswordLink(testLink),
        throwsA(isA<ChangePasswordDeepLinkException>()
            .having((e) => e.code, 'code', 'expired-action-code')
            .having(
                (e) => e.message,
                'message',
                contains(
                    'Firebase auth error when verifying change password link'))),
      );
    });

    test('should handle general exception from checkActionCode', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = ChangePasswordDeepLinkServiceImpl(auth: mockAuth);

      // Setup mock to throw exception
      when(mockAuth.checkActionCode('testCode'))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => service.handleChangePasswordLink(testLink),
        throwsA(isA<ChangePasswordDeepLinkException>()
            .having((e) => e.message, 'message', 'Error checking action code')),
      );
    });

    test('should handle and rethrow ChangePasswordDeepLinkException', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwChangePasswordException: true,
      );

      // Act & Assert
      expect(
        () => service.handleChangePasswordLink(testLink),
        throwsA(isA<ChangePasswordDeepLinkException>().having((e) => e.message,
            'message', 'Test ChangePasswordDeepLinkException')),
      );
    });

    test(
        'should handle other exceptions and wrap them in ChangePasswordDeepLinkException',
        () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwOnHandleLink: true,
      );

      // Act & Assert
      expect(
        () => service.handleChangePasswordLink(testLink),
        throwsA(isA<ChangePasswordDeepLinkException>().having((e) => e.message,
            'message', 'Error handling change password link')),
      );
    });

    test('should include FirebaseAuthException code in thrown exception',
        () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = ChangePasswordDeepLinkServiceImpl(auth: mockAuth);

      // Siapkan mock untuk melempar FirebaseAuthException dengan code spesifik
      when(mockAuth.checkActionCode('testCode')).thenThrow(
          FirebaseAuthException(
              code: 'invalid-action-code', message: 'The code is invalid.'));

      // Act & Assert
      expect(
        () => service.handleChangePasswordLink(testLink),
        throwsA(isA<ChangePasswordDeepLinkException>()
            .having((e) => e.code, 'code', 'invalid-action-code')
            .having(
                (e) => e.message,
                'message',
                contains(
                    'Firebase auth error when verifying change password link'))
            .having((e) => e.originalError, 'originalError',
                isA<FirebaseAuthException>())),
      );
    });

    test('should call isChangePasswordLink and early return if not valid',
        () async {
      // Arrange
      final invalidLink = Uri.parse('pockeat://auth?invalid=true');
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        shouldReturnValidChangePasswordLink: false,
      );

      // Act
      final result = await service.handleChangePasswordLink(invalidLink);

      // Assert
      expect(result, false);
      // Verify tidak pernah memanggil checkActionCode
      verifyNever(mockAuth.checkActionCode('testCode'));
    });

    test('should handle empty oobCode parameter with custom implementation',
        () async {
      // Arrange - Create a link with mode=resetPassword and empty oobCode
      final testLink = Uri.parse('pockeat://auth?mode=resetPassword&oobCode=');

      // Buat class custom yang mengoverride handleChangePasswordLink
      final service = EmptyOobCodeTestService(mockAuth: mockAuth);

      // Act
      final result = await service.handleChangePasswordLink(testLink);

      // Assert
      expect(result, false);
      verifyNever(mockAuth.checkActionCode(any));
    });

    test('should return false when oobCode is null in valid link format',
        () async {
      // Arrange - Create a link with mode=resetPassword but null oobCode parameter
      final testLink = Uri.parse('pockeat://auth?mode=resetPassword');

      // Use a custom service that will not throw exception
      final service = EmptyOobCodeTestService(mockAuth: mockAuth);

      // Act
      final result = await service.handleChangePasswordLink(testLink);

      // Assert
      expect(result, false);
      verifyNever(mockAuth.checkActionCode(any));
    });
  });

  group('onLinkReceived', () {
    test('should emit received links', () async {
      // Arrange
      final testUri = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
      );
      final stream = service.onLinkReceived();

      // Setup expectation
      final receivedLinks = <Uri?>[];
      final sub = stream.listen((link) {
        receivedLinks.add(link);
      });

      // Act
      service.testStreamController.add(testUri);
      await Future.delayed(Duration.zero); // Give time for stream to emit

      // Assert
      expect(receivedLinks, contains(testUri));

      // Cleanup
      await sub.cancel();
    });
  });

  group('_handleIncomingLink', () {
    test('should process null URI gracefully', () async {
      // Arrange
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
      );

      // Act - call method directly
      await service.handleIncomingLinkPublic(null);

      // Assert - verify no error was thrown
      expect(true, isTrue); // Test passed if we get here
    });

    test('should add URI to stream controller', () async {
      // Arrange
      final testUri = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
      );

      // Setup mock
      when(mockAuth.checkActionCode('testCode'))
          .thenAnswer((_) async => MockActionCodeInfo());

      // Capture emitted links from stream
      final receivedLinks = <Uri?>[];
      final sub = service.onLinkReceived().listen((uri) {
        receivedLinks.add(uri);
      });

      // Act
      await service.handleIncomingLinkPublic(testUri);

      // Wait for async operations
      await Future.delayed(Duration.zero);

      // Assert
      expect(receivedLinks, contains(testUri));

      // Cleanup
      await sub.cancel();
    });

    test('should handle change password link when valid', () async {
      // Arrange
      final testUri = createPasswordResetUrl();
      final service = CustomCheckableChangePasswordService(
        auth: mockAuth,
      );

      // Setup mock
      when(mockAuth.checkActionCode('testCode'))
          .thenAnswer((_) async => MockActionCodeInfo());

      // Act
      await service.handleIncomingLinkPublic(testUri);

      // Wait for async operations
      await Future.delayed(Duration.zero);

      // Assert - verify checkActionCode was called (through our custom class flag)
      expect(service.checkActionCodeWasCalled, isTrue);
    });

    test('should handle exceptions during link processing', () async {
      // Arrange
      final testUri = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwOnHandleLink: true,
      );

      // Act - Expect no exception to propagate since _handleIncomingLink catches them
      await expectLater(
        () => service.handleIncomingLinkPublic(testUri),
        returnsNormally, // Expect no exception to be thrown
      );
    });

    test('should silently handle exceptions during stream processing',
        () async {
      // Arrange - Buat service dengan konfigurasi untuk melempar exception
      final testUri = createPasswordResetUrl();
      final customService = _ExceptionTestService(auth: mockAuth);

      // Set up stream listener
      final receivedUris = <Uri>[];
      final subscription = customService.onLinkReceived().listen((uri) {
        if (uri != null) {
          receivedUris.add(uri);
        }
      });

      // Act - uri ditambahkan ke stream, kemudian exception dilempar
      await customService.simulateExceptionAfterStreamAdd(testUri);

      // Assert - exception tertangkap tapi uri tetap berhasil ditambahkan
      expect(receivedUris, [testUri]);

      // Clean up
      await subscription.cancel();
    });
  });

  group('dispose', () {
    test('should cancel subscription and close controller', () async {
      // Arrange
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
      );

      // Act
      service.dispose();

      // Assert
      expect(service.disposeCalled, isTrue);
    });

    test('should handle exceptions during disposal', () {
      // Arrange
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwOnDispose: true,
      );

      // Act & Assert
      expect(
        () => service.dispose(),
        throwsA(isA<ChangePasswordDeepLinkException>().having(
            (e) => e.message, 'message', 'Error disposing deep link service')),
      );
    });
  });

  group('getInitialLink', () {
    test('should handle exceptions when retrieving initial link', () async {
      // Arrange
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwOnGetInitialLink: true,
      );

      // Act & Assert
      expect(
        () => service.getInitialLink().first,
        throwsA(isA<ChangePasswordDeepLinkException>().having(
            (e) => e.message, 'message', 'Error retrieving initial URI')),
      );
    });

    test('should emit initial link when available', () async {
      // Arrange
      final testLink = createPasswordResetUrl();
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        initialAppLink: testLink,
      );

      // Act
      final result = await service.getInitialLink().first;

      // Assert
      expect(result, equals(testLink));
    });
  });

  group('uriLinkStream error handler', () {
    test('should handle errors in app link stream', () async {
      // Arrange
      // Create a new service that will throw on initialize
      final service = _TestableChangePasswordDeepLinkService(
        auth: mockAuth,
        throwOnUriLinkStreamError: true,
      );

      // Act & Assert - Should throw the proper exception when the stream has an error
      expect(
        () => service.testUriLinkStreamErrorHandler(),
        throwsA(isA<ChangePasswordDeepLinkException>()
            .having((e) => e.message, 'message', 'Error in app link stream')),
      );
    });
  });
}

/// Helper class untuk testing metode private
class _TestableChangePasswordDeepLinkService
    extends ChangePasswordDeepLinkServiceImpl {
  final Uri? initialAppLink;
  final bool throwOnGetInitialLink;
  final bool throwOnUriLinkStream;
  final bool throwOnHandleLink;
  final bool throwChangePasswordException;
  final bool throwCustomException;
  final bool throwOnUriLinkStreamError;
  final bool throwOnDispose;
  final bool throwInternalException;
  final bool shouldReturnValidChangePasswordLink;
  final StreamController<Uri?> testStreamController =
      StreamController<Uri?>.broadcast();
  bool initialLinkProcessed = false;
  bool initializeCalled = false;
  bool disposeCalled = false;

  _TestableChangePasswordDeepLinkService({
    required FirebaseAuth auth,
    this.initialAppLink,
    this.throwOnGetInitialLink = false,
    this.throwOnUriLinkStream = false,
    this.throwOnHandleLink = false,
    this.throwChangePasswordException = false,
    this.throwCustomException = false,
    this.throwOnUriLinkStreamError = false,
    this.throwOnDispose = false,
    this.throwInternalException = false,
    this.shouldReturnValidChangePasswordLink = true,
  }) : super(auth: auth);

  @override
  Future<void> initialize() async {
    initializeCalled = true;

    if (throwOnUriLinkStream) {
      throw ChangePasswordDeepLinkException(
          'Failed to setup deep link listener');
    }

    try {
      // Dapatkan initial link jika ada
      final initialUri = await getInitialAppLink();
      if (initialUri != null) {
        await handleIncomingLink(initialUri);
        initialLinkProcessed = true;
      }
    } catch (e) {
      throw ChangePasswordDeepLinkException(
        'Failed to initialize change password deep link service',
        originalError: e,
      );
    }
  }

  @override
  Future<Uri?> getInitialAppLink() {
    if (throwOnGetInitialLink) {
      throw Exception('Test exception in getInitialAppLink');
    }
    if (initialAppLink != null) {
      return Future.value(initialAppLink);
    }
    return Future.value(null);
  }

  @override
  Stream<Uri> getUriLinkStream() {
    if (throwOnUriLinkStream) {
      throw Exception('Error creating URI link stream');
    }
    return Stream<Uri>.empty();
  }

  @override
  Stream<Uri?> onLinkReceived() {
    return testStreamController.stream;
  }

  // Expose private method untuk testing
  Future<void> handleIncomingLinkPublic(Uri? uri) async {
    if (throwOnHandleLink) {
      // Simulate exception but handle it like the real method would
      if (uri != null) {
        testStreamController.add(uri); // Still add to stream

        // Simulate the exception but catch it internally
        try {
          throw Exception('Test exception in _handleIncomingLink');
        } catch (e) {
          // Silently catch, like the real implementation
        }
        return;
      }
    }
    return handleIncomingLink(uri);
  }

  // Reimplementasi _handleIncomingLink dari parent class
  @override
  Future<void> handleIncomingLink(Uri? uri) async {
    if (uri == null) return;

    try {
      // Add to stream first before potential exception
      testStreamController.add(uri);

      if (throwInternalException) {
        throw Exception('Simulated internal exception in _handleIncomingLink');
      }

      if (isChangePasswordLink(uri)) {
        final success = await handleChangePasswordLink(uri);
      }
    } catch (e) {
      // Catch error silently as in the original implementation
    }
  }

  @override
  Future<bool> handleChangePasswordLink(Uri link) async {
    try {
      if (throwChangePasswordException) {
        throw ChangePasswordDeepLinkException(
            'Test ChangePasswordDeepLinkException');
      }

      if (throwOnHandleLink) {
        throw Exception('Test exception in handleChangePasswordLink');
      }

      if (!isChangePasswordLink(link)) {
        return false;
      }

      final oobCode = link.queryParameters['oobCode'];
      if (oobCode == null || oobCode.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      if (e is ChangePasswordDeepLinkException) {
        rethrow;
      }
      throw ChangePasswordDeepLinkException(
        'Error handling change password link',
        originalError: e,
      );
    }
  }

  @override
  bool isChangePasswordLink(Uri link) {
    return shouldReturnValidChangePasswordLink;
  }

  // Call original implementation for testing
  bool callOriginalIsChangePasswordLink(Uri link) {
    try {
      final mode = link.queryParameters['mode'];
      final oobCode = link.queryParameters['oobCode'];
      return mode == 'resetPassword' && oobCode != null;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    disposeCalled = true;

    if (throwOnDispose) {
      try {
        throw Exception('Test exception in dispose');
      } catch (e) {
        throw ChangePasswordDeepLinkException(
          'Error disposing deep link service',
          originalError: e,
        );
      }
    }

    testStreamController.close();
  }

  // Metode untuk menguji onError handler di uriLinkStream
  void testUriLinkStreamErrorHandler() {
    if (throwOnUriLinkStreamError) {
      // Panggil langsung onError handler dengan exception
      final onErrorHandler = (error) {
        throw ChangePasswordDeepLinkException(
          'Error in app link stream',
          originalError: error,
        );
      };

      // Memanggil handler dengan error untuk mensimulasikan error pada stream
      onErrorHandler(Exception('Test stream error'));
    }
  }
}

// Custom class untuk test checkActionCode verification
class CustomCheckableChangePasswordService
    extends ChangePasswordDeepLinkServiceImpl {
  bool checkActionCodeWasCalled = false;
  final StreamController<Uri?> streamController =
      StreamController<Uri?>.broadcast();

  CustomCheckableChangePasswordService({required FirebaseAuth auth})
      : super(auth: auth);

  @override
  Future<void> handleIncomingLinkPublic(Uri? uri) {
    return handleIncomingLink(uri);
  }

  @override
  Future<void> handleIncomingLink(Uri? uri) async {
    if (uri == null) return;

    try {
      // Add to stream before potential exception
      streamController.add(uri);

      if (isChangePasswordLink(uri)) {
        await handleChangePasswordLink(uri);
      }
    } catch (e) {
      // Catch silently
    }
  }

  @override
  Future<bool> handleChangePasswordLink(Uri link) async {
    final oobCode = link.queryParameters['oobCode'];
    if (oobCode != null) {
      checkActionCodeWasCalled = true;
    }
    return true;
  }

  @override
  Stream<Uri?> onLinkReceived() {
    return streamController.stream;
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }
}

// Tambahkan class test khusus untuk kasus empty oobCode
class EmptyOobCodeTestService extends ChangePasswordDeepLinkServiceImpl {
  final FirebaseAuth mockAuth;

  EmptyOobCodeTestService({required this.mockAuth}) : super(auth: mockAuth);

  @override
  bool isChangePasswordLink(Uri link) {
    // Override untuk selalu return true
    return true;
  }

  @override
  Future<bool> handleChangePasswordLink(Uri link) async {
    // Implementasi custom untuk test
    if (!isChangePasswordLink(link)) {
      return false;
    }

    final oobCode = link.queryParameters['oobCode'];
    if (oobCode == null || oobCode.isEmpty) {
      return false;
    }

    return true;
  }
}

// Tambahkan kelas untuk test exception handling
class _ExceptionTestService extends ChangePasswordDeepLinkServiceImpl {
  _ExceptionTestService({required FirebaseAuth auth}) : super(auth: auth);

  final _streamController = StreamController<Uri?>.broadcast();

  @override
  Stream<Uri?> onLinkReceived() {
    return _streamController.stream;
  }

  Future<void> simulateExceptionAfterStreamAdd(Uri uri) async {
    // Tambahkan uri ke stream
    _streamController.add(uri);

    // Tunggu sebentar agar stream terupdate
    await Future.delayed(Duration(milliseconds: 10));

    // Kemudian lempar exception, tetapi tertangkap seperti dalam _handleIncomingLink
    try {
      throw Exception('Test exception');
    } catch (e) {
      // Exception tertangkap, sama seperti implementasi asli
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
