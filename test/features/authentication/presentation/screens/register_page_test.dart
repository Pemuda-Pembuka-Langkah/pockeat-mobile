import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/presentation/screens/register_page.dart';
import 'package:pockeat/features/authentication/services/register_service.dart';

// Generate mock menggunakan mockito
@GenerateMocks([RegisterService])
import 'register_page_test.mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {}
}

void main() {
  late MockRegisterService mockRegisterService;

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
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRegisterService = MockRegisterService();
    // Setup GetIt untuk testing
    if (GetIt.I.isRegistered<RegisterService>()) {
      GetIt.I.unregister<RegisterService>();
    }
    GetIt.I.registerSingleton<RegisterService>(mockRegisterService);
  });

  tearDown(() {
    // Reset GetIt setelah setiap test
    GetIt.I.reset();
  });

  testWidgets('Register page should load all form components correctly',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester);

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
    setScreenSize(tester);

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
    setScreenSize(tester);

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
    setScreenSize(tester);

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
      birthDate: null,
      gender: null,
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
    expect(find.text('Continue to Home'), findsOneWidget);
  });

  testWidgets('Password validation should accept special characters',
      (WidgetTester tester) async {
    // Atur ukuran layar
    setScreenSize(tester);

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
      birthDate: null,
      gender: null,
    )).called(1);
  });
}
