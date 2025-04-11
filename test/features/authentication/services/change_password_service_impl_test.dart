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

  group('ChangePasswordServiceImpl - confirmPasswordReset', () {
    test('confirmPasswordReset should call Firebase confirmPasswordReset',
        () async {
      // Arrange
      const code = 'valid-oob-code';
      const newPassword = 'newPassword123';

      // Mock Firebase auth to return success
      when(mockFirebaseAuth.confirmPasswordReset(
              code: code, newPassword: newPassword))
          .thenAnswer((_) async => {});

      // Act
      await changePasswordService.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );

      // Assert
      verify(mockFirebaseAuth.confirmPasswordReset(
              code: code, newPassword: newPassword))
          .called(1);
    });

    test('confirmPasswordReset should throw for weak-password error', () async {
      // Arrange
      const code = 'valid-oob-code';
      const newPassword = 'weak';

      // Mock Firebase auth to throw weak-password exception
      when(mockFirebaseAuth.confirmPasswordReset(
              code: code, newPassword: newPassword))
          .thenThrow(
        FirebaseAuthException(
          code: 'weak-password',
          message: 'Original Firebase error message',
        ),
      );

      // Act & Assert
      expect(
        () => changePasswordService.confirmPasswordReset(
          code: code,
          newPassword: newPassword,
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

    test('confirmPasswordReset should throw for expired-action-code error',
        () async {
      // Arrange
      const code = 'expired-code';
      const newPassword = 'newPassword123';

      // Mock Firebase auth to throw expired-action-code exception
      when(mockFirebaseAuth.confirmPasswordReset(
              code: code, newPassword: newPassword))
          .thenThrow(
        FirebaseAuthException(
          code: 'expired-action-code',
          message: 'Original Firebase error message',
        ),
      );

      // Act & Assert
      expect(
        () => changePasswordService.confirmPasswordReset(
          code: code,
          newPassword: newPassword,
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'expired-action-code')
              .having(
                (e) => e.message,
                'message',
                'Kode reset password sudah kadaluarsa. Silakan minta kode baru.',
              ),
        ),
      );
    });

    test('confirmPasswordReset should throw for invalid-action-code error',
        () async {
      // Arrange
      const code = 'invalid-code';
      const newPassword = 'newPassword123';

      // Mock Firebase auth to throw invalid-action-code exception
      when(mockFirebaseAuth.confirmPasswordReset(
              code: code, newPassword: newPassword))
          .thenThrow(
        FirebaseAuthException(
          code: 'invalid-action-code',
          message: 'Original Firebase error message',
        ),
      );

      // Act & Assert
      expect(
        () => changePasswordService.confirmPasswordReset(
          code: code,
          newPassword: newPassword,
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'invalid-action-code')
              .having(
                (e) => e.message,
                'message',
                'Kode reset password tidak valid. Silakan periksa email Anda dan coba lagi.',
              ),
        ),
      );
    });

    test('confirmPasswordReset should throw for user-disabled error', () async {
      // Arrange
      const code = 'valid-code';
      const newPassword = 'newPassword123';

      // Mock Firebase auth to throw user-disabled exception
      when(mockFirebaseAuth.confirmPasswordReset(
              code: code, newPassword: newPassword))
          .thenThrow(
        FirebaseAuthException(
          code: 'user-disabled',
          message: 'Original Firebase error message',
        ),
      );

      // Act & Assert
      expect(
        () => changePasswordService.confirmPasswordReset(
          code: code,
          newPassword: newPassword,
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'user-disabled')
              .having(
                (e) => e.message,
                'message',
                'Akun pengguna dinonaktifkan. Silakan hubungi dukungan.',
              ),
        ),
      );
    });

    test('confirmPasswordReset should handle unknown errors', () async {
      // Arrange
      const code = 'valid-code';
      const newPassword = 'newPassword123';

      // Mock Firebase auth to throw unknown exception
      when(mockFirebaseAuth.confirmPasswordReset(
              code: code, newPassword: newPassword))
          .thenThrow(Exception('Unknown error'));

      // Act & Assert
      expect(
        () => changePasswordService.confirmPasswordReset(
          code: code,
          newPassword: newPassword,
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

  group('ChangePasswordServiceImpl - sendPasswordResetEmail', () {
    test('sendPasswordResetEmail should call Firebase sendPasswordResetEmail',
        () async {
      // Arrange
      const email = 'test@example.com';

      // Mock Firebase auth to return success
      when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
          .thenAnswer((_) async => {});

      // Act
      await changePasswordService.sendPasswordResetEmail(email: email);

      // Assert
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
    });

    test('sendPasswordResetEmail should rethrow FirebaseAuthException',
        () async {
      // Arrange
      const email = 'invalid@example.com';

      // Mock Firebase auth to throw FirebaseAuthException
      when(mockFirebaseAuth.sendPasswordResetEmail(email: email)).thenThrow(
        FirebaseAuthException(
          code: 'user-not-found',
          message: 'There is no user record corresponding to this email.',
        ),
      );

      // Act & Assert
      expect(
        () => changePasswordService.sendPasswordResetEmail(email: email),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'user-not-found')
              .having(
                (e) => e.message,
                'message',
                'There is no user record corresponding to this email.',
              ),
        ),
      );
    });

    test('sendPasswordResetEmail should handle generic exceptions', () async {
      // Arrange
      const email = 'test@example.com';

      // Mock Firebase auth to throw generic exception
      when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => changePasswordService.sendPasswordResetEmail(email: email),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'unknown-error')
              .having(
                (e) => e.message,
                'message',
                'Terjadi kesalahan tidak terduga saat mengirim email reset password. Silakan coba lagi nanti.',
              ),
        ),
      );
    });
  });

  group('ChangePasswordServiceImpl', () {
    test(
        'sendPasswordResetEmail should call sendPasswordResetEmail when credentials are valid',
        () async {
      // Arrange
      final email = 'test@example.com';

      // Act
      await changePasswordService.sendPasswordResetEmail(email: email);

      // Assert
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
    });
    test(
        'sendPasswordResetEmail should throw exception when credentials are invalid',
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
                'Untuk alasan keamanan, silakan masukkan password saat ini Anda.',
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

  group('ChangePasswordServiceImpl - changePassword', () {
    test('changePassword should throw when passwords do not match', () async {
      // Arrange
      const newPassword = 'newPassword123';
      const confirmPassword = 'differentPassword123';

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: confirmPassword,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Konfirmasi password baru tidak sesuai dengan password baru.',
          ),
        ),
      );
    });

    test('changePassword should throw when no user is logged in', () async {
      // Arrange
      const newPassword = 'newPassword123';
      const confirmPassword = 'newPassword123';

      // Mock currentUser to return null (no user logged in)
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: confirmPassword,
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

    test('changePassword should handle generic exceptions', () async {
      // Arrange
      const newPassword = 'newPassword123';
      const confirmPassword = 'newPassword123';

      // Mock currentUser to return a user
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Mock updatePassword to throw generic exception
      when(mockUser.updatePassword(newPassword))
          .thenThrow(Exception('Unknown error'));

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: confirmPassword,
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

    test('changePassword should throw for weak-password error', () async {
      // Arrange
      const newPassword = 'weak';
      const newPasswordConfirmation = 'weak';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.updatePassword(newPassword))
          .thenThrow(FirebaseAuthException(
        code: 'weak-password',
        message: 'Password should be at least 6 characters',
      ));

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

    test('changePassword should throw for user-not-found error', () async {
      // Arrange
      const newPassword = 'newPassword123';
      const newPasswordConfirmation = 'newPassword123';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.updatePassword(newPassword))
          .thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found',
      ));

      // Act & Assert
      expect(
        () => changePasswordService.changePassword(
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        ),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'user-not-found')
              .having(
                (e) => e.message,
                'message',
                'User tidak ditemukan. Silakan login kembali.',
              ),
        ),
      );
    });

    test('changePassword should throw for network-request-failed error',
        () async {
      // Arrange
      const newPassword = 'newPassword123';
      const newPasswordConfirmation = 'newPassword123';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.updatePassword(newPassword))
          .thenThrow(FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Network error',
      ));

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
      const newPassword = 'newPassword123';
      const newPasswordConfirmation = 'newPassword123';

      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
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
