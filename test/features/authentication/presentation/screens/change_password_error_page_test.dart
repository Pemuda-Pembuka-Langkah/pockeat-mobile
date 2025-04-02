import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/authentication/presentation/screens/change_password_error_page.dart';

void main() {
  testWidgets('ChangePasswordErrorPage displays correct elements',
      (WidgetTester tester) async {
    // Arrange - Buat custom error message
    const customErrorMessage = 'Password reset link is invalid or has expired.';

    // Act - build widget
    await tester.pumpWidget(
      const MaterialApp(
        home: ChangePasswordErrorPage(
          error: customErrorMessage,
        ),
      ),
    );

    // Assert - Periksa semua elemen yang seharusnya muncul
    expect(find.text('Password Reset Failed'),
        findsOneWidget); // Judul hanya di body, tidak di AppBar
    expect(find.text(customErrorMessage), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
    expect(find.text('Get Help'), findsNothing); // Button ini tidak ada di UI
  });

  testWidgets('Back to Login button navigates to login page',
      (WidgetTester tester) async {
    // Arrange - Setup routes untuk navigation testing
    final routes = <String, WidgetBuilder>{
      '/': (context) => const ChangePasswordErrorPage(error: 'Test Error'),
      '/login': (context) => const Scaffold(body: Text('Login Page')),
    };

    // Act - build widget
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: routes,
      ),
    );

    // Tap the Back to Login button
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle(); // Tunggu navigasi selesai

    // Assert - Verifikasi navigasi ke login page
    expect(find.text('Login Page'), findsOneWidget);
  });

  testWidgets(
      'ChangePasswordErrorPage uses default error message when not provided',
      (WidgetTester tester) async {
    // Act - build widget with null error
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            // Simulate route with null arguments
            final Map<String, dynamic>? args = null;
            return ChangePasswordErrorPage(
              error: args?['error'] as String? ??
                  'Password reset failed. Please try again.',
            );
          },
        ),
      ),
    );

    // Assert - Default error message should be displayed
    expect(
        find.text('Password reset failed. Please try again.'), findsOneWidget);
  });
}
