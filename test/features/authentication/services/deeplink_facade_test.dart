import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/change_password_deeplink_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service_impl.dart';
import 'package:pockeat/features/authentication/services/email_verification_deeplink_service.dart';

// Generate mocks dengan perintah:
// flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  EmailVerificationDeepLinkService,
  ChangePasswordDeepLinkService,
  NavigatorState,
  AppLinks
])
import 'deeplink_facade_test.mocks.dart';

class TestableDeepLinkServiceImpl extends DeepLinkServiceImpl {
  final AppLinks _mockAppLinks;

  TestableDeepLinkServiceImpl({
    required EmailVerificationDeepLinkService emailVerificationService,
    required ChangePasswordDeepLinkService changePasswordService,
    required AppLinks mockAppLinks,
  })  : _mockAppLinks = mockAppLinks,
        super(
          emailVerificationService: emailVerificationService,
          changePasswordService: changePasswordService,
        );

  @override
  Future<Uri?> getInitialAppLink() => _mockAppLinks.getInitialAppLink();

  @override
  Stream<Uri> getUriLinkStream() => _mockAppLinks.uriLinkStream;
}

void main() {
  late MockEmailVerificationDeepLinkService mockEmailVerificationService;
  late MockChangePasswordDeepLinkService mockChangePasswordService;
  late MockAppLinks mockAppLinks;
  late TestableDeepLinkServiceImpl service;
  late GlobalKey<NavigatorState> navigatorKey;
  late MockNavigatorState mockNavigatorState;
  late StreamController<Uri> mockAppLinksStreamController;
  late StreamController<Uri?> mockEmailVerificationLinkStreamController;
  late StreamController<Uri?> mockChangePasswordLinkStreamController;

  setUp(() {
    mockEmailVerificationService = MockEmailVerificationDeepLinkService();
    mockChangePasswordService = MockChangePasswordDeepLinkService();
    mockAppLinks = MockAppLinks();
    navigatorKey = GlobalKey<NavigatorState>();
    mockNavigatorState = MockNavigatorState();
    mockAppLinksStreamController = StreamController<Uri>.broadcast();
    mockEmailVerificationLinkStreamController =
        StreamController<Uri?>.broadcast();
    mockChangePasswordLinkStreamController = StreamController<Uri?>.broadcast();

    // Setup AppLinks mock
    when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);
    when(mockAppLinks.uriLinkStream)
        .thenAnswer((_) => mockAppLinksStreamController.stream);

    // Setup service streams
    when(mockEmailVerificationService.onLinkReceived())
        .thenAnswer((_) => mockEmailVerificationLinkStreamController.stream);
    when(mockChangePasswordService.onLinkReceived())
        .thenAnswer((_) => mockChangePasswordLinkStreamController.stream);

    // Setup service
    service = TestableDeepLinkServiceImpl(
      emailVerificationService: mockEmailVerificationService,
      changePasswordService: mockChangePasswordService,
      mockAppLinks: mockAppLinks,
    );
  });

  tearDown(() {
    mockAppLinksStreamController.close();
    mockEmailVerificationLinkStreamController.close();
    mockChangePasswordLinkStreamController.close();
  });

  group('initialize', () {
    test('menginisialisasi semua service dengan benar', () async {
      // Arrange - mock initialize dari kedua service
      when(mockEmailVerificationService.initialize(navigatorKey: navigatorKey))
          .thenAnswer((_) async => null);
      when(mockChangePasswordService.initialize(navigatorKey: navigatorKey))
          .thenAnswer((_) async => null);

      // Act
      await service.initialize(navigatorKey: navigatorKey);

      // Assert - verifikasi dengan isolasi
      bool verified = false;
      try {
        verify(mockEmailVerificationService.initialize(
                navigatorKey: navigatorKey))
            .called(1);
        verify(mockChangePasswordService.initialize(navigatorKey: navigatorKey))
            .called(1);
        verify(mockAppLinks.getInitialAppLink()).called(1);
        verify(mockAppLinks.uriLinkStream).called(1);
        verified = true;
      } finally {
        expect(verified, true);
      }
    });

    test('menangani initial link jika ada', () async {
      // Arrange
      final initialLink =
          Uri.parse('pockeat://app?mode=verifyEmail&oobCode=abc123');
      when(mockAppLinks.getInitialAppLink())
          .thenAnswer((_) async => initialLink);

      // Mock service initialize
      when(mockEmailVerificationService.initialize(navigatorKey: navigatorKey))
          .thenAnswer((_) async => null);
      when(mockChangePasswordService.initialize(navigatorKey: navigatorKey))
          .thenAnswer((_) async => null);

      // Mock service verification dan handling
      when(mockEmailVerificationService.isEmailVerificationLink(initialLink))
          .thenReturn(true);
      when(mockChangePasswordService.isChangePasswordLink(initialLink))
          .thenReturn(false);
      when(mockEmailVerificationService
              .handleEmailVerificationLink(initialLink))
          .thenAnswer((_) async => true);

      // Act
      await service.initialize(navigatorKey: navigatorKey);

      // Assert - verifikasi handler dipanggil dengan link awal
      verify(mockEmailVerificationService.isEmailVerificationLink(initialLink))
          .called(1);
      verify(mockEmailVerificationService
              .handleEmailVerificationLink(initialLink))
          .called(1);
    });

    test('melempar exception jika ada service yang gagal inisialisasi',
        () async {
      // Arrange
      when(mockEmailVerificationService.initialize(navigatorKey: navigatorKey))
          .thenThrow(
              Exception('Failed to initialize email verification service'));
      when(mockChangePasswordService.initialize(navigatorKey: navigatorKey))
          .thenAnswer((_) async => null);

      // Act & Assert
      await expectLater(
        () => service.initialize(navigatorKey: navigatorKey),
        throwsA(isA<DeepLinkException>()),
      );
    });
  });

  group('handleDeepLink', () {
    setUp(() {
      // Siapkan mock untuk service
      when(mockEmailVerificationService.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async => null);
      when(mockChangePasswordService.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async => null);
    });

    test('mendelegasikan link verifikasi email ke service yang benar',
        () async {
      // Arrange
      final emailVerificationLink =
          Uri.parse('pockeat://app?mode=verifyEmail&oobCode=abc123');

      // Mock isEmailVerificationLink untuk mengembalikan true
      when(mockEmailVerificationService
              .isEmailVerificationLink(emailVerificationLink))
          .thenReturn(true);
      when(mockChangePasswordService
              .isChangePasswordLink(emailVerificationLink))
          .thenReturn(false);

      // Mock handleEmailVerificationLink untuk mengembalikan true
      when(mockEmailVerificationService
              .handleEmailVerificationLink(emailVerificationLink))
          .thenAnswer((_) => Future.value(true));

      // Act
      final result = await service.handleDeepLink(emailVerificationLink);

      // Assert
      expect(result, true);
      verify(mockEmailVerificationService
              .isEmailVerificationLink(emailVerificationLink))
          .called(1);
      verify(mockEmailVerificationService
              .handleEmailVerificationLink(emailVerificationLink))
          .called(1);
      verifyNever(mockChangePasswordService.handleChangePasswordLink(any));
    });

    test('mendelegasikan link change password ke service yang benar', () async {
      // Arrange
      final changePasswordLink =
          Uri.parse('pockeat://app?mode=resetPassword&oobCode=abc123');

      // Mock isEmailVerificationLink untuk mengembalikan false, dan isChangePasswordLink true
      when(mockEmailVerificationService
              .isEmailVerificationLink(changePasswordLink))
          .thenReturn(false);
      when(mockChangePasswordService.isChangePasswordLink(changePasswordLink))
          .thenReturn(true);

      // Mock handleChangePasswordLink untuk mengembalikan true
      when(mockChangePasswordService
              .handleChangePasswordLink(changePasswordLink))
          .thenAnswer((_) => Future.value(true));

      // Act
      final result = await service.handleDeepLink(changePasswordLink);

      // Assert
      expect(result, true);
      verify(mockEmailVerificationService
              .isEmailVerificationLink(changePasswordLink))
          .called(1);
      verify(mockChangePasswordService.isChangePasswordLink(changePasswordLink))
          .called(1);
      verify(mockChangePasswordService
              .handleChangePasswordLink(changePasswordLink))
          .called(1);
      verifyNever(
          mockEmailVerificationService.handleEmailVerificationLink(any));
    });

    test('mengembalikan false jika link tidak dikenali oleh semua service',
        () async {
      // Arrange
      final unknownLink =
          Uri.parse('pockeat://app?mode=unknown&oobCode=abc123');

      // Mock isEmailVerificationLink dan isChangePasswordLink untuk mengembalikan false
      when(mockEmailVerificationService.isEmailVerificationLink(unknownLink))
          .thenReturn(false);
      when(mockChangePasswordService.isChangePasswordLink(unknownLink))
          .thenReturn(false);

      // Act
      final result = await service.handleDeepLink(unknownLink);

      // Assert
      expect(result, false);
      verify(mockEmailVerificationService.isEmailVerificationLink(unknownLink))
          .called(1);
      verify(mockChangePasswordService.isChangePasswordLink(unknownLink))
          .called(1);
      verifyNever(
          mockEmailVerificationService.handleEmailVerificationLink(any));
      verifyNever(mockChangePasswordService.handleChangePasswordLink(any));
    });

    test('menangani exception dari service', () async {
      // Arrange
      final emailVerificationLink =
          Uri.parse('pockeat://app?mode=verifyEmail&oobCode=abc123');

      // Mock isEmailVerificationLink untuk mengembalikan true
      when(mockEmailVerificationService
              .isEmailVerificationLink(emailVerificationLink))
          .thenReturn(true);

      // Mock handleEmailVerificationLink untuk throw exception
      when(mockEmailVerificationService
              .handleEmailVerificationLink(emailVerificationLink))
          .thenThrow(Exception('Failed to handle email verification link'));

      // Act & Assert
      expect(
        () => service.handleDeepLink(emailVerificationLink),
        throwsA(isA<DeepLinkException>()),
      );
    });
  });

  group('getInitialLink', () {
    setUp(() async {
      // Inisialisasi service untuk test
      when(mockEmailVerificationService.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async => null);
      when(mockChangePasswordService.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async => null);
    });

    test('mengembalikan link awal jika ada', () async {
      // Arrange
      final initialLink =
          Uri.parse('pockeat://app?mode=verifyEmail&oobCode=abc123');
      when(mockAppLinks.getInitialAppLink())
          .thenAnswer((_) async => initialLink);

      // Act - menggunakan tester yang lebih stabil
      final result = await service.getInitialLink().first;

      // Assert
      expect(result, initialLink);
    });

    test('mengembalikan stream kosong jika tidak ada link awal', () async {
      // Arrange
      when(mockAppLinks.getInitialAppLink()).thenAnswer((_) async => null);

      // Act & Assert - menggunakan tes alternatif
      int emissionCount = 0;
      final subscription = service.getInitialLink().listen((uri) {
        emissionCount++;
      });

      // Beri waktu untuk stream untuk mengeluarkan nilai jika ada
      await Future.delayed(Duration(milliseconds: 100));
      await subscription.cancel();

      // Assert - stream tidak mengeluarkan event
      expect(emissionCount, 0);
    });

    test('menangani error saat mengambil link awal', () async {
      // Arrange
      when(mockAppLinks.getInitialAppLink())
          .thenThrow(Exception('Failed to get initial link'));

      // Act & Assert - gunakan try/catch untuk menangkap exception
      try {
        await service.getInitialLink().first;
        fail('Seharusnya melempar exception');
      } catch (e) {
        expect(e, isA<DeepLinkException>());
      }
    });
  });

  group('onLinkReceived', () {
    setUp(() async {
      // Inisialisasi service untuk test
      when(mockEmailVerificationService.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async => null);
      when(mockChangePasswordService.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async => null);

      await service.initialize(navigatorKey: navigatorKey);
    });

    test('menerima link dari AppLinks stream', () async {
      // Arrange
      final testLink =
          Uri.parse('pockeat://app?mode=verifyEmail&oobCode=abc123');

      // Mock service behavior
      when(mockEmailVerificationService.isEmailVerificationLink(testLink))
          .thenReturn(true);
      when(mockEmailVerificationService.handleEmailVerificationLink(testLink))
          .thenAnswer((_) async => true);

      // Act & Assert
      Uri? receivedLink;
      final subscription = service.onLinkReceived().listen((link) {
        receivedLink = link;
      });

      // Simulasi incoming link
      mockAppLinksStreamController.add(testLink);

      // Beri waktu untuk stream mengeluarkan nilai
      await Future.delayed(Duration(milliseconds: 100));
      await subscription.cancel();

      // Assert
      expect(receivedLink, testLink);
    });
  });

  group('dispose', () {
    setUp(() async {
      // Inisialisasi service untuk test
      when(mockEmailVerificationService.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async => null);
      when(mockChangePasswordService.initialize(
              navigatorKey: anyNamed('navigatorKey')))
          .thenAnswer((_) async => null);

      await service.initialize(navigatorKey: navigatorKey);
    });

    test('membersihkan resource semua service', () {
      // Act
      service.dispose();

      // Assert
      verify(mockEmailVerificationService.dispose()).called(1);
      verify(mockChangePasswordService.dispose()).called(1);
    });

    test('menangani error pada dispose', () {
      // Arrange
      when(mockEmailVerificationService.dispose())
          .thenThrow(Exception('Failed to dispose email verification service'));

      // Act & Assert
      expect(() => service.dispose(), throwsA(isA<DeepLinkException>()));
    });
  });
}
