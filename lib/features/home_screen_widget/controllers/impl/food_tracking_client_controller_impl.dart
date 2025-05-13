// lib/features/home_screen_widget/controllers/impl/food_tracking_client_controller_impl.dart

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/detailed_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/simple_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/widget_background_service_helper.dart';

// Project imports:
// coverage:ignore-start

class FoodTrackingClientControllerImpl implements FoodTrackingClientController {
  // Dependencies
  final LoginService _loginService;
  final CaloricRequirementRepository _caloricRequirementRepository;
  final WidgetBackgroundServiceHelperInterface _backgroundServiceHelper;
  final SimpleFoodTrackingController _simpleController;
  final DetailedFoodTrackingController _detailedController;

  // State variables
  UserModel? _currentUser;
  Timer? _updateTimer;

  // No Discord logging

  // Controller tidak perlu mengakses widget client langsung
  // Controller bergantung pada service layer untuk interaksi dengan widget
  final Duration _updateInterval = const Duration(minutes: 5);

  FoodTrackingClientControllerImpl({
    required LoginService loginService,
    required CaloricRequirementRepository caloricRequirementRepository,
    required SimpleFoodTrackingController simpleController,
    required DetailedFoodTrackingController detailedController,
    WidgetBackgroundServiceHelperInterface? backgroundServiceHelper,
  })  : _loginService = loginService,
        _caloricRequirementRepository = caloricRequirementRepository,
        _simpleController = simpleController,
        _detailedController = detailedController,
        _backgroundServiceHelper =
            backgroundServiceHelper ?? WidgetBackgroundServiceHelper();

  /// Inisialisasi controller
  @override
  Future<void> initialize() async {
    try {
      // 1. Initialize sub-controllers
      await _simpleController.initialize();
      await _detailedController.initialize();

      // 2. Get current user and update if already logged in (will also setup auto-updates)
      _currentUser = await _loginService.getCurrentUser();
      if (_currentUser != null) {
        debugPrint(
            'User logged in during initialization: ${_currentUser!.email}');
        await processUserStatusChange(_currentUser);
      } else {
        debugPrint('No user logged in during initialization');
        // No user logged in during initialization
      }

      // 5. Start listening to auth changes
      await startListeningToUserChanges();

      // FoodTrackingClientController initialized successfully
    } catch (e) {
      debugPrint('Failed to initialize client controller: $e');
      throw WidgetInitializationException(
          'Failed to initialize client controller: $e');
    }
  }

  /// Proses perubahan status user (login/logout)
  @override
  Future<void> processUserStatusChange(UserModel? user) async {
    try {
      if (user == null) {
        // User logged out, cleaning up widget data
        // User logout - cleanup
        await cleanup();
        return;
      }

      // User logged in, setting up auto-updates
      _setupAutoUpdate();

      // Dapatkan target kalori dari CaloricRequirementRepository
      final caloricRequirement =
          await _caloricRequirementRepository.getCaloricRequirement(user.uid);

      // Gunakan TDEE dari caloric requirement atau default 2000 jika tidak ada
      int targetCalories = 2000; // Default jika tidak ada data

      if (caloricRequirement != null) {
        // TDEE adalah total daily energy expenditure - kalori harian yang dibutuhkan
        targetCalories = caloricRequirement.tdee.toInt();
        // TDEE found
      } else {
        // No caloric requirement data, using default value 2000
      }

      // Update both widgets dengan target calorie yang sama
      await Future.wait([
        _simpleController.updateWidgetData(user,
            targetCalories: targetCalories),
        _detailedController.updateWidgetData(user,
            targetCalories: targetCalories)
      ]);

      // Widget data updated successfully
    } catch (e) {
      debugPrint('Failed to process user status change: $e');
      throw WidgetUpdateException('Failed to process user status change: $e');
    }
  }

  /// Update periodik untuk semua widget
  @override
  Future<void> processPeriodicUpdate() async {
    try {
      if (_currentUser != null) {
        await processUserStatusChange(_currentUser);
      }
    } catch (e) {
      throw WidgetUpdateException('Failed to process periodic update: $e');
    }
  }

