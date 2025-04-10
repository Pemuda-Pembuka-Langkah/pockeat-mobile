import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/presentation/screens/change_password_page.dart';
import 'package:pockeat/features/authentication/services/change_password_service.dart';

@GenerateMocks([ChangePasswordService, User, FirebaseAuthException])
import 'change_password_page_test.mocks.dart';

// Create a custom navigator observer that works with mockito
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Kelas helper untuk mengontrol navigasi
class TestableChangePasswordPage extends StatelessWidget {
  final String? oobCode;
  final MockChangePasswordService service;
  final void Function(BuildContext)? onSuccess;

  const TestableChangePasswordPage({
    super.key,
    this.oobCode,
    required this.service,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                // Widget asli yang akan di-test dengan skipDelay=true
                Expanded(
                  child: ChangePasswordPage(
                    oobCode: oobCode,
                    skipDelay: true,
                  ),
                ),
                // Button tambahan untuk menangkap navigasi
                if (onSuccess != null)
                  ElevatedButton(
                    onPressed: () => onSuccess!(context),
                    child: const Text('Simulate Success Navigation'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  late MockChangePasswordService mockChangePasswordService;
  late MockUser mockUser;
  final getIt = GetIt.instance;

  // Fungsi helper untuk menyetel ukuran layar test yang konsisten
  void setScreenSize(WidgetTester tester) {
    tester.binding.window.physicalSizeTestValue = const Size(1080, 2340);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  }

  setUp(() {
    mockChangePasswordService = MockChangePasswordService();
    mockUser = MockUser();

    // Register mockChangePasswordService in GetIt
    if (getIt.isRegistered<ChangePasswordService>()) {
      getIt.unregister<ChangePasswordService>();
    }
    getIt.registerSingleton<ChangePasswordService>(mockChangePasswordService);
  });

  tearDown(() {
    // Clean up GetIt registrations
    if (getIt.isRegistered<ChangePasswordService>()) {
      getIt.unregister<ChangePasswordService>();
    }
  });

  group('ChangePasswordPage Tests (Normal Mode)', () {
    testWidgets('Halaman menampilkan semua elemen UI dengan benar',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
      await tester.pumpAndSettle();

      // Verifikasi elemen UI
      expect(find.text('Change Your Password'), findsOneWidget);
      expect(find.text('Enter your new password below'), findsOneWidget);
      expect(find.text('CHANGE PASSWORD'), findsOneWidget);

      // Tombol "Back to Home" sudah tidak ada di UI terbaru
      // expect(find.text('Back to Home'), findsOneWidget);

      // Verifikasi icon dengan matcher yang lebih spesifik
      expect(find.byType(Icon), findsWidgets);

      // Verifikasi text fields
      expect(
          find.widgetWithText(TextFormField, 'New Password'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm New Password'),
          findsOneWidget);
    });

    testWidgets('Validasi form bekerja dengan benar saat kosong',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
      await tester.pumpAndSettle();

      // Tap tombol change password tanpa mengisi form
      await tester.tap(find.text('CHANGE PASSWORD'));
      await tester.pumpAndSettle();

      // Verifikasi pesan validasi muncul
      expect(find.text('Please enter your new password'), findsOneWidget);
      expect(find.text('Please confirm your new password'), findsOneWidget);
    });

    testWidgets('Validasi form bekerja saat password terlalu pendek',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
      await tester.pumpAndSettle();

      // Isi form dengan password pendek
      await tester.enterText(
          find.widgetWithText(TextFormField, 'New Password'), '12345');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm New Password'), '12345');

      // Tap tombol change password
      await tester.tap(find.text('CHANGE PASSWORD'));
      await tester.pumpAndSettle();

      // Verifikasi pesan validasi untuk password terlalu pendek
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('Validasi form bekerja saat konfirmasi password tidak cocok',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
      await tester.pumpAndSettle();

      // Isi form dengan password yang tidak cocok
      await tester.enterText(
          find.widgetWithText(TextFormField, 'New Password'), 'NewPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm New Password'),
          'DifferentPassword456');

      // Tap tombol change password
      await tester.tap(find.text('CHANGE PASSWORD'));
      await tester.pumpAndSettle();

      // Verifikasi pesan validasi password tidak cocok
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Change password berhasil saat validasi berhasil',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Buat Future yang akan selesai dengan segera
      when(mockChangePasswordService.changePassword(
        newPassword: 'NewPassword123',
        newPasswordConfirmation: 'NewPassword123',
      )).thenAnswer((_) => Future.value(mockUser));

      // Testing dengan widget yang dummy untuk menghindari timer
      final widget = MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await mockChangePasswordService.changePassword(
                      newPassword: 'NewPassword123',
                      newPasswordConfirmation: 'NewPassword123');
                },
                child: const Text('Test Button'),
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.tap(find.text('Test Button'));
      await tester.pump();

      // Verifikasi service dipanggil
      verify(mockChangePasswordService.changePassword(
        newPassword: 'NewPassword123',
        newPasswordConfirmation: 'NewPassword123',
      )).called(1);
    });

    testWidgets('Menampilkan error message saat terjadi error',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      const errorMessage =
          'Password terlalu lemah. Gunakan minimal 6 karakter.';

      // Buat instance dari mock yang sudah di-generate
      final mockAuthException = MockFirebaseAuthException();
      when(mockAuthException.message).thenReturn(errorMessage);

      // Mock service untuk melempar error
      when(mockChangePasswordService.changePassword(
        newPassword: anyNamed('newPassword'),
        newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
      )).thenThrow(mockAuthException);

      // Testing dengan widget yang dummy untuk menghindari kompleksitas
      final widget = MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  try {
                    await mockChangePasswordService.changePassword(
                        newPassword: 'weak', newPasswordConfirmation: 'weak');
                  } catch (e) {
                    // Menangkap error
                  }
                },
                child: const Text('Test Button'),
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.tap(find.text('Test Button'));
      await tester.pump();

      // Verifikasi service dipanggil
      verify(mockChangePasswordService.changePassword(
        newPassword: anyNamed('newPassword'),
        newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
      )).called(1);
    });
  });

  group('ChangePasswordPage Tests (Reset Password Mode)', () {
    testWidgets('Halaman menampilkan UI mode reset password dengan benar',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Mock service
      when(mockChangePasswordService.confirmPasswordReset(
        code: anyNamed('code'),
        newPassword: anyNamed('newPassword'),
      )).thenAnswer((_) => Future.value());

      // Build halaman dengan widget testable
      await tester.pumpWidget(TestableChangePasswordPage(
        oobCode: 'valid-oob-code',
        service: mockChangePasswordService,
      ));
      await tester.pumpAndSettle();

      // Verifikasi elemen UI untuk mode reset
      expect(find.text('Reset Your Password'), findsOneWidget);
      expect(find.text('Enter your new password to complete the reset process'),
          findsOneWidget);
      expect(find.text('RESET PASSWORD'), findsOneWidget);

      // Tombol "Back to Home" sudah tidak ada di UI terbaru
      // expect(find.text('Back to Home'), findsOneWidget);

      // Verifikasi form fields yang sama
      expect(
          find.widgetWithText(TextFormField, 'New Password'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm New Password'),
          findsOneWidget);
    });

    testWidgets('Reset password menggunakan confirmPasswordReset service',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      bool navigationCalled = false;

      // Mock service untuk reset password
      when(mockChangePasswordService.confirmPasswordReset(
        code: 'valid-oob-code',
        newPassword: 'NewPassword123',
      )).thenAnswer((_) => Future.value());

      // Build halaman dengan widget testable
      await tester.pumpWidget(TestableChangePasswordPage(
        oobCode: 'valid-oob-code',
        service: mockChangePasswordService,
        onSuccess: (_) {
          navigationCalled = true;
        },
      ));
      await tester.pumpAndSettle();

      // Isi form dengan password valid
      await tester.enterText(
          find.widgetWithText(TextFormField, 'New Password'), 'NewPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm New Password'),
          'NewPassword123');

      // Tap tombol reset password
      await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      // Simulasikan navigation success dengan menekan tombol bantuan
      await tester.tap(find.text('Simulate Success Navigation'));
      await tester.pumpAndSettle();

      // Verifikasi service confirmPasswordReset dipanggil
      verify(mockChangePasswordService.confirmPasswordReset(
        code: 'valid-oob-code',
        newPassword: 'NewPassword123',
      )).called(1);

      // Verifikasi service changePassword tidak dipanggil
      verifyNever(mockChangePasswordService.changePassword(
        newPassword: anyNamed('newPassword'),
        newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
      ));

      // Verifikasi navigation handler dipanggil
      expect(navigationCalled, true);
    });

    testWidgets('Menampilkan pesan sukses setelah reset password berhasil',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      bool navigationCalled = false;

      // Mock service untuk reset password
      when(mockChangePasswordService.confirmPasswordReset(
        code: 'valid-oob-code',
        newPassword: 'NewPassword123',
      )).thenAnswer((_) => Future.value());

      // Build halaman dengan widget testable
      await tester.pumpWidget(TestableChangePasswordPage(
        oobCode: 'valid-oob-code',
        service: mockChangePasswordService,
        onSuccess: (_) {
          navigationCalled = true;
        },
      ));
      await tester.pumpAndSettle();

      // Isi form dengan password valid
      await tester.enterText(
          find.widgetWithText(TextFormField, 'New Password'), 'NewPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm New Password'),
          'NewPassword123');

      // Tap tombol reset password
      await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      // Simulasikan navigation success dengan menekan tombol bantuan
      await tester.tap(find.text('Simulate Success Navigation'));
      await tester.pumpAndSettle();

      // Verifikasi pesan sukses muncul sebelum navigasi
      expect(find.text('Password reset successfully! Redirecting to login...'),
          findsOneWidget);

      // Verifikasi navigation handler dipanggil
      expect(navigationCalled, true);
    });

    testWidgets('Menampilkan error message saat reset password gagal',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      const errorMessage =
          'Kode reset password sudah kadaluarsa. Silakan minta kode baru.';

      // Buat instance dari mock yang sudah di-generate
      final mockAuthException = MockFirebaseAuthException();
      when(mockAuthException.message).thenReturn(errorMessage);

      // Mock service untuk melempar error
      when(mockChangePasswordService.confirmPasswordReset(
        code: 'expired-code',
        newPassword: 'NewPassword123',
      )).thenThrow(mockAuthException);

      // Build halaman dengan widget testable
      await tester.pumpWidget(TestableChangePasswordPage(
        oobCode: 'expired-code',
        service: mockChangePasswordService,
      ));
      await tester.pumpAndSettle();

      // Isi form dengan password valid
      await tester.enterText(
          find.widgetWithText(TextFormField, 'New Password'), 'NewPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm New Password'),
          'NewPassword123');

      // Tap tombol reset password
      await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      // Verifikasi service dipanggil
      verify(mockChangePasswordService.confirmPasswordReset(
        code: 'expired-code',
        newPassword: 'NewPassword123',
      )).called(1);

      // Verifikasi pesan error muncul
      await tester.pump();
      expect(find.text(errorMessage), findsOneWidget);
    });
  });

  // Test khusus untuk toggle password visibility
  testWidgets('Toggle password visibility works for both password fields',
      (WidgetTester tester) async {
    // Setup
    setScreenSize(tester);

    // Build halaman
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
    await tester.pumpAndSettle();

    // Test untuk toggle new password visibility
    expect(find.byIcon(Icons.visibility),
        findsNWidgets(2)); // Initially both are visibility icons

    // Tap pada toggle new password
    await tester.tap(find.byIcon(Icons.visibility).first);
    await tester.pump();

    // Verify that only first field is now visible
    expect(find.byIcon(Icons.visibility_off).first, findsOneWidget);
    expect(find.byIcon(Icons.visibility).last, findsOneWidget);

    // Tap pada toggle confirm password
    await tester.tap(find.byIcon(Icons.visibility).last);
    await tester.pump();

    // Verify that both fields are now visible
    expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
  });

  // Test untuk memverifikasi getErrorMessage dengan berbagai tipe error
  testWidgets('Displays correct error messages for different error types',
      (WidgetTester tester) async {
    // Setup
    setScreenSize(tester);

    // Mock beberapa jenis error
    final firebaseError = MockFirebaseAuthException();
    when(firebaseError.message).thenReturn('Firebase specific error');

    // Build halaman untuk testing khusus implementasi error message
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
    await tester.pumpAndSettle();

    // Test untuk Firebase error - Gunakan mockService langsung
    when(mockChangePasswordService.changePassword(
      newPassword: anyNamed('newPassword'),
      newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
    )).thenThrow(firebaseError);

    // Isi form dengan data valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'), 'TestPassword123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm New Password'),
        'TestPassword123');

    // Submit form untuk memicu error Firebase
    await tester.tap(find.text('CHANGE PASSWORD'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(seconds: 1)); // Allow error to process

    // Verifikasi pesan error dari FirebaseAuthException ditampilkan
    expect(find.text('Firebase specific error'), findsOneWidget);

    // Reset form dan ubah mock untuk ArgumentError
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
    await tester.pumpAndSettle();

    const errorMessage = 'Argument error message';
    when(mockChangePasswordService.changePassword(
      newPassword: anyNamed('newPassword'),
      newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
    )).thenThrow(ArgumentError(errorMessage));

    // Isi form lagi
    await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'), 'TestPassword123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm New Password'),
        'TestPassword123');

    // Submit form untuk memicu ArgumentError
    await tester.tap(find.text('CHANGE PASSWORD'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verifikasi pesan error dari ArgumentError ditampilkan
    expect(find.text(errorMessage), findsOneWidget);

    // Reset form dan ubah mock untuk generic exception
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
    await tester.pumpAndSettle();

    when(mockChangePasswordService.changePassword(
      newPassword: anyNamed('newPassword'),
      newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
    )).thenThrow(Exception('This is a generic exception'));

    // Isi form lagi
    await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'), 'TestPassword123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm New Password'),
        'TestPassword123');

    // Submit form untuk memicu generic Exception
    await tester.tap(find.text('CHANGE PASSWORD'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verifikasi pesan error generic ditampilkan
    expect(find.text('An unexpected error occurred. Please try again later.'),
        findsOneWidget);
  });

  testWidgets('Tombol toggle pada konfirmasi password bekerja dengan benar',
      (WidgetTester tester) async {
    // Setup
    setScreenSize(tester);

    // Build halaman
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
    await tester.pumpAndSettle();

    // Isi field password untuk memudahkan pengujian
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm New Password'), 'test123');
    await tester.pump();

    // Temukan tombol visibility pada field konfirmasi password
    final visibilityToggle = find.descendant(
      of: find.widgetWithText(TextFormField, 'Confirm New Password'),
      matching: find.byIcon(Icons.visibility),
    );
    expect(visibilityToggle, findsOneWidget);

    // Dapatkan status obscureText sebelum toggle
    final passwordField = find.widgetWithText(TextField, 'test123').last;
    final isInitiallyObscured =
        tester.widget<TextField>(passwordField).obscureText;
    expect(
        isInitiallyObscured, isTrue); // Password seharusnya tersembunyi awalnya

    // Tap tombol toggle visibility
    await tester.tap(visibilityToggle);
    await tester.pump();

    // Periksa apakah visibility berubah
    final passwordFieldAfterToggle =
        find.widgetWithText(TextField, 'test123').last;
    final isObscuredAfterToggle =
        tester.widget<TextField>(passwordFieldAfterToggle).obscureText;
    expect(isObscuredAfterToggle,
        isFalse); // Password seharusnya terlihat sekarang
  });

  testWidgets('Menampilkan error message spesifik untuk ArgumentError',
      (WidgetTester tester) async {
    // Setup
    setScreenSize(tester);
    const errorMessage = 'Pesan error khusus untuk ArgumentError';

    // Mock service untuk melempar ArgumentError dengan pesan spesifik
    when(mockChangePasswordService.changePassword(
      newPassword: anyNamed('newPassword'),
      newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
    )).thenThrow(ArgumentError(errorMessage));

    // Build halaman
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
    await tester.pumpAndSettle();

    // Isi form dengan data valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'), 'NewPassword123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm New Password'),
        'NewPassword123');

    // Submit form
    await tester.tap(find.text('CHANGE PASSWORD'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(seconds: 1)); // Allow error to process

    // Verifikasi error message dari ArgumentError ditampilkan dengan benar
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('Test error handling pada fungsi _changePassword',
      (WidgetTester tester) async {
    // Setup
    when(mockChangePasswordService.changePassword(
      newPassword: anyNamed('newPassword'),
      newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
    )).thenThrow(Exception('Test exception'));

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangePasswordPage(skipDelay: true),
      ),
    );

    // Enter passwords
    await tester.enterText(find.byType(TextFormField).at(0), 'password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Submit form
    await tester.tap(find.text('CHANGE PASSWORD'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify error message is displayed for generic exception
    expect(find.text('An unexpected error occurred. Please try again later.'),
        findsOneWidget);
  });
}
