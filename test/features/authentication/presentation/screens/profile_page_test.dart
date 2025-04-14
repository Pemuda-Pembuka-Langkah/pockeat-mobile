import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/presentation/screens/profile_page.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/authentication/services/logout_service.dart';

@GenerateNiceMocks([
  MockSpec<LoginService>(),
  MockSpec<LogoutService>(),
  MockSpec<NavigatorObserver>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<UserInfo>()
])
import 'profile_page_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock dependencies
  late MockLoginService mockLoginService;
  late MockLogoutService mockLogoutService;
  late MockNavigatorObserver mockNavigatorObserver;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserInfo mockUserInfo;

  setUp(() {
    // Reset screen size to reasonable dimension
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;

    // Initialize mocks
    mockLoginService = MockLoginService();
    mockLogoutService = MockLogoutService();
    mockNavigatorObserver = MockNavigatorObserver();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserInfo = MockUserInfo();

    // Setup GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<LoginService>()) {
      getIt.unregister<LoginService>();
    }
    if (getIt.isRegistered<LogoutService>()) {
      getIt.unregister<LogoutService>();
    }
    getIt.registerSingleton<LoginService>(mockLoginService);
    getIt.registerSingleton<LogoutService>(mockLogoutService);

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
    reset(mockNavigatorObserver);
    reset(mockAuth);
    reset(mockUser);
    reset(mockUserInfo);
  });

  // Helper untuk membuat UserModel test
  UserModel createTestUser({
    String uid = 'test-uid',
    String email = 'test@example.com',
    String? displayName = 'Test User',
    String? photoURL = null,
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

    testWidgets('Menampilkan error saat gagal logout',
        (WidgetTester tester) async {
      // Setup user and throw on logout
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser());
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

      // Verify error snackbar shown
      expect(find.textContaining('Gagal logout'), findsOneWidget);
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
}
