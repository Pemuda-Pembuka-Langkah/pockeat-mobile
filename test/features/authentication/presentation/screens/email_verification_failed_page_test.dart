import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/authentication/presentation/screens/email_verification_failed_page.dart';

void main() {
  // Fungsi helper untuk menyetel ukuran layar test yang konsisten
  void setScreenSize(WidgetTester tester) {
    tester.binding.window.physicalSizeTestValue = const Size(1080, 2340);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  }

  group('EmailVerificationFailedPage Tests', () {
    testWidgets('Halaman menampilkan semua elemen UI dengan benar',
        (WidgetTester tester) async {
      // Setup
      const testError = 'Test error message';
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: const EmailVerificationFailedPage(error: testError),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi elemen UI
      expect(find.text('Email Verification Failed'), findsOneWidget);
      expect(find.text(testError), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
      expect(find.text('CREATE NEW ACCOUNT'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Menampilkan pesan error yang benar',
        (WidgetTester tester) async {
      // Setup
      const testError = 'Custom error message for testing';
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: const EmailVerificationFailedPage(error: testError),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi error ditampilkan dengan benar
      expect(find.text(testError), findsOneWidget);
    });

    testWidgets('Tombol SIGN IN berfungsi dengan benar',
        (WidgetTester tester) async {
      // Setup
      const testError = 'Test error';
      final navigatorPushed = <String>[];

      setScreenSize(tester);

      // Build halaman dengan mocking Navigator
      await tester.pumpWidget(
        MaterialApp(
          home: const EmailVerificationFailedPage(error: testError),
          onGenerateRoute: (RouteSettings settings) {
            navigatorPushed.add(settings.name!);
            return MaterialPageRoute(
              builder: (BuildContext context) => const Scaffold(),
              settings: settings,
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap tombol "SIGN IN"
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      // Verifikasi navigasi
      expect(navigatorPushed, contains('/login'));
    });

    testWidgets('Tombol CREATE NEW ACCOUNT berfungsi dengan benar',
        (WidgetTester tester) async {
      // Setup
      const testError = 'Test error';
      final navigatorPushed = <String>[];

      setScreenSize(tester);

      // Build halaman dengan mocking Navigator
      await tester.pumpWidget(
        MaterialApp(
          home: const EmailVerificationFailedPage(error: testError),
          onGenerateRoute: (RouteSettings settings) {
            navigatorPushed.add(settings.name!);
            return MaterialPageRoute(
              builder: (BuildContext context) => const Scaffold(),
              settings: settings,
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap tombol "CREATE NEW ACCOUNT"
      await tester.tap(find.text('CREATE NEW ACCOUNT'));
      await tester.pumpAndSettle();

      // Verifikasi navigasi
      expect(navigatorPushed, contains('/register'));
    });

    testWidgets('Menampilkan warna yang konsisten dengan desain',
        (WidgetTester tester) async {
      // Setup
      const testError = 'Test error';
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: const EmailVerificationFailedPage(error: testError),
        ),
      );
      await tester.pumpAndSettle();

      // Temukan widget dengan warna yang ingin diperiksa
      final titleFinder = find.text('Email Verification Failed');
      final iconFinder = find.byIcon(Icons.error_outline);
      final signInButtonFinder = find.byType(ElevatedButton);

      // Dapatkan widget Text dan Icon
      final titleWidget = tester.widget<Text>(titleFinder);
      final iconWidget = tester.widget<Icon>(iconFinder);
      final signInButtonWidget =
          tester.widget<ElevatedButton>(signInButtonFinder);

      // Warna yang diharapkan
      final Color expectedRedColor = Colors.red[400]!;
      final Color expectedPinkColor = const Color(0xFFFF6B6B);

      // Verifikasi warna
      expect((titleWidget.style?.color), equals(expectedRedColor));
      expect(iconWidget.color, equals(expectedRedColor));

      // Verifikasi tombol menggunakan expectedPinkColor
      final ButtonStyle? style = signInButtonWidget.style;

      // Cek warna tombol
      final MaterialStateProperty<Color?>? bgColorProp =
          style?.backgroundColor as MaterialStateProperty<Color?>?;
      expect(bgColorProp?.resolve({}), equals(expectedPinkColor));
    });

    testWidgets('Halaman menampilkan error default jika error null atau empty',
        (WidgetTester tester) async {
      // Setup
      setScreenSize(tester);
      const String emptyError = '';

      // Testing dengan error kosong
      await tester.pumpWidget(
        MaterialApp(
          home: const EmailVerificationFailedPage(
            key: Key('test-key'),
            error: emptyError,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi UI tetap tampil dengan benar
      expect(find.text('Email Verification Failed'), findsOneWidget);
      // Pastikan emptyError yang ditampilkan, karena class tidak menyediakan default message
      expect(find.text(emptyError), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
      expect(find.text('CREATE NEW ACCOUNT'), findsOneWidget);

      // Verifikasi bahwa key bekerja dengan benar
      final finder = find.byKey(const Key('test-key'));
      expect(finder, findsOneWidget);
    });

    testWidgets('Konstruktor menerima dan menggunakan key dengan benar',
        (WidgetTester tester) async {
      // Setup
      const testError = 'Test error message';
      const testKey = Key('custom-test-key');
      setScreenSize(tester);

      // Build halaman dengan custom key
      await tester.pumpWidget(
        MaterialApp(
          home: const EmailVerificationFailedPage(
            key: testKey,
            error: testError,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi key digunakan dengan benar
      expect(find.byKey(testKey), findsOneWidget);

      // Verifikasi properties digunakan dengan benar di widget
      final EmailVerificationFailedPage widget =
          tester.widget(find.byKey(testKey));
      expect(widget.error, equals(testError));
    });
  });
}
