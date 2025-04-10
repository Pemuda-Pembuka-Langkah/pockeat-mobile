import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/presentation/screens/edit_profile_page.dart';
import 'package:pockeat/features/authentication/services/profile_service.dart';

@GenerateMocks([ProfileService, File, NavigatorObserver])
import 'edit_profile_page_test.mocks.dart';

// Class untuk menangkap SnackBar message
class MockBuildContext extends Mock implements BuildContext {
  final List<String> snackBarMessages = [];
  final List<Color?> snackBarColors = [];

  void showSnackBar(SnackBar snackBar) {
    final Text textWidget = snackBar.content as Text;
    snackBarMessages.add(textWidget.data ?? '');
    snackBarColors.add(snackBar.backgroundColor);
  }
}

void main() {
  group('EditProfilePage Tests', () {
    late MockProfileService mockProfileService;
    late UserModel testUser;
    late UserModel unverifiedUser;
    late MockBuildContext mockContext;
    final getIt = GetIt.instance;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockProfileService = MockProfileService();
      mockContext = MockBuildContext();

      // Register mock service ke GetIt
      if (getIt.isRegistered<ProfileService>()) {
        getIt.unregister<ProfileService>();
      }
      getIt.registerSingleton<ProfileService>(mockProfileService);

      testUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL:
            null, // Menggunakan null untuk menghindari network image issue
        emailVerified: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      unverifiedUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: null,
        emailVerified: false, // User belum diverifikasi
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    });

    tearDown(() {
      // Clean up GetIt instance
      if (getIt.isRegistered<ProfileService>()) {
        getIt.unregister<ProfileService>();
      }
    });

    // Helper untuk membuat test widget
    Widget createTestWidget({UserModel? initialUser}) {
      return MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: EditProfilePage(
              initialUser: initialUser,
              useScaffold: true, // Gunakan true untuk test SnackBar
            ),
          ),
        ),
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      );
    }

    testWidgets('renders profile edit form with initial data',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(initialUser: testUser));
      await tester.pump(const Duration(seconds: 1));

      // Verifikasi UI dan data
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      expect(find.text('Nama'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Email terverifikasi'), findsOneWidget);

      final nameField = tester.widget<TextField>(find.byType(TextField).at(0));
      expect(nameField.controller?.text, equals('Test User'));

      final emailField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(emailField.controller?.text, equals('test@example.com'));
    });

    testWidgets('shows loading indicator when loading user data',
        (WidgetTester tester) async {
      when(mockProfileService.getCurrentUser()).thenAnswer((_) =>
          Future.delayed(const Duration(milliseconds: 500), () => testUser));

      await tester.pumpWidget(createTestWidget()); // Tanpa initial user
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error view when loading fails',
        (WidgetTester tester) async {
      when(mockProfileService.getCurrentUser())
          .thenAnswer((_) => Future.delayed(
                const Duration(milliseconds: 100),
                () => throw Exception('Network error'),
              ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 200));

      // Verifikasi pesan error dan "Coba Lagi" button
      expect(find.textContaining('Network error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('retry button reloads data after error',
        (WidgetTester tester) async {
      // First request fails
      when(mockProfileService.getCurrentUser())
          .thenAnswer((_) => Future.delayed(
                const Duration(milliseconds: 100),
                () => throw Exception('Network error'),
              ));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 200));

      // Verify error is shown
      expect(find.textContaining('Network error'), findsOneWidget);

      // Second request succeeds
      when(mockProfileService.getCurrentUser())
          .thenAnswer((_) => Future.delayed(
                const Duration(milliseconds: 100),
                () => testUser,
              ));

      // Tap retry button
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));

      // Verify data is loaded
      expect(find.text('Nama'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('validates empty display name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(initialUser: testUser));
      await tester.pump(const Duration(seconds: 1));

      // Clear name field
      await tester.enterText(find.byType(TextField).at(0), '');

      // Tap save button
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();

      // Verifikasi pesan validasi melalui SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('updates profile successfully', (WidgetTester tester) async {
      // Set up success response
      when(mockProfileService.updateUserProfile(
        displayName: 'New Name',
        photoURL: null,
      )).thenAnswer((_) => Future.value(true));

      await tester.pumpWidget(createTestWidget(initialUser: testUser));
      await tester.pump(const Duration(seconds: 1));

      // Enter new name
      await tester.enterText(find.byType(TextField).at(0), 'New Name');

      // Tap save button
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));

      // Verifikasi pesan sukses melalui SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Profil berhasil diperbarui'), findsOneWidget);
    });

    testWidgets('shows error when update fails', (WidgetTester tester) async {
      // Set up failure response
      when(mockProfileService.updateUserProfile(
        displayName: 'New Name',
        photoURL: null,
      )).thenAnswer((_) => Future.value(false));

      await tester.pumpWidget(createTestWidget(initialUser: testUser));
      await tester.pump(const Duration(seconds: 1));

      // Enter new name
      await tester.enterText(find.byType(TextField).at(0), 'New Name');

      // Tap save button
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify error message is displayed
      expect(find.text('Gagal memperbarui profil'), findsOneWidget);
    });

    testWidgets('shows verification email button for unverified user',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(initialUser: unverifiedUser));
      await tester.pump(const Duration(seconds: 1));

      // Verify unverified status
      expect(find.text('Email belum terverifikasi'), findsOneWidget);
      expect(find.text('Kirim verifikasi'), findsOneWidget);
    });

    testWidgets('sends verification email successfully',
        (WidgetTester tester) async {
      // Set up success response
      when(mockProfileService.sendEmailVerification())
          .thenAnswer((_) => Future.value(true));

      await tester.pumpWidget(createTestWidget(initialUser: unverifiedUser));
      await tester.pump(const Duration(seconds: 1));

      // Tap verification button
      await tester.tap(find.text('Kirim verifikasi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifikasi pesan sukses melalui SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email verifikasi telah dikirim'), findsOneWidget);
    });

    testWidgets('shows error when sending verification email fails',
        (WidgetTester tester) async {
      // Set up failure response
      when(mockProfileService.sendEmailVerification())
          .thenAnswer((_) => Future.value(false));

      await tester.pumpWidget(createTestWidget(initialUser: unverifiedUser));
      await tester.pump(const Duration(seconds: 1));

      // Tap verification button
      await tester.tap(find.text('Kirim verifikasi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifikasi pesan error melalui SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Gagal mengirim email verifikasi'), findsOneWidget);
    });
  });
}
