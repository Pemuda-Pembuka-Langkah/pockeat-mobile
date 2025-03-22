import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/login_service_impl.dart';

@GenerateMocks([FirebaseAuth, UserCredential])
import 'login_service_impl_test.mocks.dart';

void main() {
  group('LoginServiceImpl', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late LoginServiceImpl loginService;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      loginService = LoginServiceImpl(auth: mockFirebaseAuth);
      mockUserCredential = MockUserCredential();
    });

    group('loginByEmail', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('should login successfully with email and password', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await loginService.loginByEmail(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, mockUserCredential);
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).called(1);
      });

      test('should throw FirebaseAuthException when login fails', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for that email.',
        );

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () => loginService.loginByEmail(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(equals(exception)),
        );
      });

      test('should convert general exceptions to FirebaseAuthException',
          () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).thenThrow(Exception('Test error'));

        // Act & Assert
        expect(
          () => loginService.loginByEmail(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(
            isA<FirebaseAuthException>()
                .having((e) => e.code, 'code', 'unknown-error')
                .having((e) => e.message, 'message', contains('Test error')),
          ),
        );
      });
    });
  });
}
