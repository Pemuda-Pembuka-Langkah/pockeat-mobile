// lib/features/home_screen_widget/controllers/impl/food_tracking_client_controller_impl.dart

import 'dart:async';
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/services/caloric_requirement_service.dart';
import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';
import 'package:pockeat/features/health_metrics/domain/service/health_metrics_check_service.dart';
import 'package:pockeat/features/home_screen_widget/controllers/food_tracking_client_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/detailed_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/simple_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/default_calorie_calculation_strategy.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/permission_helper.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/widget_background_service_helper.dart';
import '../../services/calorie_calculation_strategy.dart';

class FoodTrackingClientControllerImpl implements FoodTrackingClientController {
  // Service & Repository dependencies
  final LoginService _loginService;
  final CaloricRequirementService _caloricRequirementService;
  final HealthMetricsRepository _healthMetricsRepository;
  final PermissionHelperInterface _permissionHelper;
  final WidgetBackgroundServiceHelperInterface _backgroundServiceHelper;

  // Specific controllers
  final SimpleFoodTrackingController _simpleController;
  final DetailedFoodTrackingController _detailedController;

  // State variables
  UserModel? _currentUser;
  Timer? _updateTimer;
  StreamSubscription<UserModel?>? _userSubscription;

  // Controller tidak perlu mengakses widget client langsung
  // Controller bergantung pada service layer untuk interaksi dengan widget

  final CalorieCalculationStrategy _calorieCalculationStrategy;
  final Duration _updateInterval = const Duration(minutes: 5);

  FoodTrackingClientControllerImpl({
    required LoginService loginService,
    required CaloricRequirementService caloricRequirementService,
    required HealthMetricsRepository healthMetricsRepository,
    required HealthMetricsCheckService healthMetricsCheckService,
    required SimpleFoodTrackingController simpleController,
    required DetailedFoodTrackingController detailedController,
    CalorieCalculationStrategy? calorieCalculationStrategy,
    PermissionHelperInterface? permissionHelper,
    WidgetBackgroundServiceHelperInterface? backgroundServiceHelper,
  })  : _loginService = loginService,
        _caloricRequirementService = caloricRequirementService,
        _healthMetricsRepository = healthMetricsRepository,
        _simpleController = simpleController,
        _detailedController = detailedController,
        _permissionHelper = permissionHelper ?? PermissionHelper(),
        _backgroundServiceHelper =
            backgroundServiceHelper ?? WidgetBackgroundServiceHelper(),
        _calorieCalculationStrategy =
            calorieCalculationStrategy ?? DefaultCalorieCalculationStrategy();

  /// Inisialisasi controller
  @override
  Future<void> initialize() async {
    try {
      // 1. Initialize sub-controllers
      await _simpleController.initialize();
      await _detailedController.initialize();
      // 2. Setup auto-updates
      _setupAutoUpdate();

      // 3. Get current user and update if already logged in
      _currentUser = await _loginService.getCurrentUser();
      if (_currentUser != null) {
        await processUserStatusChange(_currentUser);
      }

      // 5. Start listening to auth changes
      await startListeningToUserChanges();
    } catch (e) {
      throw WidgetInitializationException(
          'Failed to initialize client controller: $e');
    }
  }

  /// Proses perubahan status user (login/logout)
  @override
  Future<void> processUserStatusChange(UserModel? user) async {
    try {
      // Update current user reference
      _currentUser = user;

      if (user == null) {
        // User logout - cleanup
        await cleanup();
        return;
      }

      // User login atau update - perbarui widget
      final int targetCalories =
          await _calorieCalculationStrategy.calculateTargetCalories(
              _healthMetricsRepository, _caloricRequirementService, user.uid);

      // Update both widgets dengan target calorie yang sama
      await Future.wait([
        _simpleController.updateWidgetData(user,
            targetCalories: targetCalories),
        _detailedController.updateWidgetData(user,
            targetCalories: targetCalories)
      ]);
    } catch (e) {
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

  /// Membersihkan data dan resources
  @override
  Future<void> cleanup() async {
    try {
      // Cancel periodic updates
      stopPeriodicUpdates();

      // Cancel user subscription
      _userSubscription?.cancel();
      _userSubscription = null;

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
      // Cancel existing subscription jika ada
      await _userSubscription?.cancel();

      // Berlangganan ke stream user changes dari LoginService
      final authStream = _loginService.initialize();
      _userSubscription = authStream.listen((user) async {
        // Jika user berubah, update widget
        if (user?.uid != _currentUser?.uid) {
          await processUserStatusChange(user);
        }
      });
    } catch (e) {
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
    } catch (e) {
      throw WidgetTimerSetupException('Failed to setup auto update timer: $e');
    }
  }

  /// Setup background service untuk widget updates
  Future<void> _setupBackgroundService() async {
    try {
      // Request notification permission (diperlukan untuk beberapa background tasks)
      await _requestPermissions();

      // Initialize workmanager
      await _backgroundServiceHelper.initialize();

      // Register periodic task (minimal 15 menit sesuai batasan Android)
      await _backgroundServiceHelper.registerPeriodicTask();

      // Register midnight task untuk update jam 00:00
      await _backgroundServiceHelper.registerMidnightTask();
    } catch (e) {
      throw WidgetTimerSetupException('Failed to setup background service: $e');
    }
  }

  /// Request permissions yang diperlukan
  Future<void> _requestPermissions() async {
    // Notification permission
    await _permissionHelper.requestNotificationPermission();

    // Battery optimization exemption (untuk background process)
    if (await _permissionHelper.isBatteryOptimizationExemptionGranted() ==
        false) {
      await _permissionHelper.requestBatteryOptimizationExemption();
    }
  }
}
