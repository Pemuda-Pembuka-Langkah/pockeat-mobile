import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/authentication/presentation/screens/account_activated_page.dart';

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

  group('AccountActivatedPage Tests', () {
    testWidgets('Halaman menampilkan semua elemen UI dengan benar',
        (WidgetTester tester) async {
      // Setup
      const testEmail = 'test@example.com';
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: const AccountActivatedPage(email: testEmail),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi elemen UI
      expect(find.text('Akun Berhasil Diaktifkan!'), findsOneWidget);
      expect(
          find.text(
              'Email $testEmail telah berhasil diverifikasi. Sekarang kamu dapat menggunakan semua fitur PockEat.'),
          findsOneWidget);
      expect(find.text('LANJUTKAN KE HOME'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('Menampilkan email yang benar di halaman',
        (WidgetTester tester) async {
      // Setup
      const testEmail = 'user@pockeat.com';
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: const AccountActivatedPage(email: testEmail),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi email ditampilkan dengan benar
      expect(
          find.text(
              'Email $testEmail telah berhasil diverifikasi. Sekarang kamu dapat menggunakan semua fitur PockEat.'),
          findsOneWidget);
    });

    testWidgets('Tombol navigasi ke Home berfungsi dengan benar',
        (WidgetTester tester) async {
      // Setup
      const testEmail = 'test@example.com';
      bool navigatedToHome = false;
      setScreenSize(tester);

      // Build halaman dengan mocking Navigator
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return AccountActivatedPage(
                email: testEmail,
                onHomeTap: () {
                  navigatedToHome = true;
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap tombol "LANJUTKAN KE HOME"
      await tester.tap(find.text('LANJUTKAN KE HOME'));
      await tester.pumpAndSettle();

      // Verifikasi callback dipanggil
      expect(navigatedToHome, true);
    });

    testWidgets('Tombol navigasi ke Masuk berfungsi dengan benar',
        (WidgetTester tester) async {
      // Setup
      const testEmail = 'test@example.com';
      bool navigatedToLogin = false;
      setScreenSize(tester);

      // Build halaman dengan mocking Navigator
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return AccountActivatedPage(
                email: testEmail,
                onLoginTap: () {
                  navigatedToLogin = true;
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap tombol "Masuk ke Akun"
      await tester.tap(find.text('Masuk ke Akun'));
      await tester.pumpAndSettle();

      // Verifikasi callback dipanggil
      expect(navigatedToLogin, true);
    });

    testWidgets('Menampilkan warna yang konsisten dengan desain',
        (WidgetTester tester) async {
      // Setup
      const testEmail = 'test@example.com';
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: const AccountActivatedPage(email: testEmail),
        ),
      );
      await tester.pumpAndSettle();

      // Temukan widget dengan warna yang ingin diperiksa
      final titleFinder = find.text('Akun Berhasil Diaktifkan!');
      final iconFinder = find.byIcon(Icons.check_circle_outline);
      final buttonFinder = find.byType(ElevatedButton);

      // Dapatkan widget Text dan Icon
      final titleWidget = tester.widget<Text>(titleFinder);
      final iconWidget = tester.widget<Icon>(iconFinder);
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);

      // Warna yang diharapkan
      const Color expectedGreenColor = Color(0xFF4ECDC4);

      // Verifikasi warna
      expect((titleWidget.style?.color), equals(expectedGreenColor));
      expect(iconWidget.color, equals(expectedGreenColor));

      // Verifikasi tombol menggunakan expectedGreenColor
      final ButtonStyle? style = buttonWidget.style;

      // Cek warna tombol
      final MaterialStateProperty<Color?>? bgColorProp =
          style?.backgroundColor as MaterialStateProperty<Color?>?;
      expect(bgColorProp?.resolve({}), equals(expectedGreenColor));
    });

    testWidgets('Halaman dapat menampilkan email kosong dengan benar',
        (WidgetTester tester) async {
      // Setup
      const String emptyEmail = '';
      setScreenSize(tester);

      // Build halaman
      await tester.pumpWidget(
        MaterialApp(
          home: const AccountActivatedPage(email: emptyEmail),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi teks masih ditampilkan meskipun email kosong
      expect(
          find.text(
              'Email  telah berhasil diverifikasi. Sekarang kamu dapat menggunakan semua fitur PockEat.'),
          findsOneWidget);
    });
  });
}
