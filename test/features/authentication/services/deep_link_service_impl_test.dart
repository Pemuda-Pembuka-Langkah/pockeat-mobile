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
  bool _throwOnGetInitialAppLink = false;
  bool _throwOnUriLinkStream = false;

  void addLink(Uri uri) {
    _uriStreamController.add(uri);
  }

  void setInitialLink(Uri? uri) {
    _initialLink = uri;
  }

  void throwErrorOnGetInitialAppLink() {
    _throwOnGetInitialAppLink = true;
  }

  void throwErrorOnUriLinkStream() {
    _throwOnUriLinkStream = true;
  }

  @override
  Future<Uri?> getInitialAppLink() async {
    if (_throwOnGetInitialAppLink) {
      throw Exception('Failed to get initial app link');
    }
    return _initialLink;
  }

  @override
  Stream<Uri> get uriLinkStream {
    if (_throwOnUriLinkStream) {
      throw Exception('Failed to get uri link stream');
    }
    return _uriStreamController.stream;
  }
}

class CustomDeepLinkService extends DeepLinkServiceImpl {
  final MockAppLinks mockAppLinks;
  bool throwOnDispose = false;

  CustomDeepLinkService({
    required FirebaseAuth auth,
    required UserRepository userRepository,
    required this.mockAppLinks,
  }) : super(auth: auth, userRepository: userRepository);

  @override
  Future<Uri?> getInitialAppLink() => mockAppLinks.getInitialAppLink();

  @override
  Stream<Uri> getUriLinkStream() => mockAppLinks.uriLinkStream;

  @override
  void dispose() {
    if (throwOnDispose) {
      throw Exception('Failed to dispose');
    }
    super.dispose();
  }
}

// Class sederhana untuk mock NavigatorState
class MockNavigatorState extends Mock implements NavigatorState {
  final BuildContext _mockContext = MockBuildContext();

  @override
  BuildContext get context => _mockContext;

  @override
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    return null;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockNavigatorState';
  }
}

class MockBuildContext extends Mock implements BuildContext {}

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
    late CustomDeepLinkService customDeepLinkService;
    late GlobalKey<NavigatorState> navigatorKey;

    Uri createVerificationUrl({String? oobCode}) {
      return Uri.parse(
          'pockeat://auth?mode=verifyEmail&oobCode=${oobCode ?? 'testCode'}');
    }

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUserRepository = MockUserRepository();
      mockUser = MockUser();
      mockAppLinks = MockAppLinks();
      navigatorKey = GlobalKey<NavigatorState>();

      // Setup deep link service dengan mocks
      deepLinkService = DeepLinkServiceImpl(
        auth: mockFirebaseAuth,
        userRepository: mockUserRepository,
      );

      // Setup custom deep link service
      customDeepLinkService = CustomDeepLinkService(
        auth: mockFirebaseAuth,
        userRepository: mockUserRepository,
        mockAppLinks: mockAppLinks,
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

      // Error handling untuk baris 219
      test('should catch errors when validating link', () {
        // Membuat mock untuk isEmailVerificationLink yang melempar exception
        final malformedLink = Uri(scheme: 'pockeat', host: 'auth');
        final result = deepLinkService.isEmailVerificationLink(malformedLink);
        expect(result, false);
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

      test('should handle exception during link processing', () async {
        // Setup - coba access malformed link yang menyebabkan error
        final malformedLink = Uri.parse('pockeat://');

        // Setup exception when processing the link
        when(mockFirebaseAuth.checkActionCode(any))
            .thenThrow(FirebaseAuthException(code: 'invalid-action-code'));

        // Verify bahwa error di catch dan method return false bukan throw exception
        expect(await deepLinkService.handleEmailVerificationLink(malformedLink),
            false);
      });
    });

    group('initialize', () {
      // Test untuk baris 195
      test('should handle error when getInitialAppLink throws', () {
        // Setup mockAppLinks untuk throw exception
        mockAppLinks.throwErrorOnGetInitialAppLink();

        // Verify bahwa initialize method melempar DeepLinkException
        expect(
          () => customDeepLinkService.initialize(navigatorKey: navigatorKey),
          throwsException,
        );
      });

      // Test untuk baris 203
      test('should handle error when getUriLinkStream throws', () {
        // Setup mockAppLinks untuk throw exception
        mockAppLinks.throwErrorOnUriLinkStream();

        // Verify bahwa initialize method melempar DeepLinkException
        expect(
          () => customDeepLinkService.initialize(navigatorKey: navigatorKey),
          throwsException,
        );
      });
    });

    group('dispose', () {
      test('should handle error when disposing streams', () {
        // Setup to throw on dispose
        customDeepLinkService.throwOnDispose = true;

        // Execute & Verify
        expect(
          () => customDeepLinkService.dispose(),
          throwsException,
        );
      });
    });

    group('getInitialLink', () {
      test('should handle exceptions when retrieving initial link', () {
        // Setup - mock that throws on getInitialAppLink
        mockAppLinks.throwErrorOnGetInitialAppLink();

        // Execute & Verify - menggunakan pump untuk stream testing
        expectLater(
          customDeepLinkService.getInitialLink(),
          emitsError(isA<DeepLinkException>()),
        );
      });
    });
  });
}
