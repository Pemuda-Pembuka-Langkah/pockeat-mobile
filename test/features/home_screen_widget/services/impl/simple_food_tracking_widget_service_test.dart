// This file needs to be updated by build_runner

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_event_type.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/simple_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/simple_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_client.dart';

@GenerateMocks([
  HomeWidgetInterface
])

// Note: Run flutter pub run build_runner build --delete-conflicting-outputs
// to generate the mock classes

import 'simple_food_tracking_widget_service_test.mocks.dart';

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
      test('should set app group ID and register callback', () async {
        // Arrange
        when(mockHomeWidget.setAppGroupId(any)).thenAnswer((_) async => true);
        when(mockHomeWidget.registerBackgroundCallback(any))
            .thenAnswer((_) async {});
        
        // Act
        await service.initialize();
        
        // Assert
        verify(mockHomeWidget.setAppGroupId(testAppGroupId)).called(1);
        verify(mockHomeWidget.registerBackgroundCallback(any)).called(1);
      });
      
      test('should handle failure to set app group ID', () async {
        // Arrange
        when(mockHomeWidget.setAppGroupId(any)).thenAnswer((_) async => false);
        when(mockHomeWidget.registerBackgroundCallback(any))
            .thenAnswer((_) async {});
        
        // Act
        await service.initialize();
        
        // Assert
        verify(mockHomeWidget.setAppGroupId(testAppGroupId)).called(1);
        verify(mockHomeWidget.registerBackgroundCallback(any)).called(1);
      });
    });
    
    group('getData', () {
      test('should retrieve and convert widget data correctly', () async {
        // Arrange
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => 2000);
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
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
        when(mockHomeWidget.getWidgetData(any)).thenAnswer((_) async => null);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result, isA<SimpleFoodTracking>());
        expect(result.caloriesNeeded, 0);
        expect(result.currentCaloriesConsumed, 0);
      });
      
      test('should handle partial widget data', () async {
        // Arrange
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => 2000);
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
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
    
    group('handleWidgetClicked', () {
      test('should emit correct event type for click type', () async {
        // Arrange
        // URI dengan format yang benar: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        final uri = Uri.parse('pockeat://app_group?widgetName=simple_food&&type=click');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.clicked);
      });
      
      test('should emit correct event type for log type', () async {
        // Arrange
        // URI dengan format yang benar: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        final uri = Uri.parse('pockeat://app_group?widgetName=simple_food&&type=log');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.quicklog);
      });
      
      test('should emit correct event type for refresh parameter', () async {
        // Arrange
        // URI dengan format alternatif yang menggunakan parameter refresh
        final uri = Uri.parse('pockeat://app_group?widgetName=simple_food&&refresh=true');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.refresh);
      });
      
      test('should emit default event type for unknown type', () async {
        // Arrange
        // URI dengan type yang tidak dikenal
        final uri = Uri.parse('pockeat://app_group?widgetName=simple_food&&type=unknown');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.other);
      });
      
      test('should emit default event type for null URI', () async {
        // Arrange
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(null);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.other);
      });
    });
    
    group('registerWidgetClickCallback', () {
      test('should register callback for widget clicks', () async {
        // Arrange
        when(mockHomeWidget.registerBackgroundCallback(any))
            .thenAnswer((_) async {});
        
        // Act
        await service.registerWidgetClickCallback();
        
        // Assert
        verify(mockHomeWidget.registerBackgroundCallback(any)).called(1);
      });
    });
    
    group('widgetEvents stream', () {
      test('should be a broadcast stream', () {
        // Assert
        expect(service.widgetEvents.isBroadcast, isTrue);
      });
      
      test('should allow multiple subscribers', () async {
        // Arrange
        // Create two listeners to the same stream
        final eventsFuture1 = service.widgetEvents.first;
        final eventsFuture2 = service.widgetEvents.first;
        
        // Act - URI dengan format yang benar untuk memicu event clicked
        // Format: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        final uri = Uri.parse('pockeat://app_group?widgetName=simple_food&&type=click');
        await service.handleWidgetClicked(uri);
        
        // Assert - both listeners should receive the same event
        final emittedEvent1 = await eventsFuture1;
        final emittedEvent2 = await eventsFuture2;
        
        expect(emittedEvent1, FoodWidgetEventType.clicked);
        expect(emittedEvent2, FoodWidgetEventType.clicked);
      });
      
      test('should handle URI without type parameter', () async {
        // Arrange
        // URI tanpa parameter type
        final uri = Uri.parse('pockeat://app_group?widgetName=simple_food');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.other);
      });
      
      test('should handle negative numeric values in widget storage', () async {
        // Arrange
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.caloriesNeeded.toStorageKey()))
            .thenAnswer((_) async => -2000);
        when(mockHomeWidget.getWidgetData(FoodTrackingKey.currentCaloriesConsumed.toStorageKey()))
            .thenAnswer((_) async => -1500);
        
        // Act
        final result = await service.getData();
        
        // Assert
        expect(result.caloriesNeeded, -2000);
        expect(result.currentCaloriesConsumed, -1500);
      });
    });
  });
}
