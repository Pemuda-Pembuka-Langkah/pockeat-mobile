// This file needs to be updated by build_runner

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/simple_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_client.dart';
import 'simple_food_tracking_widget_service_test.mocks.dart';

@GenerateMocks([
  HomeWidgetInterface
])

// Note: Run flutter pub run build_runner build --delete-conflicting-outputs
// to generate the mock classes


void main() {
  late MockHomeWidgetInterface mockHomeWidget;
  late SimpleFoodTrackingWidgetService service;
  
  const testWidgetName = 'test_widget';
  const testAppGroupId = 'test.app.group';
  
  setUp(() {
    // Initialize Flutter binding for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Create our mock
    mockHomeWidget = MockHomeWidgetInterface();
    
    // Create the service with our mock
    service = SimpleFoodTrackingWidgetService(
      widgetName: testWidgetName,
      appGroupId: testAppGroupId,
      homeWidget: mockHomeWidget,
    );
  });
  
  group('SimpleFoodTrackingWidgetService', () {
    group('initialize', () {
      test('should set app group ID', () async {
        // Arrange
        when(mockHomeWidget.setAppGroupId(any)).thenAnswer((_) async {});
        
        // Act
        await service.initialize();
        
        // Assert
        verify(mockHomeWidget.setAppGroupId(testAppGroupId)).called(1);
      });
      
      test('should handle failure to set app group ID', () async {
        // Arrange
        when(mockHomeWidget.setAppGroupId(any)).thenThrow(Exception('Failed to set app group ID'));
        
        // Act & Assert
        expect(
          () => service.initialize(),
          throwsException,
        );
      });
    });
    
    group('getData', () {
      test('should retrieve and convert widget data correctly', () async {
        // Arrange
        // Handle the userId parameter first
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        // Then mock the actual data retrieval
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => 2000);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => 1500);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result, isA<SimpleFoodTracking>());
        expect(result.caloriesNeeded, 2000);
        expect(result.currentCaloriesConsumed, 1500);
      });
      
      test('should handle missing widget data with defaults', () async {
        // Arrange
        // Handle the userId parameter first
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        // Then mock all other data as null
        when(mockHomeWidget.getWidgetData<int?>(any))
            .thenAnswer((_) async => null);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result, isA<SimpleFoodTracking>());
        expect(result.caloriesNeeded, 0);
        expect(result.currentCaloriesConsumed, 0);
      });
      
      test('should handle partial widget data', () async {
        // Arrange
        // Handle the userId parameter first
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        // Then mock partial data
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => 2000);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => null);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result.caloriesNeeded, 2000);
        expect(result.currentCaloriesConsumed, 0); // Default value
      });
    });
    
    group('updateData', () {
      test('should save data to widget storage and update widget', () async {
        // Arrange
        final testData = SimpleFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
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
        
        verify(mockHomeWidget.updateWidget(name: testWidgetName)).called(1);
      });
      
      test('should handle empty data', () async {
        // Arrange
        final testData = SimpleFoodTracking.empty();
        
        when(mockHomeWidget.saveWidgetData(any, any)).thenAnswer((_) async => true);
        when(mockHomeWidget.updateWidget(name: anyNamed('name'))).thenAnswer((_) async => true);
        
        // Act
        await service.updateData(testData);
        
        // Assert
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.caloriesNeeded.toStorageKey(), 0)).called(1);
        verify(mockHomeWidget.saveWidgetData(
          FoodTrackingKey.currentCaloriesConsumed.toStorageKey(), 0)).called(1);
        
        verify(mockHomeWidget.updateWidget(name: testWidgetName)).called(1);
      });
      
      test('should continue even if saving one field fails', () async {
        // Arrange
        final testData = SimpleFoodTracking(
          caloriesNeeded: 2000,
          currentCaloriesConsumed: 1500,
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
        
        verify(mockHomeWidget.updateWidget(name: testWidgetName)).called(1);
      });
    });
    
    group('updateWidget', () {
      test('should call updateWidget with correct widget name', () async {
        // Arrange
        when(mockHomeWidget.updateWidget(name: anyNamed('name'))).thenAnswer((_) async => true);
        
        // Act
        await service.updateWidget();
        
        // Assert
        verify(mockHomeWidget.updateWidget(name: testWidgetName)).called(1);
      });
      
      test('should handle failure to update widget', () async {
        // Arrange
        when(mockHomeWidget.updateWidget(name: anyNamed('name'))).thenAnswer((_) async => false);
        
        // Act
        await service.updateWidget();
        
        // Assert
        verify(mockHomeWidget.updateWidget(name: testWidgetName)).called(1);
        // Service should not throw any exception
      });
    });
    
    group('handle widget values', () {
      test('should handle negative numeric values in widget storage', () async {
        // Arrange
        // Handle the userId parameter first
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => 'test-user-id');
        // Then mock with negative values
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => -2000);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => -1500);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result.caloriesNeeded, -2000);
        expect(result.currentCaloriesConsumed, -1500);
      });
      
      test('should handle explicit null values from platform channel', () async {
        // Arrange
        // Return null for all values including userId
        when(mockHomeWidget.getWidgetData<String?>(FoodTrackingKey.userId.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => null);
        when(mockHomeWidget.getWidgetData<int?>(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => null);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result, isA<SimpleFoodTracking>());
        expect(result.caloriesNeeded, 0);
        expect(result.currentCaloriesConsumed, 0);
        expect(result.userId, isNull);
      });
    });
  });
}
