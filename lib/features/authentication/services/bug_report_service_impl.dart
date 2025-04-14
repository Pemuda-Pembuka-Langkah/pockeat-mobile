import 'package:flutter/foundation.dart';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/bug_report_service.dart';
import 'package:pockeat/features/authentication/services/utils/instabug_client.dart';

/// Implementasi [BugReportService] menggunakan Instabug SDK
/// 
/// Catatan: Inisialisasi Instabug dilakukan langsung di main.dart
class BugReportServiceImpl implements BugReportService {
  /// Client for Instabug operations
  final InstabugClient _instabugClient;
  
  /// Konstruktor default
  BugReportServiceImpl({InstabugClient? instabugClient}) 
      : _instabugClient = instabugClient ?? InstabugClient();
  
  // Metode initialize dipindahkan ke main.dart
  
  // reportError method removed - use InstabugLog.logError(), logInfo(), etc. directly
  
  @override
  Future<bool> setUserData(UserModel user) async {
    try {
      await _instabugClient.identifyUser(
        user.email, // email (first parameter)
        user.displayName ?? 'User-${user.uid.substring(0, 5)}', // name (second parameter)
        user.uid, // id (third parameter)
      );
      
      return true;
    } catch (e) {
      // Log error ke console
      final errorMsg = 'ERROR: Gagal mengatur data pengguna Instabug: $e';
      debugPrint(errorMsg);
      return false;
    }
  }
  
  
  @override
  Future<bool> clearUserData() async {
    try {
      await _instabugClient.logOut();
      return true;
    } catch (e) {
      // Log error ke console
      final errorMsg = 'ERROR: Gagal menghapus data pengguna Instabug: $e';
      debugPrint(errorMsg);
      return false;
    }
  }
  
  @override
  Future<bool> show() async {
    try {
      await _instabugClient.showReportingUI();
      return true;
    } catch (e) {
      // Log error ke console
      final errorMsg = 'ERROR: Gagal menampilkan UI pelaporan bug Instabug: $e';
      debugPrint(errorMsg);
      return false;
    }
  }
}
