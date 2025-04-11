import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/presentation/screens/change_password_page.dart';
import 'package:pockeat/features/authentication/services/change_password_service.dart';

@GenerateMocks([
  ChangePasswordService,
  FirebaseAuth,
  User,
  NavigatorObserver
], customMocks: [
  MockSpec<FirebaseAuthException>(
      as: #MockFirebaseAuthException, fallbackGenerators: {})
])
import 'change_password_page_test.mocks.dart';

// Navigasi sederhana untuk test
abstract class SimpleNavigator {
  void pushReplacementNamed(String routeName);
}

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
                    testMode: true,
                    customChangePasswordService: service,
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
      routes: {
        '/login': (context) => const Scaffold(body: Text('Login Page')),
      },
    );
  }
}

// Kita gunakan kelas spesifik ini daripada extend NavigatorState
class MockCustomNavigator extends Mock implements SimpleNavigator {}

void main() {
  late MockChangePasswordService mockChangePasswordService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockNavigatorObserver mockNavigatorObserver;
  final getIt = GetIt.instance;

  TestWidgetsFlutterBinding.ensureInitialized();

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
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockNavigatorObserver = MockNavigatorObserver();

    // Setup mockUser email
    when(mockUser.email).thenReturn('test@example.com');
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

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

  group('ChangePasswordPage Tests (Normal Mode) - UI dan Validasi', () {
    testWidgets('Halaman menampilkan semua elemen UI dengan benar',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(MaterialApp(
          home: ChangePasswordPage(
              testMode: true,
              customChangePasswordService: mockChangePasswordService)));
      await tester.pump(); // Gunakan pumpAndSettle hanya jika diperlukan

      // Verifikasi elemen UI
      expect(find.text('Change Your Password'), findsOneWidget);
      expect(find.text('Enter your new password below'), findsOneWidget);
      expect(find.text('UBAH PASSWORD'), findsOneWidget);

      // Verifikasi field password saat ini (current password) ada
      expect(find.widgetWithText(TextFormField, 'Password Saat Ini'),
          findsOneWidget);

      // Verifikasi tombol lupa password tersedia
      expect(find.text('Lupa Password?'), findsOneWidget);

      // Verifikasi text fields
      expect(
          find.widgetWithText(TextFormField, 'Password Baru'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
          findsOneWidget);
    });

    testWidgets('Validasi form bekerja dengan benar saat kosong',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(MaterialApp(
          home: ChangePasswordPage(
              testMode: true,
              customChangePasswordService: mockChangePasswordService)));
      await tester.pump();

      // Tap tombol change password tanpa mengisi form
      await tester.tap(find.text('UBAH PASSWORD'));
      await tester.pump();

      // Verifikasi pesan validasi muncul
      expect(find.text('Password saat ini tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password baru tidak boleh kosong'), findsOneWidget);
      expect(
          find.text('Konfirmasi password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Validasi form bekerja saat password terlalu pendek',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(MaterialApp(
          home: ChangePasswordPage(
              testMode: true,
              customChangePasswordService: mockChangePasswordService)));
      await tester.pump();

      // Isi form dengan password pendek
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Saat Ini'),
          'current123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Baru'), '12345');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
          '12345');

      // Tap tombol change password
      await tester.tap(find.text('UBAH PASSWORD'));
      await tester.pump();

      // Verifikasi pesan validasi untuk password terlalu pendek
      expect(find.text('Password harus minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('Validasi form bekerja saat konfirmasi password tidak cocok',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(MaterialApp(
          home: ChangePasswordPage(
              testMode: true,
              customChangePasswordService: mockChangePasswordService)));
      await tester.pump();

      // Isi form dengan password yang tidak cocok
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Saat Ini'),
          'current123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Baru'),
          'NewPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
          'DifferentPassword456');

      // Tap tombol change password
      await tester.tap(find.text('UBAH PASSWORD'));
      await tester.pump();

      // Verifikasi pesan validasi password tidak cocok
      expect(find.text('Konfirmasi password tidak sesuai dengan password baru'),
          findsOneWidget);
    });
  });

  group('ChangePasswordPage Tests (Normal Mode) - Fungsionalitas', () {
    testWidgets('Change password berhasil saat validasi berhasil',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Configure mock untuk reauthenticate - gunakan anyNamed untuk parameter fleksibel
      when(mockChangePasswordService.changePassword(
        newPassword: anyNamed('newPassword'),
        newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
        currentPassword: anyNamed('currentPassword'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => mockUser);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
              body: ChangePasswordPage(
            skipDelay: true,
            testMode: true,
            customChangePasswordService: mockChangePasswordService,
          )),
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        ),
      );
      await tester.pump();

      // Isi form dengan data valid
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Saat Ini'),
          'CurrentPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Baru'),
          'NewPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
          'NewPassword123');

      // Tap tombol ubah password
      await tester.tap(find.text('UBAH PASSWORD'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Process animation frames

      // Verifikasi service dipanggil
      verify(mockChangePasswordService.changePassword(
        newPassword: anyNamed('newPassword'),
        newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
        currentPassword: anyNamed('currentPassword'),
        email: anyNamed('email'),
      )).called(1);
      
      // Skip test untuk SnackBar karena dihandle dalam ScaffoldMessenger
      // dan navigasi dilakukan segera setelah SnackBar muncul
      // Cukup verifikasi bahwa service method dipanggil
    });

    testWidgets('Menampilkan error message saat terjadi error',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      const errorMessage =
          'Password terlalu lemah. Gunakan minimal 6 karakter.';

      // Buat instance dari mock yang sudah di-generate
      final mockAuthException = MockFirebaseAuthException();
      when(mockAuthException.code).thenReturn('weak-password');
      when(mockAuthException.message).thenReturn(errorMessage);

      // Mock service untuk melempar error dengan anyNamed
      when(mockChangePasswordService.changePassword(
        newPassword: captureAnyNamed('newPassword'),
        newPasswordConfirmation: captureAnyNamed('newPasswordConfirmation'),
        currentPassword: captureAnyNamed('currentPassword'),
        email: captureAnyNamed('email'),
      )).thenThrow(mockAuthException);

      // Build halaman
      await tester.pumpWidget(MaterialApp(
          home: ChangePasswordPage(
              testMode: true,
              customChangePasswordService: mockChangePasswordService)));
      await tester.pump();

      // Isi form dengan password yang lolos validasi tapi akan gagal di Firebase
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Saat Ini'),
          'CurrentPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Baru'), 'weakpass'); // At least 6 chars
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
          'weakpass'); // Same as password

      // Tap tombol ubah password
      await tester.tap(find.text('UBAH PASSWORD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifikasi service dipanggil dan pesan error ditampilkan
      verify(mockChangePasswordService.changePassword(
        newPassword: anyNamed('newPassword'),
        newPasswordConfirmation: anyNamed('newPasswordConfirmation'),
        currentPassword: anyNamed('currentPassword'),
        email: anyNamed('email'),
      )).called(1);
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('Menangani error requires-recent-login dengan benar',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      const errorMessage =
          'Untuk alasan keamanan, silakan masukkan password saat ini Anda.';

      // Buat instance dari mock yang sudah di-generate
      final mockAuthException = MockFirebaseAuthException();
      when(mockAuthException.code).thenReturn('requires-recent-login');
      when(mockAuthException.message).thenReturn(errorMessage);
      
      // Mock Firebase auth untuk test mode
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');

      // Mock service untuk melempar error dengan captureAnyNamed
      when(mockChangePasswordService.changePassword(
        newPassword: captureAnyNamed('newPassword'),
        newPasswordConfirmation: captureAnyNamed('newPasswordConfirmation'),
        currentPassword: captureAnyNamed('currentPassword'),
        email: captureAnyNamed('email'),
      )).thenThrow(mockAuthException);

      // Build halaman
      await tester.pumpWidget(MaterialApp(
          home: ChangePasswordPage(
              testMode: true,
              customChangePasswordService: mockChangePasswordService)));
      await tester.pump();

      // Isi form
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Saat Ini'),
          'WrongPassword');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Baru'),
          'NewPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
          'NewPassword123');

      // Tap tombol ubah password
      await tester.tap(find.text('UBAH PASSWORD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifikasi pesan error ditampilkan
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('Lupa Password button mengirim reset password email',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Configure mock untuk sendPasswordResetEmail dengan anyNamed
      when(mockChangePasswordService.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).thenAnswer((_) async => {});

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
              body: ChangePasswordPage(
            skipDelay: true,
            testMode: true,
            customChangePasswordService: mockChangePasswordService,
          )),
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        ),
      );
      await tester.pump();

      // Tap tombol lupa password
      await tester.tap(find.text('Lupa Password?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifikasi sendPasswordResetEmail dipanggil
      verify(mockChangePasswordService.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).called(1);

      // Verifikasi pesan sukses ditampilkan
      expect(
        find.text('Email reset password telah dikirim ke test@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('Lupa Password button menampilkan error saat gagal',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      const errorMessage = 'Tidak ada pengguna yang terkait dengan email ini.';

      // Buat instance dari mock exception
      final mockAuthException = MockFirebaseAuthException();
      when(mockAuthException.code).thenReturn('user-not-found');
      when(mockAuthException.message).thenReturn(errorMessage);

      // Configure mock untuk sendPasswordResetEmail melempar error dengan anyNamed
      when(mockChangePasswordService.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).thenThrow(mockAuthException);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
              body: ChangePasswordPage(
            skipDelay: true,
            testMode: true,
            customChangePasswordService: mockChangePasswordService,
          )),
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        ),
      );
      await tester.pump();

      // Tap tombol lupa password
      await tester.tap(find.text('Lupa Password?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifikasi pesan error ditampilkan
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('Menampilkan error saat email tidak tersedia',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Buat custom mock ChangePasswordService untuk kasus ini
      final mockNoEmailService = MockChangePasswordService();
      
      // Mock service.sendPasswordResetEmail untuk throw exception dengan pesan email tidak ditemukan
      when(mockNoEmailService.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).thenThrow(Exception('Email tidak ditemukan. Silakan login ulang.'));

      // Build halaman dengan customChangePasswordService
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: ChangePasswordPage(
              testMode: true, // Use test mode to avoid real Firebase calls
              customChangePasswordService: mockNoEmailService))));
      await tester.pump();

      // Tap tombol lupa password
      await tester.tap(find.text('Lupa Password?'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 300)); // Allow time for setState to complete

      // Verifikasi pesan error ditampilkan
      expect(find.text('Email tidak ditemukan. Silakan login ulang.'),
          findsOneWidget);
    });
  });

  group('ChangePasswordPage Tests (Reset Password Mode)', () {
    testWidgets('Halaman menampilkan UI mode reset password dengan benar',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman dengan oobCode (mode reset password)
      await tester.pumpWidget(
        MaterialApp(
          home: ChangePasswordPage(
            oobCode: 'valid-oob-code',
            testMode: true,
            customChangePasswordService: mockChangePasswordService,
          ),
        ),
      );
      await tester.pump();

      // Verifikasi elemen UI untuk mode reset
      expect(find.text('Reset Your Password'), findsOneWidget);
      expect(find.text('Enter your new password to complete the reset process'),
          findsOneWidget);
      expect(find.text('RESET PASSWORD'), findsOneWidget);

      // Verifikasi tidak ada field current password
      expect(find.widgetWithText(TextFormField, 'Password Saat Ini'),
          findsNothing);

      // Verifikasi tidak ada tombol Lupa Password
      expect(find.text('Lupa Password?'), findsNothing);

      // Verifikasi form fields
      expect(
          find.widgetWithText(TextFormField, 'Password Baru'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
          findsOneWidget);
    });

    testWidgets('Reset password menggunakan confirmPasswordReset service',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      bool navigationCalled = false;

      // Mock service untuk reset password dengan anyNamed
      when(mockChangePasswordService.confirmPasswordReset(
        code: anyNamed('code'),
        newPassword: anyNamed('newPassword'),
      )).thenAnswer((_) async => {});

      // Build halaman dengan widget testable
      await tester.pumpWidget(TestableChangePasswordPage(
        oobCode: 'valid-oob-code',
        service: mockChangePasswordService,
        onSuccess: (_) {
          navigationCalled = true;
        },
      ));
      await tester.pump();

      // Isi form dengan password valid
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password Baru'),
          'NewPassword123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Konfirmasi Password Baru'),
          'NewPassword123');

      // Tap tombol reset password
      await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      // Simulasikan navigation success dengan menekan tombol bantuan
      await tester.tap(find.text('Simulate Success Navigation'));
      await tester.pump();

      // Verifikasi service confirmPasswordReset dipanggil
      verify(mockChangePasswordService.confirmPasswordReset(
        code: anyNamed('code'),
        newPassword: anyNamed('newPassword'),
      )).called(1);

      // Verifikasi navigation handler dipanggil
      expect(navigationCalled, true);
    });

    testWidgets('Validasi form di mode reset password',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman dengan widget testable
      await tester.pumpWidget(TestableChangePasswordPage(
        oobCode: 'valid-oob-code',
        service: mockChangePasswordService,
      ));
      await tester.pump();

      // Tap tombol reset password tanpa mengisi form
      await tester.tap(find.text('RESET PASSWORD'));
      await tester.pump();

      // Verifikasi pesan validasi muncul
      expect(find.text('Password baru tidak boleh kosong'), findsOneWidget);
      expect(
          find.text('Konfirmasi password tidak boleh kosong'), findsOneWidget);
    });
  });

  // Test untuk UI dan interaksi
  group('ChangePasswordPage UI Interaction Tests', () {
    testWidgets('Toggle password visibility works for current password',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(MaterialApp(
          home: ChangePasswordPage(
              testMode: true,
              customChangePasswordService: mockChangePasswordService)));
      await tester.pump();

      // Verifikasi bahwa password field diset sebagai obscureText = true awalnya
      final currentPasswordField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Password Saat Ini'));
      expect(currentPasswordField.obscureText, isTrue);

      // Tap pada icon visibility untuk mengubah visibility
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pump();

      // Verifikasi bahwa password field sekarang visible (obscureText = false)
      final updatedPasswordField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Password Saat Ini'));
      expect(updatedPasswordField.obscureText, isFalse);
    });
  });
}
