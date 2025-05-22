// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/user_model.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/detailed_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/food_tracking_client_controller_impl.dart';
import 'package:pockeat/features/home_screen_widget/controllers/impl/simple_food_tracking_controller.dart';
import 'package:pockeat/features/home_screen_widget/domain/exceptions/widget_exceptions.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/widget_background_service_helper.dart';
import 'food_tracking_client_controller_test.mocks.dart';

// Mock classes for dependencies
@GenerateMocks([
  LoginService,
  CaloricRequirementRepository,
  SimpleFoodTrackingController,
  DetailedFoodTrackingController,
  WidgetBackgroundServiceHelperInterface,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FoodTrackingClientControllerImpl controller;
  late MockLoginService mockLoginService;
  late MockCaloricRequirementRepository mockCaloricRequirementRepository;
  late MockSimpleFoodTrackingController mockSimpleController;
  late MockDetailedFoodTrackingController mockDetailedController;
  late MockWidgetBackgroundServiceHelperInterface mockBackgroundServiceHelper;

  // Constants for testing
  final String testUserId = 'test-user-123';
  late UserModel testUser;
  late UserModel testUser2;

  // Helper untuk membuat CaloricRequirementModel untuk testing
  CaloricRequirementModel createTestCaloricRequirement(int tdee) {
    return CaloricRequirementModel(
      userId: testUserId,
      bmr: (tdee * 0.7).toDouble(), // Contoh nilai bmr
      tdee: tdee.toDouble(),
      proteinGrams: 150.0,
      carbsGrams: 200.0,
      fatGrams: 66.7,
      timestamp: DateTime.now(),
    );
  }

  setUp(() {
    // Inisialisasi test users
    testUser = UserModel(
      uid: testUserId,
      displayName: 'Test User',
      email: 'test@example.com',
      photoURL: 'https://example.com/photo.jpg',
      emailVerified: true,
      createdAt: DateTime(2025, 4, 1),
    );
    
    testUser2 = UserModel(
      uid: 'different-user-456',
      displayName: 'New User',
      email: 'new@example.com',
      emailVerified: true,
      createdAt: DateTime(2025, 4, 2),
    );
    
    // Inisialisasi mocks
    mockLoginService = MockLoginService();
    mockCaloricRequirementRepository = MockCaloricRequirementRepository();
    mockSimpleController = MockSimpleFoodTrackingController();
    mockDetailedController = MockDetailedFoodTrackingController();
    mockBackgroundServiceHelper = MockWidgetBackgroundServiceHelperInterface();

    // Setup controller with mocks
    controller = FoodTrackingClientControllerImpl(
      loginService: mockLoginService,
      caloricRequirementRepository: mockCaloricRequirementRepository,
      simpleController: mockSimpleController,
      detailedController: mockDetailedController,
      backgroundServiceHelper: mockBackgroundServiceHelper,
    );

    // Setup default mock behaviors
    when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);
    when(mockLoginService.initialize()).thenAnswer((_) => Stream<UserModel?>.fromIterable([null]));
    when(mockSimpleController.initialize()).thenAnswer((_) async => Future.value());
    when(mockDetailedController.initialize()).thenAnswer((_) async => Future.value());
    when(mockSimpleController.updateWidgetData(any, targetCalories: anyNamed('targetCalories'))).thenAnswer((_) async => Future.value());
    when(mockDetailedController.updateWidgetData(any, targetCalories: anyNamed('targetCalories'))).thenAnswer((_) async => Future.value());
    when(mockSimpleController.cleanupData()).thenAnswer((_) async => Future.value());
    when(mockDetailedController.cleanupData()).thenAnswer((_) async => Future.value());
    when(mockBackgroundServiceHelper.registerTasks()).thenAnswer((_) async => Future.value());
    when(mockBackgroundServiceHelper.cancelAllTasks()).thenAnswer((_) async => Future.value());
  });

  group('FoodTrackingClientController - initialize', () {
    test('should initialize all required components', () async {
      // Arrange
      final streamController = StreamController<UserModel?>();
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenAnswer((_) async => createTestCaloricRequirement(2000));
      when(mockLoginService.initialize()).thenAnswer((_) => streamController.stream);

      // Act
      await controller.initialize();

      // Assert - hanya verifikasi bahwa komponen penting diinisialisasi
      verify(mockSimpleController.initialize()).called(greaterThanOrEqualTo(1));
      verify(mockDetailedController.initialize()).called(greaterThanOrEqualTo(1));
      verify(mockBackgroundServiceHelper.registerTasks()).called(greaterThanOrEqualTo(1));
      
      // Cleanup
      await streamController.close();
    });

    test('should update widgets if user already logged in', () async {
      // Arrange
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenAnswer((_) async => createTestCaloricRequirement(2500));

      // Act
      await controller.initialize();

      // Assert
      verify(mockLoginService.getCurrentUser()).called(1);
      verify(mockCaloricRequirementRepository.getCaloricRequirement(testUserId)).called(1);
      verify(mockSimpleController.updateWidgetData(testUser, targetCalories: 2500)).called(1);
      verify(mockDetailedController.updateWidgetData(testUser, targetCalories: 2500)).called(1);
    });

    test('should throw WidgetInitializationException if simple controller initialization fails', () async {
      // Arrange
      when(mockSimpleController.initialize()).thenThrow(Exception('Failed to initialize'));

      // Act & Assert
      await expectLater(controller.initialize(), throwsA(isA<WidgetInitializationException>()));
    });

    test('should throw WidgetInitializationException if detailed controller initialization fails', () async {
      // Arrange
      when(mockDetailedController.initialize()).thenThrow(Exception('Failed to initialize'));

      // Act & Assert
      await expectLater(controller.initialize(), throwsA(isA<WidgetInitializationException>()));
    });
  });

  group('FoodTrackingClientController - timer and background service setup', () {
    test('should register background tasks when user logs in', () async {
      // Arrange - setup clean controller dan mock untuk test ini
      controller = FoodTrackingClientControllerImpl(
        loginService: mockLoginService,
        caloricRequirementRepository: mockCaloricRequirementRepository,
        simpleController: mockSimpleController,
        detailedController: mockDetailedController,
        backgroundServiceHelper: mockBackgroundServiceHelper,
      );

      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCaloricRequirementRepository.getCaloricRequirement(testUserId))
          .thenAnswer((_) async => createTestCaloricRequirement(2000));
      
      // Act
      await controller.processUserStatusChange(testUser);
      
      // Assert - verifikasi background service diregister
      verify(mockBackgroundServiceHelper.registerTasks()).called(1);
    });
    
    // Kita menguji setup background service di test sebelumnya
    // Untuk periodic timer, kita bisa menguji secara tidak langsung dengan
    // memeriksa bahwa _setupAutoUpdate dipanggil ketika ada user login
    test('should setup timer update when user logs in', () async {
      // Arrange - gunakan spy untuk memantau panggilan ke processPeriodicUpdate
      final originalController = controller;
      var updateCallCount = 0;
      
      // Mock dependency
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCaloricRequirementRepository.getCaloricRequirement(testUserId))
          .thenAnswer((_) async => createTestCaloricRequirement(2000));
      
      // Gunakan callback untuk mendeteksi panggilan processPeriodicUpdate
      when(mockSimpleController.updateWidgetData(any, targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) {
        // Setiap kali updateWidgetData dipanggil, kita tahu controller melakukan update
        updateCallCount++;
        return Future.value();
      });
      
      // Act - trigger user login untuk setup timer
      await controller.processUserStatusChange(testUser);
      
      // Assert - verifikasi bahwa register tasks dipanggil (bagian dari _setupAutoUpdate)
      verify(mockBackgroundServiceHelper.registerTasks()).called(1);
      
      // Verifikasi proses update pertama terjadi
      // ini memvalidasi bahwa setup auto update berhasil
      expect(updateCallCount, greaterThan(0));
    });
  });
  
  group('FoodTrackingClientController - processUserStatusChange', () {
    test('should update widgets with correct target calories for logged in user', () async {
      // Arrange
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenAnswer((_) async => createTestCaloricRequirement(2500));

      // Act
      await controller.processUserStatusChange(testUser);

      // Assert
      verify(mockCaloricRequirementRepository.getCaloricRequirement(testUserId)).called(1);
      verify(mockSimpleController.updateWidgetData(testUser, targetCalories: 2500)).called(1);
      verify(mockDetailedController.updateWidgetData(testUser, targetCalories: 2500)).called(1);
    });

    test('should use default calorie target if no caloric requirement found', () async {
      // Arrange - return null to simulate no caloric requirement
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenAnswer((_) async => null);

      // Act
      await controller.processUserStatusChange(testUser);

      // Assert - should use default 2000 calories
      verify(mockCaloricRequirementRepository.getCaloricRequirement(testUserId)).called(1);
      verify(mockSimpleController.updateWidgetData(testUser, targetCalories: 2000)).called(1);
      verify(mockDetailedController.updateWidgetData(testUser, targetCalories: 2000)).called(1);
    });

    test('should clean up data when user is null (logged out)', () async {
      // Arrange
      when(mockSimpleController.cleanupData()).thenAnswer((_) async => Future.value());
      when(mockDetailedController.cleanupData()).thenAnswer((_) async => Future.value());

      // Act
      await controller.processUserStatusChange(null);

      // Assert
      verifyNever(mockCaloricRequirementRepository.getCaloricRequirement(any));
      verify(mockSimpleController.cleanupData()).called(1);
      verify(mockDetailedController.cleanupData()).called(1);
    });

    test('should throw WidgetUpdateException if getting caloric requirement fails', () async {
      // Arrange
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenThrow(Exception('Failed to get caloric requirement'));

      // Act & Assert
      expect(() => controller.processUserStatusChange(testUser), throwsA(isA<WidgetUpdateException>()));
    });

    test('should throw WidgetUpdateException if updating widgets fails', () async {
      // Arrange
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenAnswer((_) async => createTestCaloricRequirement(2000));
      when(mockSimpleController.updateWidgetData(any, targetCalories: anyNamed('targetCalories')))
          .thenThrow(Exception('Failed to update widget'));

      // Act & Assert
      expect(() => controller.processUserStatusChange(testUser), throwsA(isA<WidgetUpdateException>()));
    });
    
    test('should handle different user IDs correctly', () async {
      // Arrange - different caloric requirements for different users
      when(mockCaloricRequirementRepository.getCaloricRequirement(testUserId))
          .thenAnswer((_) async => createTestCaloricRequirement(2000));
      
      // Different requirement for second user
      when(mockCaloricRequirementRepository.getCaloricRequirement('different-user-456'))
          .thenAnswer((_) async => CaloricRequirementModel(
            userId: 'different-user-456',
            bmr: 1260.0, // 70% of 1800
            tdee: 1800.0,
            timestamp: DateTime.now(),
            proteinGrams: 150.0,
            carbsGrams: 200.0,
            fatGrams: 66.7,
          ));
          
      // Act - first update with original user
      await controller.processUserStatusChange(testUser);
      
      // Verify original user update
      verify(mockCaloricRequirementRepository.getCaloricRequirement(testUserId)).called(1);
      verify(mockSimpleController.updateWidgetData(testUser, targetCalories: 2000)).called(1);
      
      // Reset mocks
      clearInteractions(mockCaloricRequirementRepository);
      clearInteractions(mockSimpleController);
      clearInteractions(mockDetailedController);
      
      // Act - update with new user
      await controller.processUserStatusChange(testUser2);
      
      // Assert - should get caloric requirement for new user ID
      verify(mockCaloricRequirementRepository.getCaloricRequirement('different-user-456')).called(1);
      verify(mockSimpleController.updateWidgetData(testUser2, targetCalories: 1800)).called(1);
      verify(mockDetailedController.updateWidgetData(testUser2, targetCalories: 1800)).called(1);
    });
  });

  group('FoodTrackingClientController - processPeriodicUpdate', () {
    test('should update widgets for logged in user', () async {
      // Arrange - Setup dengan controller baru di setiap test untuk isolasi
      // Pastikan semua mock dikonfigurasi dengan benar
      final testRequirement = createTestCaloricRequirement(2000);
      when(mockCaloricRequirementRepository.getCaloricRequirement(testUserId))
          .thenAnswer((_) async => testRequirement);
     
      // Setup login service untuk mengembalikan user yang sama
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      
      // Setup user pake call yang terdokumentasi di controller
      // Ini akan men-set _currentUser secara internal di controller
      await controller.processUserStatusChange(testUser);
      
   
      
      // Setup ulang mocks setelah reset
      when(mockCaloricRequirementRepository.getCaloricRequirement(testUserId))
          .thenAnswer((_) async => testRequirement);
      
      // Act
      await controller.processPeriodicUpdate();

      // Assert - verifikasi panggilan setelah processPeriodicUpdate
      verify(mockCaloricRequirementRepository.getCaloricRequirement(testUserId)).called(1);
      verify(mockSimpleController.updateWidgetData(testUser, targetCalories: 2000)).called(1);
      verify(mockDetailedController.updateWidgetData(testUser, targetCalories: 2000)).called(1);
    });

    test('should not update widgets if no user is logged in', () async {
      // Arrange - no user logged in, controller._currentUser is null
      
      // Act
      await controller.processPeriodicUpdate();

      // Assert
      verifyNever(mockCaloricRequirementRepository.getCaloricRequirement(any));
      verifyNever(mockSimpleController.updateWidgetData(any, targetCalories: anyNamed('targetCalories')));
      verifyNever(mockDetailedController.updateWidgetData(any, targetCalories: anyNamed('targetCalories')));
    });
  });

  group('FoodTrackingClientController - cleanup and stopPeriodicUpdates', () {
    test('should cleanup all resources properly', () async {
      // Arrange - setup controller baru untuk test case ini
      controller = FoodTrackingClientControllerImpl(
        loginService: mockLoginService,
        caloricRequirementRepository: mockCaloricRequirementRepository,
        simpleController: mockSimpleController,
        detailedController: mockDetailedController,
        backgroundServiceHelper: mockBackgroundServiceHelper,
      );
      
      // Setup user status dengan direct call
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenAnswer((_) async => createTestCaloricRequirement(2000));

      // Panggil method yang mengatur _currentUser
      await controller.processUserStatusChange(testUser);
      
      // Reset semua mock agar hanya panggilan cleanup yang dihitung
      reset(mockSimpleController);
      reset(mockDetailedController);
      reset(mockBackgroundServiceHelper);
      
      // Setup mock lagi setelah reset
      when(mockSimpleController.cleanupData()).thenAnswer((_) async => Future.value());
      when(mockDetailedController.cleanupData()).thenAnswer((_) async => Future.value());
      
      // Act
      await controller.cleanup();
      
      // Assert
      verify(mockSimpleController.cleanupData()).called(1);
      verify(mockDetailedController.cleanupData()).called(1);
      
    });
    
    test('should stop all periodic updates', () async {
      // Act
      await controller.stopPeriodicUpdates();
      
      // Assert
      verify(mockBackgroundServiceHelper.cancelAllTasks()).called(1);
    });
    
    test('should throw WidgetCleanupException if cleanup fails', () async {
      // Arrange
      when(mockSimpleController.cleanupData()).thenThrow(Exception('Cleanup failed'));
      
      // Act & Assert
      expect(() => controller.cleanup(), throwsA(isA<WidgetCleanupException>()));
    });
  });
  
  group('FoodTrackingClientController - forceUpdate', () {
    test('should update widget data when user is already logged in', () async {
      // Arrange - set current user first
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenAnswer((_) async => createTestCaloricRequirement(2500));
      await controller.initialize(); // Initialize with user
      
      // Reset mocks
      clearInteractions(mockLoginService);
      clearInteractions(mockCaloricRequirementRepository);
      clearInteractions(mockSimpleController);
      clearInteractions(mockDetailedController);
      
      // Act
      await controller.forceUpdate();
      
      // Assert - should use cached user
      verifyNever(mockLoginService.getCurrentUser());
      verify(mockCaloricRequirementRepository.getCaloricRequirement(testUserId)).called(1);
      verify(mockSimpleController.updateWidgetData(testUser, targetCalories: 2500)).called(1);
      verify(mockDetailedController.updateWidgetData(testUser, targetCalories: 2500)).called(1);
    });
    
    test('should fetch user from login service when no user is cached', () async {
      // Arrange
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockCaloricRequirementRepository.getCaloricRequirement(any))
          .thenAnswer((_) async => createTestCaloricRequirement(2500));
      
      // Act
      await controller.forceUpdate();
      
      // Assert
      verify(mockLoginService.getCurrentUser()).called(1);
      verify(mockCaloricRequirementRepository.getCaloricRequirement(testUserId)).called(1);
      verify(mockSimpleController.updateWidgetData(testUser, targetCalories: 2500)).called(1);
      verify(mockDetailedController.updateWidgetData(testUser, targetCalories: 2500)).called(1);
    });
    
    test('should handle case when no user is logged in', () async {
      // Arrange
      when(mockLoginService.getCurrentUser()).thenAnswer((_) async => null);
      
      // Act
      await controller.forceUpdate();
      
      // Assert
      verify(mockLoginService.getCurrentUser()).called(1);
      verifyNever(mockCaloricRequirementRepository.getCaloricRequirement(any));
      verify(mockSimpleController.updateWidgetData(null)).called(1);
      verify(mockDetailedController.updateWidgetData(null)).called(1);
    });
  });
  
  group('FoodTrackingClientController - user auth stream', () {
    test('should listen to auth changes and update widgets accordingly', () async {
      // Arrange - Buat controller baru untuk test ini agar tidak ada state yang terbawa
      controller = FoodTrackingClientControllerImpl(
        loginService: mockLoginService,
        caloricRequirementRepository: mockCaloricRequirementRepository,
        simpleController: mockSimpleController,
        detailedController: mockDetailedController,
        backgroundServiceHelper: mockBackgroundServiceHelper,
      );
      
      // Buat stream controller broadcast untuk streaming events
      final authStream = StreamController<UserModel?>.broadcast();
      
      // Setup dependency mocks
      when(mockLoginService.initialize()).thenAnswer((_) => authStream.stream);
      when(mockCaloricRequirementRepository.getCaloricRequirement(testUserId))
          .thenAnswer((_) async => createTestCaloricRequirement(2000));
      when(mockCaloricRequirementRepository.getCaloricRequirement('different-user-456'))
          .thenAnswer((_) async => CaloricRequirementModel(
            userId: 'different-user-456',
            bmr: 1260.0,
            tdee: 1800.0,
            timestamp: DateTime.now(),
            proteinGrams: 150.0,
            carbsGrams: 200.0,
            fatGrams: 66.7,
          ));
      
      // Gunakan completer untuk menunggu processUserStatusChange selesai
      final completer1 = Completer<void>();
      when(mockSimpleController.updateWidgetData(testUser, targetCalories: 2000))
          .thenAnswer((_) async {
        completer1.complete();
        return Future.value();
      });
      
      // Inisialisasi controller - ini akan mulai mendengarkan stream
      await controller.initialize();
      
      // Reset semua mock agar hanya events berikutnya yang kita verifikasi
      reset(mockCaloricRequirementRepository);
      reset(mockSimpleController);
      reset(mockDetailedController);
      
      // Setup lagi mock yang diperlukan setelah reset
      when(mockCaloricRequirementRepository.getCaloricRequirement(testUserId))
          .thenAnswer((_) async => createTestCaloricRequirement(2000));
      when(mockSimpleController.updateWidgetData(any, targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async => Future.value());
      when(mockDetailedController.updateWidgetData(any, targetCalories: anyNamed('targetCalories')))
          .thenAnswer((_) async => Future.value());
      
      // TEST LOGIN EVENT
      // Simulasikan login dengan mengirim user ke stream
      authStream.add(testUser);
      
      // Tunggu sejenak agar controller sempat memproses event stream
      await Future.delayed(const Duration(milliseconds: 100)); 
      
      // Verifikasi bahwa proses user login terjadi
      verify(mockCaloricRequirementRepository.getCaloricRequirement(testUserId)).called(1);
      verify(mockSimpleController.updateWidgetData(testUser, targetCalories: 2000)).called(1);
      verify(mockDetailedController.updateWidgetData(testUser, targetCalories: 2000)).called(1);
      
      // Cleanup
      await authStream.close();
    });
    
    // Test sederhana untuk memverifikasi auth stream
    test('should respond to user logout event', () async {
      // Setup controller baru untuk test ini
      controller = FoodTrackingClientControllerImpl(
        loginService: mockLoginService,
        caloricRequirementRepository: mockCaloricRequirementRepository,
        simpleController: mockSimpleController,
        detailedController: mockDetailedController,
        backgroundServiceHelper: mockBackgroundServiceHelper,
      );
      
      // Setup stream untuk user events
      final logoutStream = StreamController<UserModel?>.broadcast();
      when(mockLoginService.initialize()).thenAnswer((_) => logoutStream.stream);
      
      // Initialize controller (ini akan mulai mendengarkan stream)
      await controller.initialize();
      
      // Reset mocks
      reset(mockSimpleController);
      reset(mockDetailedController);
      
      // Setup mock untuk cleanup data
      when(mockSimpleController.cleanupData()).thenAnswer((_) async => Future.value());
      when(mockDetailedController.cleanupData()).thenAnswer((_) async => Future.value());
      
      // Kirim null ke stream (simulasi logout)
      logoutStream.add(null);
      
      // Tunggu processing event
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Verifikasi bahwa controller memanggil cleanup pada kedua subcontroller
      verify(mockSimpleController.cleanupData()).called(1);
      verify(mockDetailedController.cleanupData()).called(1);
      
      // Cleanup stream
      await logoutStream.close();
    });
  });
}