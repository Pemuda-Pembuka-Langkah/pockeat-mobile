import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/authentication/services/change_password_service_impl.dart';

@GenerateMocks([FirebaseAuth, User],
    customMocks: [MockSpec<UserCredential>(as: #MockUserCred)])
import 'change_password_service_impl_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late ChangePasswordServiceImpl changePasswordService;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    changePasswordService = ChangePasswordServiceImpl(
      auth: mockFirebaseAuth,
    );
  });



  group('ChangePasswordServiceImpl', () {
    test('sendPasswordResetEmail should call sendPasswordResetEmail when credentials are valid',
        () async {
      // Arrange
      final email = 'test@example.com';

      // Act
      await changePasswordService.sendPasswordResetEmail(email: email);

      // Assert
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
    });
    test('sendPasswordResetEmail should throw exception when credentials are invalid',
        () async {
      // Arrange
      const email = 'invalid@example.com';
      final exception = FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      );
      
      // Configure the mock to throw an exception when sendPasswordResetEmail is called
      when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
          .thenThrow(exception);
      
      // Act & Assert
      // Expect that calling sendPasswordResetEmail throws a FirebaseAuthException
      await expectLater(
        () => changePasswordService.sendPasswordResetEmail(email: email),
        throwsA(isA<FirebaseAuthException>()),
      );
    }); 
    test('changePassword should call updatePassword when credentials are valid',
        () async {
      // Arrange
      final newPassword = 'newPassword456';
      final newPasswordConfirmation = 'newPassword456';
      final email = 'test@example.com';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(email);
      when(mockUser.updatePassword(newPassword)).thenAnswer((_) async => {});

      // Act
      final result = await changePasswordService.changePassword(
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      // Assert
      expect(result, equals(mockUser));
      verify(mockUser.updatePassword(newPassword)).called(1);
    });

    test('changePassword should throw error when passwords do not match',
        () async {
      // Arrange
      final newPassword = 'newPassword456';
      final newPasswordConfirmation = 'differentPassword789';

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Konfirmasi password baru tidak sesuai dengan password baru.',
          ),
        ),
      );

      // Verify that no Firebase methods are called
      verifyZeroInteractions(mockFirebaseAuth);
    });

    test('changePassword should throw exception when no user is logged in',
        () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: 'newPassword456',
          newPasswordConfirmation: 'newPassword456',
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'user-not-logged-in')
              .having(
                (e) => e.message,
                'message',
                'No user is currently logged in.',
              ),
        ),
      );
    });

    test('changePassword should throw specific error message for weak-password',
        () async {
      // Arrange
      final newPassword = 'weak';
      final newPasswordConfirmation = 'weak';
      final email = 'test@example.com';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(email);
      when(mockUser.updatePassword(newPassword)).thenThrow(
        FirebaseAuthException(
          code: 'weak-password',
          message: 'Original Firebase error message',
        ),
      );

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'weak-password')
              .having(
                (e) => e.message,
                'message',
                'Password baru terlalu lemah. Gunakan minimal 6 karakter.',
              ),
        ),
      );
    });

    test(
        'changePassword should throw specific error message for requires-recent-login',
        () async {
      // Arrange
      final newPassword = 'newPassword456';
      final newPasswordConfirmation = 'newPassword456';
      final email = 'test@example.com';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(email);
      when(mockUser.updatePassword(newPassword)).thenThrow(
        FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'Original Firebase error message',
        ),
      );

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'requires-recent-login')
              .having(
                (e) => e.message,
                'message',
                'Untuk alasan keamanan, silakan login ulang sebelum mengubah password.',
              ),
        ),
      );
    });

    test(
        'changePassword should throw specific error message for network-request-failed',
        () async {
      // Arrange
      final newPassword = 'newPassword456';
      final newPasswordConfirmation = 'newPassword456';
      final email = 'test@example.com';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(email);
      when(mockUser.updatePassword(newPassword)).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Original Firebase error message',
        ),
      );

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'network-request-failed')
              .having(
                (e) => e.message,
                'message',
                'Masalah jaringan terjadi. Periksa koneksi internet Anda.',
              ),
        ),
      );
    });

    test('changePassword should handle unknown errors', () async {
      // Arrange
      final newPassword = 'newPassword456';
      final newPasswordConfirmation = 'newPassword456';
      final email = 'test@example.com';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(email);
      when(mockUser.updatePassword(newPassword))
          .thenThrow(Exception('Unknown error'));

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'unknown-error')
              .having(
                (e) => e.message,
                'message',
                'Terjadi kesalahan tidak terduga saat mengubah password. Silakan coba lagi nanti.',
              ),
        ),
      );
    });
  });
}
