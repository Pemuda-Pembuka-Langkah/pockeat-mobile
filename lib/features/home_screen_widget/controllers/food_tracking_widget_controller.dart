// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';

/// Interface dasar untuk semua controller widget food tracking
///
/// Interface ini mendefinisikan metode yang harus diimplementasikan
/// oleh semua controller widget food tracking, baik simple maupun detailed
abstract class FoodTrackingWidgetController {
  /// Inisialisasi controller
  ///
  /// Metode ini dipanggil saat widget pertama kali diinisialisasi
  /// [navigatorKey] digunakan untuk navigasi ke halaman lain
  Future<void> initialize();

  /// Memperbarui data widget dengan user yang aktif
  ///
  /// [user] adalah user yang sedang aktif, null jika tidak ada user login
  /// [targetCalories] adalah target kalori harian user, jika diketahui
  Future<void> updateWidgetData(UserModel? user, {int? targetCalories});

  /// Membersihkan data saat logout/app reset
  ///
  /// @throws WidgetCleanupException jika gagal membersihkan data
  Future<void> cleanupData();
}