  /// Membersihkan data resources untuk logout tapi TETAP mempertahankan auth listener
  @override
  Future<void> cleanup() async {
    try {
      // Cancel periodic updates
      stopPeriodicUpdates();
      debugPrint('Periodic updates cancelled');

      // PENTING: JANGAN cancel subscription auth listener!
      // Auth listener harus tetap berjalan untuk mendeteksi login berikutnya
      // Jika di-cancel, app tidak akan bisa mendeteksi login setelah logout

      // Cleanup sub-controllers
      await _simpleController.cleanupData();
      await _detailedController.cleanupData();

      // Clear cached user data
      _currentUser = null;
    } catch (e) {
      throw WidgetCleanupException('Failed to cleanup: $e');
    }
  }

  /// Hentikan semua proses periodik
  @override
  Future<void> stopPeriodicUpdates() async {
    // Cancel in-app timer
    _updateTimer?.cancel();
    _updateTimer = null;

    // Cancel background tasks
    await _backgroundServiceHelper.cancelAllTasks();
  }

  /// Mulai mendengarkan perubahan status user (login/logout)
  @override
  Future<void> startListeningToUserChanges() async {
    try {
      debugPrint('Setting up LoginService auth stream listener');

      // Gunakan stream dari LoginService (sudah diperbaiki)
      final authStream = _loginService.initialize();
      authStream.listen((userModel) async {
        // Deteksi perubahan login state
        debugPrint(
            'Auth state changed: ${userModel != null ? 'Logged in' : 'Logged out'}');

        // Update widget berdasarkan userModel
        await processUserStatusChange(userModel);
      });
    } catch (e) {
      debugPrint('Failed to setup Firebase Auth state listener: $e');
      throw WidgetInitializationException(
          'Failed to setup user changes listener: $e');
    }
  }

  /// Paksa update widget secara manual
  ///
  /// Berguna untuk komponen eksternal yang perlu memperbarui widget
  /// setelah perubahan data, misalnya setelah menambahkan food log
  @override
  Future<void> forceUpdate() async {
    try {
      // Jika user aktif, gunakan _currentUser
      if (_currentUser != null) {
        await processUserStatusChange(_currentUser);
        return;
      }

      // Jika tidak ada user aktif, coba ambil user dari login service
      final currentUser = await _loginService.getCurrentUser();
      if (currentUser != null) {
        await processUserStatusChange(currentUser);
        return;
      }

      // Jika masih null, update widget dengan data kosong
      await Future.wait([
        _simpleController.updateWidgetData(null),
        _detailedController.updateWidgetData(null)
      ]);

      // Widget data updated successfully
    } catch (e) {
      throw WidgetUpdateException('Failed to force update: $e');
    }
  }

  /// Setup auto-update untuk update periodik
  ///
  /// Menggunakan kombinasi in-app Timer dan background service
  /// untuk memastikan widget tetap diperbarui
  Future<void> _setupAutoUpdate() async {
    try {
      // 1. Setup in-app timer untuk update ketika app aktif
      _updateTimer?.cancel();
      _updateTimer = Timer.periodic(_updateInterval, (_) {
        processPeriodicUpdate();
      });

      // 2. Setup background service untuk update ketika app tidak aktif
      await _setupBackgroundService();

      // Auto-update setup completed successfully
    } catch (e) {
      debugPrint('Failed to setup auto-update: $e');
      throw WidgetTimerSetupException('Failed to setup auto update timer: $e');
    }
  }

  /// Setup background service untuk widget updates
  Future<void> _setupBackgroundService() async {
    try {
      // Permission sudah ditangani oleh PermissionService, langsung register tasks
      await _backgroundServiceHelper.registerTasks();
    } catch (e) {
      throw WidgetTimerSetupException('Failed to setup background service: $e');
    }
  }
}
// coverage:ignore-end
