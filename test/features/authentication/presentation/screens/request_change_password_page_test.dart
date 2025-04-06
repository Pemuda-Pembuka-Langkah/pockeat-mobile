import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/presentation/screens/reset_password_request_page.dart';
import 'package:pockeat/features/authentication/services/change_password_service.dart';

// Generate mock classes
@GenerateMocks([ChangePasswordService])
import 'request_change_password_page_test.mocks.dart';

void main() {
  late MockChangePasswordService mockChangePasswordService;
  final getIt = GetIt.instance;

  setUp(() {
    mockChangePasswordService = MockChangePasswordService();

    // Reset GetIt to prevent conflicts between tests
    if (getIt.isRegistered<ChangePasswordService>()) {
      getIt.unregister<ChangePasswordService>();
    }
    
    // Register the mock service with GetIt
    getIt.registerSingleton<ChangePasswordService>(mockChangePasswordService);
  });

  tearDown(() {
    // Clean up after each test
    if (getIt.isRegistered<ChangePasswordService>()) {
      getIt.unregister<ChangePasswordService>();
    }
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ForgotPasswordPage(),
    );
  }

  group('ForgotPasswordPage UI', () {
    testWidgets('should display all required UI elements', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Enter your email to receive a password reset link'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('SEND RESET LINK'), findsOneWidget);
    });

    testWidgets('should show back button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

     testWidgets('should navigate back when back button is pressed', (WidgetTester tester) async {
      // Arrange
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage())
                    );
                  },
                  child: const Text('Go to Forgot Password'),
                ),
                const Text('Previous Page'),
              ],
            ),
          ),
        ),
      ));
      
      // Navigate to the forgot password page
      await tester.tap(find.text('Go to Forgot Password'));
      await tester.pumpAndSettle();
      
      // Verify we're on the forgot password page
      expect(find.text('Reset Password'), findsOneWidget);
      
      // Act - press the back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Assert - we should be back on the previous page
      expect(find.text('Previous Page'), findsOneWidget);
      expect(find.text('Reset Password'), findsNothing);
    });
  });

  group('Form validation', () {
    testWidgets('should show error for empty email', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - tap the SEND RESET LINK button without entering text
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pump();

      // Assert
      expect(find.text('Email cannot be empty'), findsOneWidget);
    });

    testWidgets('should show error for invalid email format', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - enter invalid email and submit
      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pump();

      // Assert
      expect(find.text('Invalid email format'), findsOneWidget);
    });
  });

  group('Reset email flow', () {
    testWidgets('should show loading indicator when sending email', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Use a Completer to have manual control over when the Future completes
      final completer = Completer<void>();
      when(mockChangePasswordService.sendPasswordResetEmail(email: 'test@example.com'))
          .thenAnswer((_) => completer.future);

      // Act - enter email and tap button
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pump(); // Process initial state change

      // Assert - should find CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SEND RESET LINK'), findsNothing); // Button text should be replaced by indicator
      
      // Complete the future so test can finish properly
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('should show success UI when email is sent', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      when(mockChangePasswordService.sendPasswordResetEmail(email: 'test@example.com'))
          .thenAnswer((_) async => {});

      // Act
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Check Your Email'), findsOneWidget);
      expect(find.text('We have sent a password reset link to test@example.com. Please check your inbox or spam folder and follow the instructions.'), findsOneWidget);
      expect(find.text('TRY DIFFERENT EMAIL'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
    });

    testWidgets('should go back to form when trying different email', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      when(mockChangePasswordService.sendPasswordResetEmail(email: 'test@example.com'))
          .thenAnswer((_) async => {});

      // Act - first get to success UI
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pumpAndSettle();
      
      // Then tap TRY DIFFERENT EMAIL
      await tester.tap(find.text('TRY DIFFERENT EMAIL'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('SEND RESET LINK'), findsOneWidget);
    });
  });

  group('Error handling', () {
    testWidgets('should display user-not-found error', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      when(mockChangePasswordService.sendPasswordResetEmail(email: 'test@example.com'))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Act
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No user found with this email.'), findsOneWidget);
    });

    testWidgets('should display invalid-email error', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      when(mockChangePasswordService.sendPasswordResetEmail(email: 'test@example.com'))
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      // Act
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid email format.'), findsOneWidget);
    });

    testWidgets('should display custom message for other Firebase exceptions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      when(mockChangePasswordService.sendPasswordResetEmail(email: 'test@example.com'))
          .thenThrow(FirebaseAuthException(
            code: 'unknown',
            message: 'Some custom error message',
          ));

      // Act
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Some custom error message'), findsOneWidget);
    });

    testWidgets('should display generic error for non-Firebase exceptions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      when(mockChangePasswordService.sendPasswordResetEmail(email: 'test@example.com'))
          .thenThrow(Exception('Some error'));

      // Act
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('SEND RESET LINK'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('An error occurred. Please try again.'), findsOneWidget);
    });
  });
}