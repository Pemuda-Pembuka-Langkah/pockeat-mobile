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
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';
import 'profile_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<LoginService>(),
  MockSpec<LogoutService>(),
  MockSpec<BugReportService>(),
  MockSpec<NavigatorObserver>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<UserInfo>(),
  MockSpec<NotificationService>(),
  MockSpec<
      UserPreferencesService>() // Add this line to mock UserPreferencesService
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
  late MockUserPreferencesService mockUserPreferencesService; // Add this line

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
    mockUserPreferencesService =
        MockUserPreferencesService(); // Initialize the mock

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
    if (getIt.isRegistered<UserPreferencesService>()) {
      getIt.unregister<UserPreferencesService>();
    }
    getIt.registerSingleton<LoginService>(mockLoginService);
    getIt.registerSingleton<LogoutService>(mockLogoutService);
    getIt.registerSingleton<BugReportService>(mockBugReportService);
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<UserPreferencesService>(
        mockUserPreferencesService); // Register the mock

    // Setup default behavior for UserPreferencesService
    when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
        .thenAnswer((_) async => false);
    when(mockUserPreferencesService.setExerciseCalorieCompensationEnabled(any))
        .thenAnswer((_) async => {});
    when(mockUserPreferencesService.isRolloverCaloriesEnabled())
        .thenAnswer((_) async => false);
    when(mockUserPreferencesService.setRolloverCaloriesEnabled(any))
        .thenAnswer((_) async => {});

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
    reset(mockUserPreferencesService); // Reset the mock
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

    testWidgets('Menampilkan toggle untuk exercise calorie compensation',
        (WidgetTester tester) async {
      // Setup user data and calorie compensation setting
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) async => true);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find text for this feature
      expect(find.text('Hitung Kalori Terbakar'), findsOneWidget);
      expect(
          find.text(
              'Kalori terbakar akan ditambahkan ke sisa kalori harian Anda'),
          findsOneWidget);

      // Toggle should exist and be ON
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('Menampilkan toggle untuk rollover calories',
        (WidgetTester tester) async {
      // Setup user data and rollover calories setting
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) async => true);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find text for this feature
      expect(find.text('Rollover Kalori'), findsOneWidget);
      expect(
          find.text(
              'Kalori yang tidak terpakai akan diakumulasikan ke hari berikutnya (maks 1000)'),
          findsOneWidget);

      // Toggle should exist and be ON
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('Mengubah rollover calories setting',
        (WidgetTester tester) async {
      // Setup user data and rollover setting
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) async => false);
      when(mockUserPreferencesService.setRolloverCaloriesEnabled(any))
          .thenAnswer((_) async => {});

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find rollover toggle section and tap on the switch
      // Since there can be multiple switches, we need to find the one next to "Rollover Kalori"
      final text = find.text('Rollover Kalori');
      expect(text, findsOneWidget);

      // To find the switch for rollover setting:
      // 1. First, find the Row containing "Rollover Kalori"
      // 2. Then find the switch within that row
      // This is challenging to do in widget tests, so we'll use a simpler approach for now

      // Find all switches in the profile page, should be at least 2:
      // 1 for exercise compensation and 1 for rollover calories
      expect(find.byType(Switch), findsAtLeastNWidgets(2));

      // For simplicity in the test, toggle all switches
      // In a real app you would find a more specific way to target the right switch
      for (final switchFinder in find.byType(Switch).evaluate()) {
        await tester.tap(find.byWidget(switchFinder.widget));
        await tester.pumpAndSettle();
      }

      // Verify the service was called to update the setting
      verify(mockUserPreferencesService.setRolloverCaloriesEnabled(any))
          .called(greaterThan(0));
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

    testWidgets(
        'Menampilkan error ketika gagal mengubah rollover calories setting',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Setup preferences
      when(mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) async => false);
      when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) async => false);

      // Setup error when setting rollover calories
      when(mockUserPreferencesService.setRolloverCaloriesEnabled(any))
          .thenThrow(Exception('Failed to update setting'));

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the rollover text
      final rolloverText = find.text('Rollover Kalori');
      expect(rolloverText, findsOneWidget);

      // First find all switches in the widget tree
      final switches = find.byType(Switch);
      
      // We need to find the switch that's inside the same container as the rollover text
      // Find the closest common ancestor for "Rollover Kalori" and a Switch
      Switch? targetSwitch;
      
      // Find the switch that's closest to our text by examining widget tree
      for (final switchElement in switches.evaluate()) {
        // Get the switch widget
        final switchWidget = switchElement.widget as Switch;
        
        // Check if this switch is near our target text
        // by testing if they share a close common ancestor
        final parentRow = find.ancestor(
          of: find.byWidget(switchWidget),
          matching: find.byType(Row),
          matchRoot: false,
        ).evaluate().first;
        
        // Check if this Row also contains our text
        final hasRolloverText = tester.widgetList(find.descendant(
          of: find.byWidget(parentRow.widget),
          matching: find.text('Rollover Kalori'),
        )).isNotEmpty;
        
        if (hasRolloverText) {
          targetSwitch = switchWidget;
          break;
        }
      }
      
      // Make sure we found the right switch
      expect(targetSwitch, isNotNull, reason: "Couldn't find Switch near 'Rollover Kalori'");
      
      // Tap the switch we found
      await tester.tap(find.byWidget(targetSwitch!));
      await tester.pumpAndSettle();

      // Verify the SnackBar is displayed with the error message
      expect(find.byType(SnackBar), findsOneWidget);
      
      // Find the SnackBar and check its content
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      final snackBarText = snackBar.content as Text;
      
      // Verify the error message contains the expected text
      expect(snackBarText.data, contains('Gagal mengubah pengaturan'));
    });
  });

  // == USER PREFERENCES FEATURE TESTS ==
  group('User Preferences Features', () {
    testWidgets(
        'Exercise calorie compensation and rollover calories toggles exist and work',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Initial state of preferences
      when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) async => false);
      when(mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) async => false);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify both toggles exist
      expect(find.text('Hitung Kalori Terbakar'), findsOneWidget);
      expect(find.text('Rollover Kalori'), findsOneWidget);

      // Find all switches and toggle them
      final switches = find.byType(Switch);
      expect(switches, findsAtLeastNWidgets(2));

      // Verify services called when changing preferences
      when(mockUserPreferencesService
              .setExerciseCalorieCompensationEnabled(any))
          .thenAnswer((_) async => {});
      when(mockUserPreferencesService.setRolloverCaloriesEnabled(any))
          .thenAnswer((_) async => {});

      // Toggle each switch
      for (final switchFinder in switches.evaluate()) {
        await tester.tap(find.byWidget(switchFinder.widget));
        await tester.pumpAndSettle();
      }

      // Verify services were called
      verify(mockUserPreferencesService
              .setExerciseCalorieCompensationEnabled(any))
          .called(greaterThan(0));
      verify(mockUserPreferencesService.setRolloverCaloriesEnabled(any))
          .called(greaterThan(0));
    });
  });
}
