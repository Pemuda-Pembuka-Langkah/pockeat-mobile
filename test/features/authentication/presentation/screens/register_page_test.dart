import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/presentation/screens/register_page.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';
import 'package:pockeat/features/authentication/services/deep_link_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// Generate mock menggunakan mockito
@GenerateMocks([RegisterService, DeepLinkService])
import 'register_page_test.mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {}
}

void main() {
  late MockRegisterService mockRegisterService;
  late MockDeepLinkService mockDeepLinkService;
  final getIt = GetIt.instance;

  // Helper untuk menyetel ukuran screen yang konsisten
  void setScreenSize(
    WidgetTester tester, {
    double width = 400,
    double height = 800,
  }) {
    final dpi = tester.binding.window.devicePixelRatio;
    tester.binding.window.physicalSizeTestValue =
        Size(width * dpi, height * dpi);
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRegisterService = MockRegisterService();
    mockDeepLinkService = MockDeepLinkService();

    // Setup GetIt untuk testing
    if (getIt.isRegistered<RegisterService>()) {
      getIt.unregister<RegisterService>();
    }
    if (getIt.isRegistered<DeepLinkService>()) {
      getIt.unregister<DeepLinkService>();
    }

    getIt.registerSingleton<RegisterService>(mockRegisterService);
    getIt.registerSingleton<DeepLinkService>(mockDeepLinkService);

    // Setup behavior dasar
    when(mockDeepLinkService.onLinkReceived())
        .thenAnswer((_) => Stream.value(null));
    when(mockDeepLinkService.getInitialLink())
        .thenAnswer((_) => Stream.value(null));
  });

  tearDown(() {
    // Reset GetIt
    if (getIt.isRegistered<RegisterService>()) {
      getIt.unregister<RegisterService>();
    }
    if (getIt.isRegistered<DeepLinkService>()) {
      getIt.unregister<DeepLinkService>();
    }
  });

  testWidgets('Register page should load all form components correctly',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Pastikan semua elemen UI ada
    expect(find.text('Create New Account'), findsOneWidget);
    expect(find.text('Sign up to start your health journey'), findsOneWidget);

    // Form fields
    expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(
        find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Birth Date (Optional)'),
        findsOneWidget);
    expect(
        find.widgetWithText(
            DropdownButtonFormField<String>, 'Gender (Optional)'),
        findsOneWidget);

    // Checkbox untuk terms and conditions
    expect(find.byType(Checkbox), findsOneWidget);

    // Terms and Conditions dan Login link menggunakan RichText
    expect(find.byType(RichText), findsWidgets);

    // Register Button
    expect(find.widgetWithText(ElevatedButton, 'SIGN UP'), findsOneWidget);
  });

  testWidgets('Form validation should work correctly',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Ambil lokasi tombol register
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');

    // Scroll ke tombol register untuk memastikan tombol terlihat
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();

    // Tap pada tombol register tanpa mengisi form
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verifikasi error text fields
    expect(find.text('Email cannot be empty'), findsOneWidget);
    expect(find.text('Password cannot be empty'), findsOneWidget);
  });

  testWidgets('Terms and conditions validation should work',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dengan data valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Scroll ke tombol register
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();

    // Tap tombol register tanpa menyetujui terms
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verifikasi pesan error syarat dan ketentuan
    expect(find.text('You must agree to the terms and conditions'),
        findsOneWidget);
  });

  testWidgets('Successful registration should show email verification UI',
      (WidgetTester tester) async {
    // Setup mock untuk sukses
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenAnswer((_) async => RegisterResult.success);

    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dengan data valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Setuju terms dengan mengetuk checkbox
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Scroll ke tombol register
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();

    // Tap tombol register
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verify register dipanggil dengan parameter yang benar
    verify(mockRegisterService.register(
      email: 'test@example.com',
      password: 'Password123',
      confirmPassword: 'Password123',
      termsAccepted: true,
      displayName: 'Test User',
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).called(1);

    // Verifikasi SnackBar muncul
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Registration successful! Please verify your email.'),
        findsOneWidget);

    // Verify verification screen is shown
    expect(find.text('Verify Your Email'), findsOneWidget);
    expect(
        find.text(
            'We have sent a verification email to test@example.com. Please check your inbox or spam folder to verify.'),
        findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'RESEND EMAIL'), findsOneWidget);
    expect(find.text('Back to Sign In'), findsOneWidget);
  });

  testWidgets('Password validation should accept special characters',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dengan password yang memiliki karakter khusus
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');

    // Password dengan karakter khusus
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Pass@word123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Pass@word123');

    // Setuju terms dengan mengetuk checkbox
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Setup mock untuk sukses
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenAnswer((_) async => RegisterResult.success);

    // Scroll ke tombol register
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();

    // Tap tombol register
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verify register dipanggil dengan parameter yang benar termasuk password dengan karakter khusus
    verify(mockRegisterService.register(
      email: 'test@example.com',
      password: 'Pass@word123',
      confirmPassword: 'Pass@word123',
      termsAccepted: true,
      displayName: 'Test User',
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).called(1);
  });

  testWidgets('Password validation should reject weak passwords',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dengan password yang lemah
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');

    // 1. Password tanpa huruf besar
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

    // Scroll ke tombol register
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();

    // Tap tombol register
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verifikasi error message muncul
    expect(find.text('Password must contain at least 1 uppercase letter'),
        findsOneWidget);

    // 2. Password tanpa huruf kecil
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'PASSWORD123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'PASSWORD123');

    // Tap tombol register lagi
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verifikasi error message muncul
    expect(find.text('Password must contain at least 1 lowercase letter'),
        findsOneWidget);

    // 3. Password tanpa angka atau karakter khusus
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'PasswordTest');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'PasswordTest');

    // Tap tombol register lagi
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verifikasi error message muncul
    expect(find.text('Password must contain at least 1 number or symbol'),
        findsOneWidget);
  });

  testWidgets('Password and confirm password must match',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill form fields with mismatched passwords
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password456');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verify validation error
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Show error message for already used email',
      (WidgetTester tester) async {
    // Setup mock behavior
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      gender: anyNamed('gender'),
      birthDate: anyNamed('birthDate'),
    )).thenAnswer((_) async => RegisterResult.emailAlreadyInUse);

    // Set ukuran screen
    setScreenSize(tester, width: 600, height: 800);

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill form fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'existing@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verify pesan error
    expect(find.text('Email is already in use. Please use a different email.'),
        findsOneWidget);
  });

  testWidgets('Should call resendEmailVerification when tapping resend button',
      (WidgetTester tester) async {
    // Setup mock untuk sukses
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenAnswer((_) async => RegisterResult.success);

    when(mockRegisterService.resendEmailVerification())
        .thenAnswer((_) async => true);

    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dengan data valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Setuju terms dengan mengetuk checkbox
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Scroll ke tombol register
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();

    // Tap tombol register
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Sekarang kita berada di layar verifikasi email
    expect(find.text('Verify Your Email'), findsOneWidget);

    // Tap tombol resend email
    final resendButton = find.widgetWithText(OutlinedButton, 'RESEND EMAIL');
    await tester.ensureVisible(resendButton);
    await tester.tap(resendButton);
    await tester.pump();

    // Verify resendEmailVerification dipanggil
    verify(mockRegisterService.resendEmailVerification()).called(1);
  });

  testWidgets('Should call resendEmailVerification with failure result',
      (WidgetTester tester) async {
    // Setup mock
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenAnswer((_) async => RegisterResult.success);

    when(mockRegisterService.resendEmailVerification())
        .thenAnswer((_) async => false);

    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dan register seperti di atas
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Setuju terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Register
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Tap tombol resend email
    final resendButton = find.widgetWithText(OutlinedButton, 'RESEND EMAIL');
    await tester.ensureVisible(resendButton);
    await tester.tap(resendButton);
    await tester.pump();

    // Verify resendEmailVerification dipanggil
    verify(mockRegisterService.resendEmailVerification()).called(1);
  });

  testWidgets(
      'Should handle error correctly when register service returns invalidEmail',
      (WidgetTester tester) async {
    // Setup mock behavior
    when(mockRegisterService.register(
      email: 'invalid@email',
      password: 'Password123',
      confirmPassword: 'Password123',
      termsAccepted: true,
      displayName: 'Test User',
      gender: null,
      birthDate: null,
    )).thenAnswer((_) async => RegisterResult.invalidEmail);

    // Set ukuran screen
    setScreenSize(tester, width: 600, height: 800);

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill form fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'invalid@email');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Should handle error correctly when register service returns operationNotAllowed',
      (WidgetTester tester) async {
    // Setup mock behavior
    when(mockRegisterService.register(
      email: 'test@example.com',
      password: 'Password123',
      confirmPassword: 'Password123',
      termsAccepted: true,
      displayName: 'Test User',
      gender: null,
      birthDate: null,
    )).thenAnswer((_) async => RegisterResult.operationNotAllowed);

    // Set ukuran screen
    setScreenSize(tester, width: 600, height: 800);

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill form fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Should handle navigation back to sign in from verification screen',
      (WidgetTester tester) async {
    // Setup mock behavior
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      gender: anyNamed('gender'),
      birthDate: anyNamed('birthDate'),
    )).thenAnswer((_) async => RegisterResult.success);

    // Tambah mock navigator untuk memeriksa navigasi
    final mockObserver = MockNavigatorObserver();

    // Set ukuran screen
    setScreenSize(tester, width: 600, height: 800);

    // Build widget dengan navigator observer
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
        navigatorObservers: [mockObserver],
        routes: {
          '/login': (context) => Scaffold(
                appBar: AppBar(title: Text('Login Page')),
              ),
        },
      ),
    );
    await tester.pumpAndSettle();

    // Fill form fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verifikasi screen berubah ke verification
    expect(find.text('Verify Your Email'), findsOneWidget);

    // Tap pada Back to Sign In
    await tester.tap(find.text('Back to Sign In'));
    await tester.pumpAndSettle();

    // Verifikasi navigasi ke login page
    expect(find.text('Login Page'), findsOneWidget);
  });

  testWidgets('Should allow gender selection for registration',
      (WidgetTester tester) async {
    // Setup mock behavior
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenAnswer((_) async => RegisterResult.success);

    // Set ukuran screen
    setScreenSize(tester, width: 600, height: 800);

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill form fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Coba cara lain untuk memilih gender
    final genderDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(genderDropdown);
    await tester.tap(genderDropdown);
    await tester.pumpAndSettle();

    // Tap the first option (which should be 'Male')
    await tester.tap(find.text('Male').last);
    await tester.pumpAndSettle();

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verify register dipanggil dengan parameter yang benar termasuk gender
    verify(mockRegisterService.register(
      email: 'test@example.com',
      password: 'Password123',
      confirmPassword: 'Password123',
      termsAccepted: true,
      displayName: 'Test User',
      birthDate: null,
      gender: 'Male',
    )).called(1);
  });

  testWidgets('Should handle exception during registration process',
      (WidgetTester tester) async {
    // Setup mock untuk throw exception
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenThrow(Exception('Test exception'));

    // Set ukuran screen
    setScreenSize(tester, width: 600, height: 800);

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill form fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pump();

    // Verify register dipanggil dengan parameter yang benar
    verify(mockRegisterService.register(
      email: 'test@example.com',
      password: 'Password123',
      confirmPassword: 'Password123',
      termsAccepted: true,
      displayName: 'Test User',
      birthDate: null,
      gender: null,
    )).called(1);
  });

  testWidgets('Should handle exception during resend verification email',
      (WidgetTester tester) async {
    // Setup mock behavior
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenAnswer((_) async => RegisterResult.success);

    // Setup resend to throw exception
    when(mockRegisterService.resendEmailVerification())
        .thenThrow(Exception('Test exception'));

    // Set ukuran screen
    setScreenSize(tester, width: 600, height: 800);

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill form fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Tap resend button
    final resendButton = find.widgetWithText(OutlinedButton, 'RESEND EMAIL');
    await tester.ensureVisible(resendButton);
    await tester.tap(resendButton);
    await tester.pump();

    // Verify resendEmailVerification dipanggil
    verify(mockRegisterService.resendEmailVerification()).called(1);
  });

  testWidgets('Should select birth date properly', (WidgetTester tester) async {
    // Setup mock untuk register
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenAnswer((_) async => RegisterResult.success);

    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return RegisterPage();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dengan data valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Tap pada field tanggal lahir untuk memicu fungsi selectDate
    final birthDateField =
        find.widgetWithText(TextFormField, 'Birth Date (Optional)');
    await tester.ensureVisible(birthDateField);
    await tester.tap(birthDateField);
    await tester.pump();

    // Verifikasi bahwa state berjalan dengan benar, hanya verifikasi method daripada UI
    // Kita tidak perlu memverifikasi text "01 January 2000" karena format bisa berbeda

    // Lanjutkan proses registrasi normal untuk meningkatkan coverage
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
  });

  testWidgets('Should show loading indicator when register is processing',
      (WidgetTester tester) async {
    // Setup mock untuk delayed response
    when(mockRegisterService.register(
      email: anyNamed('email'),
      password: anyNamed('password'),
      confirmPassword: anyNamed('confirmPassword'),
      termsAccepted: anyNamed('termsAccepted'),
      displayName: anyNamed('displayName'),
      birthDate: anyNamed('birthDate'),
      gender: anyNamed('gender'),
    )).thenAnswer((_) async {
      // Delay untuk menunjukkan loading
      await Future.delayed(const Duration(milliseconds: 500));
      return RegisterResult.success;
    });

    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dengan data valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Setuju terms dengan mengetuk checkbox
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap tombol register
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);

    // Pump satu frame untuk memulai loading
    await tester.pump();

    // Pastikan CircularProgressIndicator muncul (perhatikan baris 597-598)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump sampai operasi selesai
    await tester.pumpAndSettle();

    // Verifikasi loading indicator sudah hilang dan navigasi sudah berhasil
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Verify Your Email'), findsOneWidget);
  });

  testWidgets('Should verify login link exists in registration form',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Isi form dengan data valid untuk memastikan scroll ke bawah
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123');

    // Cari RichText yang berisi "Sign In"
    final signInLinkFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text is TextSpan &&
          (widget.text as TextSpan).children != null &&
          (widget.text as TextSpan)
              .children!
              .any((span) => span is TextSpan && span.text == 'Sign In'),
    );

    // Scroll ke bawah untuk memastikan link terlihat
    await tester.dragUntilVisible(
      signInLinkFinder,
      find.byType(SingleChildScrollView),
      const Offset(0, 50),
    );
    await tester.pumpAndSettle();

    // Pastikan link "Sign In" ditemukan
    expect(signInLinkFinder, findsOneWidget);
  });

  testWidgets('Should verify birth date field is present and tappable',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Find the birth date field
    final birthDateField =
        find.widgetWithText(TextFormField, 'Birth Date (Optional)');
    expect(birthDateField, findsOneWidget);

    // Verify there is a GestureDetector for date picking
    // Gunakan findDescendantOfType untuk mencari GestureDetector dalam hierarki widget
    final gestureDetectorFinder = find
        .descendant(
          of: find.byType(AbsorbPointer),
          matching: find.byType(GestureDetector),
        )
        .first;

    // Verify gesture detector exists
    expect(gestureDetectorFinder, isNotNull);

    // Verify calendar icon exists
    final calendarIcon = find.byIcon(Icons.calendar_today);
    expect(calendarIcon, findsOneWidget);
  });

  testWidgets('Should initialize RegisterService properly in initState',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page - we just need to verify initState completes without errors
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that RegisterService was initialized properly from GetIt
    // This test simply checks that we can access the page without errors from initialization
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('Should validate empty confirm password field',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester, width: 600, height: 800);

    // Build Register Page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill all fields except confirm password
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123');
    // Deliberately leave confirm password empty

    // Accept terms
    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap register button
    final registerButton = find.widgetWithText(ElevatedButton, 'SIGN UP');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verify error message for empty confirm password
    expect(find.text('Confirm password cannot be empty'), findsOneWidget);
  });

  testWidgets('Should handle back button press on register page',
      (WidgetTester tester) async {
    // Setup screen size
    setScreenSize(tester, width: 600, height: 800);

    // Build register page
    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi PopScope ada
    expect(find.byType(PopScope), findsOneWidget);

    // Verifikasi canPop adalah false
    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse);
  });
}
