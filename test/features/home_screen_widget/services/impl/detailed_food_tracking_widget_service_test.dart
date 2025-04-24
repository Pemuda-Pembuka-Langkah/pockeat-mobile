// This file needs to be updated by build_runner

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/detailed_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_client.dart';
import 'detailed_food_tracking_widget_service_test.mocks.dart';

@GenerateMocks([
  HomeWidgetInterface
])

// Note: Run flutter pub run build_runner build --delete-conflicting-outputs
// to generate the mock classes


void main() {
  late MockHomeWidgetInterface mockHomeWidget;
  late DetailedFoodTrackingWidgetService service;
  
  const testWidgetName = 'test_widget';
  const testAppGroupId = 'test.app.group';
  
  setUp(() {
    // Initialize Flutter binding for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Create our mock
    mockHomeWidget = MockHomeWidgetInterface();
    
    // Create the service with our mock
    service = DetailedFoodTrackingWidgetService(
      widgetName: testWidgetName,
      appGroupId: testAppGroupId,
      homeWidget: mockHomeWidget,
    );
  });
  
  group('DetailedFoodTrackingWidgetService', () {
    group('initialize', () {
      test('should set app group ID', () async {
        // Arrange
        when(mockHomeWidget.setAppGroupId(any)).thenAnswer((_) async {});
        
        // Act
        await service.initialize();
        
        // Assert
        verify(mockHomeWidget.setAppGroupId(testAppGroupId)).called(1);
      });
    });
    
    group('getData', () {
      test('should retrieve and convert widget data correctly', () async {
        // Arrange
        // Handle userId parameter first
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => 2000);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => 1500);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentProtein.toStorageKey()))
            .thenAnswer((_) async => 75.5);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentCarb.toStorageKey()))
            .thenAnswer((_) async => 200.0);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentFat.toStorageKey()))
            .thenAnswer((_) async => 50.2);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result, isA<DetailedFoodTracking>());
        expect(result.caloriesNeeded, 2000);
        expect(result.currentCaloriesConsumed, 1500);
        expect(result.currentProtein, 75.5);
        expect(result.currentCarb, 200.0);
        expect(result.currentFat, 50.2);
      });
      
      test('should handle missing widget data with defaults', () async {
        // Arrange
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        when(mockHomeWidget.getWidgetData<dynamic>(any)).thenAnswer((_) async => null);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result, isA<DetailedFoodTracking>());
        expect(result.caloriesNeeded, 0);
        expect(result.currentCaloriesConsumed, 0);
        expect(result.currentProtein, 0.0);
        expect(result.currentCarb, 0.0);
        expect(result.currentFat, 0.0);
      });
      
      test('should handle partial widget data', () async {
        // Arrange
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => 2000);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => 1500);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentProtein.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentCarb.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentFat.toStorageKey()))
            .thenAnswer((_) async => null);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result.caloriesNeeded, 2000);
        expect(result.currentCaloriesConsumed, 1500);
        expect(result.currentProtein, 0.0); // Default value
        expect(result.currentCarb, 0.0); // Default value
        expect(result.currentFat, 0.0); // Default value
      });
      
      test('should handle integer values for double fields', () async {
        // Arrange
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        
        // Simple mocking approach: mock the return of ints for the protein, carb, and fat fields
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => 2000);
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => 1500);
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.currentProtein.toStorageKey()))
            .thenAnswer((_) async => 75); // Integer
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.currentCarb.toStorageKey()))
            .thenAnswer((_) async => 200); // Integer
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.currentFat.toStorageKey()))
            .thenAnswer((_) async => 50); // Integer
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result.currentProtein, 75.0);
        expect(result.currentCarb, 200.0);
        expect(result.currentFat, 50.0);
      });
    });
    
    group('updateData', () {
      test('should save data to widget storage and update widget', () async {
        // Arrange
        final testData = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
          currentProtein: 75.5,
          currentCarb: 200.0,
          currentFat: 50.2,
        );
        
        when(mockHomeWidget.saveWidgetData(any, any)).thenAnswer((_) async => true);
        when(mockHomeWidget.updateWidget(name: anyNamed('name'))).thenAnswer((_) async => true);
        
        // Act
        await service.updateData(testData);
        
        // Assert
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.caloriesNeeded.toStorageKey(), 2000)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(), 1500)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentProtein.toStorageKey(), 75.5)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentCarb.toStorageKey(), 200.0)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentFat.toStorageKey(), 50.2)).called(1);
        
        verify(mockHomeWidget.updateWidget(name: testWidgetName)).called(1);
      });
      
      test('should handle empty data', () async {
        // Arrange
        final testData = DetailedFoodTracking.empty();
        
        when(mockHomeWidget.saveWidgetData(any, any)).thenAnswer((_) async => true);
        when(mockHomeWidget.updateWidget(name: anyNamed('name'))).thenAnswer((_) async => true);
        
        // Act
        await service.updateData(testData);
        
        // Assert
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.caloriesNeeded.toStorageKey(), 0)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(), 0)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentProtein.toStorageKey(), 0.0)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentCarb.toStorageKey(), 0.0)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentFat.toStorageKey(), 0.0)).called(1);
        
        verify(mockHomeWidget.updateWidget(name: testWidgetName)).called(1);
      });
      
      test('should continue even if saving one field fails', () async {
        // Arrange
        final testData = DetailedFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
          currentProtein: 75.5,
          currentCarb: 200.0,
          currentFat: 50.2,
        );
        
        // First call fails, others succeed
        when(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.caloriesNeeded.toStorageKey(), any))
          .thenAnswer((_) async => false);
        when(mockHomeWidget.saveWidgetData(any, any))
          .thenAnswer((_) async => true);
        when(mockHomeWidget.updateWidget(name: anyNamed('name')))
          .thenAnswer((_) async => true);
        
        // Act
        await service.updateData(testData);
        
        // Assert
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.caloriesNeeded.toStorageKey(), 2000)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(), 1500)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentProtein.toStorageKey(), 75.5)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentCarb.toStorageKey(), 200.0)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentFat.toStorageKey(), 50.2)).called(1);
        
        verify(mockHomeWidget.updateWidget(name: testWidgetName)).called(1);
      });
    });
    

    
    group('edge cases', () {
      test('should handle negative numeric values in widget storage', () async {
        // Arrange
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => -2000);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => -1500);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentProtein.toStorageKey()))
            .thenAnswer((_) async => -75.5);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentCarb.toStorageKey()))
            .thenAnswer((_) async => -200.0);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentFat.toStorageKey()))
            .thenAnswer((_) async => -50.2);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result.caloriesNeeded, -2000);
        expect(result.currentCaloriesConsumed, -1500);
        expect(result.currentProtein, -75.5);
        expect(result.currentCarb, -200.0);
        expect(result.currentFat, -50.2);
      });

      test('should handle explicit null values from platform channel', () async {
        // Arrange - all values return null
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentProtein.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentCarb.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<double?>(FoodTrackingKey.currentFat.toStorageKey()))
            .thenAnswer((_) async => null);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result, isA<DetailedFoodTracking>());
        expect(result.caloriesNeeded, 0);
        expect(result.currentCaloriesConsumed, 0);
        expect(result.currentProtein, 0.0);
        expect(result.currentCarb, 0.0);
        expect(result.currentFat, 0.0);
        expect(result.userId, isNull);
      });
    });
  });
}
