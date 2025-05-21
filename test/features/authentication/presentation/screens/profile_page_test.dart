// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  MockSpec<UserPreferencesService>(),
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
  late MockUserPreferencesService mockUserPreferencesService;

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
    mockUserPreferencesService = MockUserPreferencesService();

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
    getIt.registerSingleton<UserPreferencesService>(mockUserPreferencesService);

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
    reset(mockUserPreferencesService);
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
        '/widget-settings': (context) =>
            const Scaffold(body: Text('Widget Settings Page')),
        '/height-weight': (context) =>
            const Scaffold(body: Text('Height Weight Page')),
      },
    );
  }

  // == POSITIVE CASES ==
  group('Positive Cases', () {
    testWidgets('Shows loading indicator when loading data',
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

    testWidgets('Displays profile data correctly', (WidgetTester tester) async {
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
      // Email now only appears once in the profile header
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Email verified'), findsOneWidget);
    });

    testWidgets('Shows exercise calorie compensation toggle',
        (WidgetTester tester) async {
      // Setup user data and calorie compensation setting
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) async => true);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); 
      
      // Find text for this feature - Updated to English text
      expect(find.text('Count Burned Calories'), findsOneWidget);
      expect(
          find.text(
              'Burned calories will be added to your daily remaining calories'),
          findsOneWidget);

      // Toggle should exist and be ON
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('Shows rollover calories toggle', (WidgetTester tester) async {
      // Setup user data and rollover calories setting
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) async => true);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); 
      
      // Find text for this feature - Updated to English text
      expect(find.text('Rollover Calories'), findsOneWidget);
      expect(
          find.text(
              'Unused calories will be accumulated to the next day (max 1000)'),
          findsOneWidget);

      // Toggle should exist and be ON
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('Can toggle rollover calories setting',
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
      final text = find.text('Rollover Calories');

      // For simplicity in the test, toggle the last switch (rollover calories)
      final switches = find.byType(Switch);
      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      // Verify the service was called to update the setting
      verify(mockUserPreferencesService.setRolloverCaloriesEnabled(any))
          .called(1);
    });

    testWidgets('Pull-to-refresh reloads user data', (WidgetTester tester) async {
      // Setup initial user data
      final initialUser = createTestUser(displayName: 'Initial User');
      final updatedUser = createTestUser(displayName: 'Updated User');
      
      // Use a more reliable approach with explicit mock reset between calls
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => initialUser);
      
      // Setup default preferences
      when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) async => false);
      when(mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) async => false);
      
      // Render widget with initial user
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Verify initial user is displayed
      expect(find.text('Initial User'), findsOneWidget);
      
      // Reset the mock to return the updated user for the next call
      reset(mockLoginService);
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => updatedUser);
      
      // Find a scrollable widget to drag
      final scrollable = find.byType(SingleChildScrollView).first;
      
      // Simulate pull-to-refresh gesture with a larger offset
      await tester.drag(scrollable, const Offset(0, 500));
      
      // Allow the refresh indicator to appear
      await tester.pump();
      
      // Wait for the async refresh to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      
      // Verify updated user data is displayed after refresh
      expect(find.text('Updated User'), findsOneWidget);
    });
  });

  // == NEGATIVE CASES ==
  group('Negative Cases', () {
    testWidgets('Shows error view when failed to load profile data',
        (WidgetTester tester) async {
      // Setup error response
      when(mockLoginService.getCurrentUser())
          .thenThrow(Exception('Network error'));

      // Render widget
      await tester.pumpWidget(createTestWidget());

      // Let widget process error
      await tester.pumpAndSettle();

      // Verify error view shown
      expect(find.textContaining('Failed to load profile'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Setup success response for retry
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Verify profile loaded after retry
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('Clears user data from bug reporting service before logout',
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
      await tester.pumpAndSettle();
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify clearUserData was called before logout
      verifyInOrder([
        mockBugReportService.clearUserData(),
        mockLogoutService.logout(),
      ]);
    });

    testWidgets('Shows error when logout fails', (WidgetTester tester) async {
      // Setup user and throw on logout
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser());
      when(mockBugReportService.clearUserData()).thenAnswer((_) async => true);
      when(mockLogoutService.logout()).thenThrow(Exception('Logout failed'));

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

      // Verify clearUserData was still called even though logout failed
      verify(mockBugReportService.clearUserData()).called(1);
      // Verify error snackbar shown
      expect(find.textContaining('Logout failed'), findsOneWidget);
    });

    // Email bug report test already covered in 'Check Report Bug menu exists and has correct content' test
    // All Instabug-related tests have been removed as we now use email for bug reporting

    testWidgets('Shows error when updating rollover calories setting fails',
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
      final rolloverText = find.text('Rollover Calories');

      // Find and tap the switch for rollover calories
      final switches = find.byType(Switch);

      // Tap the last switch (rollover calories)
      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      // Verify the SnackBar is displayed with the error message

      // Find the SnackBar and check its content
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      final snackBarText = snackBar.content as Text;

      // Verify the error message contains the expected text
      expect(snackBarText.data, contains('Failed to update'));
    });
  });

  // == EDGE CASES ==
  group('Edge Cases', () {
    testWidgets('Shows default name for user without displayName',
        (WidgetTester tester) async {
      // Setup user with null displayName
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser(displayName: null));

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify default name displayed
      expect(find.text('Pockeat User'), findsOneWidget);
    });

    testWidgets('Shows single initial for one-word name',
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

    testWidgets('Shows email verification button for unverified email',
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
      expect(find.text('Email not verified'), findsOneWidget);
      expect(find.text('Send Verification Email'), findsOneWidget);
    });

    testWidgets('Google login user does not see change password menu',
        (WidgetTester tester) async {
      // Setup Google login user
      when(mockLoginService.getCurrentUser())
          .thenAnswer((_) async => createTestUser());
      when(mockUserInfo.providerId).thenReturn('google.com');

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify Change Password option is hidden
      expect(find.text('Change Password'), findsNothing);
    });
  });

  // == NOTIFICATION AND PROFILE SETTINGS ==
  group('Notification and Profile Settings', () {
    testWidgets(
        'Navigates to Widget Settings page when widget settings button is pressed',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Mock the navigation to prevent actual navigation to WidgetManagerScreen
      // which would require actual dependencies
      when(mockNavigatorObserver.didPush(any, any)).thenAnswer((_) => null);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and scroll to widget settings menu
      final widgetSettingsFinder = find.text('Widget Settings');
      await tester.dragUntilVisible(
        widgetSettingsFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      expect(widgetSettingsFinder, findsOneWidget);

      // Verify widget settings menu subtitle and icon
      expect(find.text('Manage app widgets on home screen'), findsOneWidget);
      expect(find.byIcon(Icons.widgets_outlined), findsOneWidget);

      // Tap on widget settings menu
      await tester.tap(widgetSettingsFinder);
      await tester.pumpAndSettle();

      // Verify navigation was triggered
      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets(
        'Navigates to Notification Settings page when button is pressed',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and scroll to notification settings menu
      final notifSettingsFinder = find.text('Notification Settings');
      await tester.dragUntilVisible(
        notifSettingsFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      expect(notifSettingsFinder, findsOneWidget);

      // Verify notification settings menu subtitle
      expect(find.text('Manage app notification settings'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // Tap on notification settings menu
      await tester.tap(notifSettingsFinder);
      await tester.pumpAndSettle();

      // Verify navigation to notification settings page
      expect(find.text('Notification Settings Page'), findsOneWidget);

      // Verify navigation was observed
      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('Navigates to edit profile page when edit button is pressed',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Edit Profile menu
      final editProfileFinder = find.text('Edit Profile');
      expect(editProfileFinder, findsOneWidget);
      expect(find.text('Update your profile information'), findsOneWidget);

      // Tap Edit Profile menu
      await tester.tap(editProfileFinder);
      await tester.pumpAndSettle();

      // Verify navigation to edit profile page
      expect(find.text('Edit Profile Page'), findsOneWidget);

      // Verify navigation was observed
      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('Check interaction with Edit Health Information menu',
        (WidgetTester tester) async {
      // Setup user data and service
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      
      // Setup mock preferences
      when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) async => false);
      when(mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) async => false);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Edit Health Information menu
      final editHealthInfoFinder = find.text('Edit Health Information');
      expect(editHealthInfoFinder, findsOneWidget);
      expect(find.text('Edit your health information'), findsOneWidget);

      // Tap Edit Health Information menu
      await tester.tap(editHealthInfoFinder);
      await tester.pumpAndSettle();

      // Verify navigation to height-weight page
      expect(find.text('Height Weight Page'), findsOneWidget);

      // Verify navigation was observed
      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('Check Report Bug menu exists and has correct content',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and scroll to Report Bug menu
      final bugReportFinder = find.text('Report Bug');
      await tester.dragUntilVisible(
        bugReportFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      expect(bugReportFinder, findsOneWidget);

      // Verify menu subtitle
      expect(find.text('Help us improve the app'), findsOneWidget);
      
      // Verify icon is correct
      final iconFinder = find.byIcon(Icons.bug_report_outlined);
      expect(iconFinder, findsOneWidget);
    });
    
    testWidgets('Report Bug uses proper URI for email launch',
        (WidgetTester tester) async {
      // Setup mocks for url_launcher
      final mockChannel = MethodChannel('plugins.flutter.io/url_launcher');
      final canLaunchLog = <String>[];
      final launchLog = <String>[];
      
      // Mock url_launcher methods
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mockChannel, (call) async {
        if (call.method == 'canLaunch') {
          canLaunchLog.add(call.arguments['url'] as String);
          return true;
        } else if (call.method == 'launch') {
          launchLog.add(call.arguments['url'] as String);
          return true;
        }
        return false;
      });
      
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockUser.email).thenReturn('test@example.com');
      
      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and scroll to Report Bug menu, then tap it
      final bugReportFinder = find.text('Report Bug');
      await tester.dragUntilVisible(
        bugReportFinder,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.tap(bugReportFinder);
      await tester.pumpAndSettle();
      
      // Verify the URL was constructed correctly
      expect(canLaunchLog.isNotEmpty, true, reason: 'canLaunch should be called');
      
      // Verify URI structure is correct (mailto: with query parameters)
      final uri = canLaunchLog.first;
      expect(uri.startsWith('mailto:pockeat.service@gmail.com'), true, 
            reason: 'URI should start with mailto to correct address');
      expect(uri.contains('subject='), true, 
            reason: 'URI should contain subject parameter');
      expect(uri.contains('body='), true, 
            reason: 'URI should contain body parameter');
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
      
      // Verify both toggles exist - Updated to English text
      expect(find.text('Count Burned Calories'), findsOneWidget);
      expect(find.text('Rollover Calories'), findsOneWidget);

      // Find all switches and toggle them
      final switches = find.byType(Switch);
      expect(switches, findsAtLeastNWidgets(2));

      // Setup service responses for when changes are made
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

    testWidgets('Both English and Indonesian text variations are handled',
        (WidgetTester tester) async {
      // Setup user data
      final testUser = createTestUser();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
          .thenAnswer((_) async => false);
      when(mockUserPreferencesService.isRolloverCaloriesEnabled())
          .thenAnswer((_) async => false);

      // Render widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The test should now look for English text only since the app has been updated
      // Check for English versions of the text
      final exerciseCalorieText = find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data?.contains('Count Burned Calories') == true ||
              widget.data?.contains('Burned calories will be added') == true));

      final rolloverCaloriesText = find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data?.contains('Rollover Calories') == true ||
              widget.data?.contains('Unused calories will be accumulated') == true));

      expect(exerciseCalorieText, findsAtLeastNWidgets(1));
      expect(rolloverCaloriesText, findsAtLeastNWidgets(1));
    });
  });
}
