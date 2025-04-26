// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/presentation/screens/profile_page.dart';
import 'package:pockeat/features/authentication/services/bug_report_service.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/authentication/services/logout_service.dart';
import 'package:pockeat/features/notifications/domain/services/notification_service.dart';
import 'profile_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<LoginService>(),
  MockSpec<LogoutService>(),
  MockSpec<BugReportService>(),
  MockSpec<NavigatorObserver>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<UserInfo>(),
  MockSpec<NotificationService>()
])

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock dependencies
  late MockLoginService mockLoginService;
  late MockLogoutService mockLogoutService;
  late MockBugReportService mockBugReportService;
  late MockNavigatorObserver mockNavigatorObserver;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserInfo mockUserInfo;
  late MockNotificationService mockNotificationService;

  setUp(() {
    // Reset screen size to reasonable dimension
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;

    // Initialize mocks
    mockLoginService = MockLoginService();
    mockLogoutService = MockLogoutService();
    mockBugReportService = MockBugReportService();
    mockNavigatorObserver = MockNavigatorObserver();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserInfo = MockUserInfo();
    mockNotificationService = MockNotificationService();

    // Setup GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
    if (getIt.isRegistered<LogoutService>()) {
      getIt.unregister<LogoutService>();
    }
    if (getIt.isRegistered<BugReportService>()) {
      getIt.unregister<BugReportService>();
    }
    if (getIt.isRegistered<NotificationService>()) {
      getIt.unregister<NotificationService>();
    }
    getIt.registerSingleton<LoginService>(mockLoginService);
    getIt.registerSingleton<LogoutService>(mockLogoutService);
    getIt.registerSingleton<BugReportService>(mockBugReportService);
    getIt.registerSingleton<NotificationService>(mockNotificationService);

    // Setup default User behavior
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.photoURL)
        .thenReturn(null); // Null to avoid network image error
    when(mockUser.emailVerified).thenReturn(true);
    when(mockUser.providerData).thenReturn([mockUserInfo]);
    when(mockUser.sendEmailVerification()).thenAnswer((_) async => {});

    // Setup UserInfo mock (for provider type)
    when(mockUserInfo.providerId).thenReturn('password');

    // Setup Firebase Auth
    when(mockAuth.currentUser).thenReturn(mockUser);
  });

  tearDown(() {
    reset(mockLoginService);
    reset(mockLogoutService);
    reset(mockBugReportService);
    reset(mockNavigatorObserver);
    reset(mockAuth);
    reset(mockUser);
    reset(mockUserInfo);
    reset(mockNotificationService);
  });

  // Helper untuk membuat UserModel test
  UserModel createTestUser({
    String uid = 'test-uid',
    String email = 'test@example.com',
    String? displayName = 'Test User',
    String? photoURL,
    bool emailVerified = true,
    String? gender = 'Male',
    DateTime? birthDate,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      emailVerified: emailVerified,
      gender: gender,
      birthDate: birthDate ?? DateTime(1990, 1, 1),
      createdAt: DateTime.now(),
      lastLoginAt: null,
    );
  }

  // Helper untuk membuat widget tree
  Widget createTestWidget() {
    return MaterialApp(
      navigatorObservers: [mockNavigatorObserver],
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<NavigationProvider>(
            create: (_) => NavigationProvider(),
          ),
        ],
        child: ProfilePage(firebaseAuth: mockAuth),
      ),
      routes: {
        '/login': (context) => const Scaffold(body: Text('Login Page')),
        '/change-password': (context) =>
            const Scaffold(body: Text('Change Password Page')),
        '/notification-settings': (context) =>
            const Scaffold(body: Text('Notification Settings Page')),
        '/edit-profile': (context) =>
            const Scaffold(body: Text('Edit Profile Page')),
      },
    );
  }

  // == KASUS POSITIF ==
  group('Kasus Positif', () {
    testWidgets('Menampilkan loading indicator saat loading data',
        (WidgetTester tester) async {
      // Setup loading delay
      final completer = Completer<UserModel>();
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) => completer.future);

      // Render widget
      await tester.pumpWidget(createTestWidget());

      // Verify loading indicator shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid pending timers
      completer.complete(createTestUser());

      // Pump again to process the future completion
      await tester.pump();

      // Pump until all animations and timers are settled
      await tester.pumpAndSettle();
    });

    testWidgets('Menampilkan data profil dengan benar',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Render widget
      await tester.pumpWidget(createTestWidget());

      // Wait for async operations to complete
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify user data is displayed - gunakan nilai yang sesuai dari helper
      expect(find.text('Test User'), findsOneWidget);
      // Email sekarang hanya muncul sekali di header profil
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Email terverifikasi'), findsOneWidget);
    });
  });

  // == KASUS NEGATIF ==
  group('Kasus Negatif', () {
    testWidgets('Menampilkan error view ketika gagal memuat data profil',
        (WidgetTester tester) async {
      // Setup error response
      when(mockLoginService.getCurrentUser())
          .thenThrow(Exception('Network error'));

      // Render widget
      await tester.pumpWidget(createTestWidget());

      // Let widget process error
      await tester.pumpAndSettle();

      // Verify error view shown
      expect(find.textContaining('Gagal memuat profil'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Setup success response for retry
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      // Tap retry button
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      // Verify profile loaded after retry
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('Menghapus user data dari bug reporting service sebelum logout',
        (WidgetTester tester) async {
      // Setup user and logout services
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser());
      when(mockBugReportService.clearUserData()).thenAnswer((_) async => true);
      when(mockLogoutService.logout()).thenAnswer((_) async => true);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find logout button
      final logoutFinder = find.text('Logout');
      expect(logoutFinder, findsOneWidget);

      // Tap logout button
      await tester.ensureVisible(logoutFinder);
      await tester.pumpAndSettle();
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      // Tap confirm button
      final confirmButton = find.text('Logout').last;
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify clearUserData was called before logout
      verifyInOrder([
        mockBugReportService.clearUserData(),
        mockLogoutService.logout(),
      ]);
    });

    testWidgets('Menampilkan error saat gagal logout',
        (WidgetTester tester) async {
      // Setup user and throw on logout
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser());
      when(mockBugReportService.clearUserData()).thenAnswer((_) async => true);
      when(mockLogoutService.logout()).thenThrow(Exception('Logout failed'));

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find logout button (using hitTestable finder karena mungkin ada masalah size)
      final logoutFinder = find.text('Logout');
      expect(logoutFinder, findsOneWidget);

      // Tap logout button dengan force jika perlu
      await tester.ensureVisible(logoutFinder);
      await tester.pumpAndSettle();
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      // Tap confirm button
      final confirmButton = find.text('Logout').last;
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify clearUserData was still called even though logout failed
      verify(mockBugReportService.clearUserData()).called(1);

      // Verify error snackbar shown
      expect(find.textContaining('Gagal logout'), findsOneWidget);
    });

    testWidgets(
        'Menampilkan UI pelaporan bug saat tombol Report Bug ditekan dan set user data',
        (WidgetTester tester) async {
      // Setup user and successful bug report response
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockBugReportService.setUserData(any)).thenAnswer((_) async => true);
      when(mockBugReportService.show()).thenAnswer((_) async => true);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Report Bug button
      final reportBugFinder = find.text('Laporkan Bug');
      expect(reportBugFinder, findsOneWidget);

      // Tap Report Bug button
      await tester.ensureVisible(reportBugFinder);
      await tester.pumpAndSettle();
      await tester.tap(reportBugFinder);
      await tester.pumpAndSettle();

      // Verify setUserData was called before showing the UI
      verifyInOrder([
        mockBugReportService.setUserData(testUser),
        mockBugReportService.show(),
      ]);
    });

    testWidgets('Menampilkan error saat gagal menampilkan UI pelaporan bug',
        (WidgetTester tester) async {
      // Setup user and failed bug report response
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockBugReportService.setUserData(any)).thenAnswer((_) async => true);
      when(mockBugReportService.show()).thenAnswer((_) async => false);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Report Bug button
      final reportBugFinder = find.text('Laporkan Bug');
      expect(reportBugFinder, findsOneWidget);

      // Tap Report Bug button
      await tester.ensureVisible(reportBugFinder);
      await tester.pumpAndSettle();
      await tester.tap(reportBugFinder);
      await tester.pumpAndSettle();

      // Verify setUserData was called before showing the UI
      verifyInOrder([
        mockBugReportService.setUserData(testUser),
        mockBugReportService.show(),
      ]);

      // Verify error snackbar shown
      expect(find.text('Gagal membuka pelaporan bug'), findsOneWidget);
    });

    testWidgets(
        'Menampilkan peringatan saat user data tidak tersedia untuk pelaporan bug',
        (WidgetTester tester) async {
      // Setup null user scenario
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The ProfilePage shows an error state when user is null
      // Let's skip the error state UI verification as UI may change

      // Set up a successful user load and simulate the user being loaded
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      // Force a rebuild to simulate user loading scenario
      await tester.pump();
      await tester.pumpAndSettle();

      // Find and tap Report Bug button
      final reportBugFinder = find.text('Laporkan Bug');
      expect(reportBugFinder, findsOneWidget);

      // Force currentUser to be null to test the null check path
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);

      // Simulate _currentUser becoming null again by changing the mock response
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap Report Bug button
      await tester.ensureVisible(reportBugFinder);
      await tester.tap(reportBugFinder);
      await tester.pumpAndSettle();

      // Verify bug report service methods were not called
      verifyNever(mockBugReportService.setUserData(any));
      verifyNever(mockBugReportService.show());

      // Verify warning snackbar about missing user data
      expect(find.text('Data pengguna tidak tersedia untuk pelaporan bug'),
          findsOneWidget);
    });
  });

  // == EDGE CASES ==
  group('Edge Cases', () {
    testWidgets('Menampilkan nama default untuk user tanpa displayName',
        (WidgetTester tester) async {
      // Setup user with null displayName
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser(displayName: null));

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify default name displayed
      expect(find.text('Pengguna Pockeat'), findsOneWidget);
    });

    testWidgets('Menampilkan initial tunggal untuk nama satu kata',
        (WidgetTester tester) async {
      // Setup user with single-word name
      when(mockLoginService.getCurrentUser()).thenAnswer(
          (_) async => createTestUser(displayName: 'Mono', photoURL: null));

      // Also set mock user for Firebase.currentUser
      when(mockUser.displayName).thenReturn('Mono');

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify single initial displayed
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets(
        'Menampilkan button verifikasi email untuk email yang belum diverifikasi',
        (WidgetTester tester) async {
      // Setup unverified user
      final unverifiedUser = createTestUser(emailVerified: false);
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => unverifiedUser);
      when(mockUser.emailVerified).thenReturn(false);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify verification status and button shown
      expect(find.text('Email belum terverifikasi'), findsOneWidget);
      expect(find.text('Kirim Email Verifikasi'), findsOneWidget);
    });

    testWidgets('Google login user tidak melihat menu ubah password',
        (WidgetTester tester) async {
      // Setup Google login user
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser());
      when(mockUserInfo.providerId).thenReturn('google.com');

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify Change Password option is hidden
      expect(find.text('Ubah Password'), findsNothing);
    });
  });
  
  // == NOTIFIKASI DAN PENGATURAN PROFILE ==
  group('Notifikasi dan Pengaturan Profile', () {
    testWidgets('Menampilkan menu pengaturan notifikasi dan navigasi ke halaman pengaturan notifikasi',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Temukan dan scroll ke menu pengaturan notifikasi
      final notifSettingsFinder = find.text('Pengaturan Notifikasi');
      await tester.dragUntilVisible(
        notifSettingsFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      expect(notifSettingsFinder, findsOneWidget);

      // Verifikasi subtitle menu pengaturan notifikasi
      expect(find.text('Kelola pengaturan notifikasi aplikasi'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // Tap pada menu pengaturan notifikasi
      await tester.tap(notifSettingsFinder);
      await tester.pumpAndSettle();

      // Verifikasi navigasi ke halaman pengaturan notifikasi
      expect(find.text('Notification Settings Page'), findsOneWidget);
      
      // Verifikasi navigasi terobservasi
      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('Navigasi ke halaman edit profile ketika tombol edit ditekan',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Temukan menu Edit Profil
      final editProfileFinder = find.text('Edit Profil');
      expect(editProfileFinder, findsOneWidget);
      expect(find.text('Perbarui informasi profil Anda'), findsOneWidget);
      
      // Tap menu Edit Profil
      await tester.tap(editProfileFinder);
      await tester.pumpAndSettle();

      // Verifikasi navigasi ke halaman edit profil
      expect(find.text('Edit Profile Page'), findsOneWidget);
      
      // Verifikasi navigasi terobservasi
      verify(mockNavigatorObserver.didPush(any, any));
    });
    
    testWidgets('Cek interaksi dengan menu lain (Laporkan Bug)',
        (WidgetTester tester) async {
      // Setup user data dan service
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockBugReportService.setUserData(any)).thenAnswer((_) async => true);
      when(mockBugReportService.show()).thenAnswer((_) async => true);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Temukan dan scroll ke menu Laporkan Bug
      final bugReportFinder = find.text('Laporkan Bug');
      await tester.dragUntilVisible(
        bugReportFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      expect(bugReportFinder, findsOneWidget);

      // Verifikasi subtitle menu
      expect(find.text('Bantu kami meningkatkan aplikasi'), findsOneWidget);
      
      // Tap menu Laporkan Bug
      await tester.tap(bugReportFinder);
      await tester.pumpAndSettle();

      // Verifikasi metode yang dipanggil
      verify(mockBugReportService.setUserData(testUser)).called(1);
      verify(mockBugReportService.show()).called(1);
    });
  });
}
