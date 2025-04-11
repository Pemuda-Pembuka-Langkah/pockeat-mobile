import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/authentication/services/change_password_service.dart';

/// Implementasi [ChangePasswordService] menggunakan Firebase Authentication
class ChangePasswordServiceImpl implements ChangePasswordService {
  final FirebaseAuth _auth;

  /// Constructor
  ChangePasswordServiceImpl({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    } catch (e) {
      // Tangkap exception lain dan lempar sebagai FirebaseAuthException
      const message =
          'Terjadi kesalahan tidak terduga saat mengirim email reset password. Silakan coba lagi nanti.';
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: message,
      );
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      // Ubah pesan error menjadi lebih spesifik dalam bahasa Indonesia
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password baru terlalu lemah. Gunakan minimal 6 karakter.';
          break;
        case 'expired-action-code':
          message =
              'Kode reset password sudah kadaluarsa. Silakan minta kode baru.';
          break;
        case 'invalid-action-code':
          message =
              'Kode reset password tidak valid. Silakan periksa email Anda dan coba lagi.';
          break;
        case 'user-disabled':
          message = 'Akun pengguna dinonaktifkan. Silakan hubungi dukungan.';
          break;
        case 'user-not-found':
          message = 'Tidak ada pengguna yang terkait dengan kode ini.';
          break;
        case 'network-request-failed':
          message = 'Masalah jaringan terjadi. Periksa koneksi internet Anda.';
          break;
        default:
          message = 'Gagal mengubah password: ${e.message ?? e.code}';
      }

      throw FirebaseAuthException(
        code: e.code,
        message: message,
      );
    } catch (e) {
      // Tangkap exception lain dan lempar sebagai FirebaseAuthException
      const message =
          'Terjadi kesalahan tidak terduga saat mengubah password. Silakan coba lagi nanti.';
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: message,
      );
    }
  }

  /// Re-autentikasi pengguna dengan email dan password
  Future<void> reauthenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'No user is currently logged in.',
        );
      }

      // Buat credential untuk re-autentikasi
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Re-autentikasi pengguna
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-mismatch':
          message = 'Email yang dimasukkan tidak cocok dengan akun saat ini.';
          break;
        case 'user-not-found':
          message = 'Tidak ada pengguna yang terkait dengan email ini.';
          break;
        case 'invalid-credential':
          message = 'Kredensial tidak valid.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'wrong-password':
          message = 'Password yang dimasukkan salah.';
          break;
        default:
          message = 'Gagal melakukan autentikasi ulang: ${e.message ?? e.code}';
      }

      throw FirebaseAuthException(
        code: e.code,
        message: message,
      );
    } catch (e) {
      const message =
          'Terjadi kesalahan tidak terduga saat melakukan autentikasi ulang.';
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: message,
      );
    }
  }

  @override
  Future<User> changePassword({
    required String newPassword,
    required String newPasswordConfirmation,
    String? currentPassword,
    String? email,
  }) async {
    try {
      // Validasi password baru dan konfirmasi
      if (newPassword != newPasswordConfirmation) {
        throw ArgumentError(
            'Konfirmasi password baru tidak sesuai dengan password baru.');
      }

      // Mendapatkan user yang sedang login
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'No user is currently logged in.',
        );
      }

      // Untuk mode login, selalu lakukan re-autentikasi terlebih dahulu jika currentPassword tersedia
      if (currentPassword != null && email != null) {
        try {
          // Re-autentikasi user
          await reauthenticateUser(
            email: email,
            password: currentPassword,
          );
        } catch (e) {
          // Lemparkan error dari proses re-autentikasi
          rethrow;
        }
      }

      // Setelah re-autentikasi berhasil atau tidak diperlukan, ubah password
      await user.updatePassword(newPassword);
      return user;
    } on ArgumentError {
      rethrow; // Lempar kembali error validasi
    } on FirebaseAuthException catch (e) {
      // Jika masih mendapat error requires-recent-login, itu berarti user belum re-autentikasi
      // atau re-autentikasi gagal
      if (e.code == 'requires-recent-login' && currentPassword == null) {
        throw FirebaseAuthException(
          code: 'requires-recent-login',
          message:
              'Untuk alasan keamanan, silakan masukkan password saat ini Anda.',
        );
      }

      // Ubah pesan error menjadi lebih spesifik dalam bahasa Indonesia
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password baru terlalu lemah. Gunakan minimal 6 karakter.';
          break;
        case 'requires-recent-login':
          message =
              'Untuk alasan keamanan, silakan login ulang sebelum mengubah password.';
          break;
        case 'user-not-found':
          message = 'User tidak ditemukan. Silakan login kembali.';
          break;
        case 'network-request-failed':
          message = 'Masalah jaringan terjadi. Periksa koneksi internet Anda.';
          break;
        case 'user-not-logged-in':
          // Pertahankan pesan error asli untuk kasus ini
          message = e.message ?? 'No user is currently logged in.';
          break;
        default:
          message = 'Gagal mengubah password: ${e.message ?? e.code}';
      }

      throw FirebaseAuthException(
        code: e.code,
        message: message,
      );
    } catch (e) {
      // Tangkap exception lain dan lempar sebagai FirebaseAuthException
      const message =
          'Terjadi kesalahan tidak terduga saat mengubah password. Silakan coba lagi nanti.';
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: message,
      );
    }
  }
}
