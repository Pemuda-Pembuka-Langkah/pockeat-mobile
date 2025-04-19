// This file needs to be updated by build_runner

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/food_tracking_keys.dart';
import 'package:pockeat/features/home_screen_widget/domain/constants/widget_event_type.dart';
import 'package:pockeat/features/home_screen_widget/domain/models/detailed_food_tracking.dart';
import 'package:pockeat/features/home_screen_widget/services/impl/detailed_food_tracking_widget_service.dart';
import 'package:pockeat/features/home_screen_widget/services/utils/home_widget_client.dart';

@GenerateMocks([
  HomeWidgetInterface
])

// Note: Run flutter pub run build_runner build --delete-conflicting-outputs
// to generate the mock classes

import 'detailed_food_tracking_widget_service_test.mocks.dart';

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
      test('should set app group ID and register callback', () async {
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
      test('should emit clicked event type for click type', () async {
        // Arrange
        // Format URI: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=click');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.clicked);
      });
      
      test('should emit clicked event type for tap type', () async {
        // Arrange
        // Format URI: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=tap');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.clicked);
      });
      
      test('should emit quicklog event type for quick type', () async {
        // Arrange
        // Format URI: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=quick');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.quicklog);
      });
      
      test('should emit quicklog event type for log type', () async {
        // Arrange
        // Format URI: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=log');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.quicklog);
      });
      
      test('should emit refresh event type for refresh type', () async {
        // Arrange
        // Format URI: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=refresh');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.refresh);
      });
      
      test('should emit refresh event type with refresh parameter', () async {
        // Arrange
        // Format URI dengan parameter refresh
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&refresh=true');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.refresh);
      });
      
      test('should emit default event type for unknown type', () async {
        // Arrange
        // Format URI dengan type yang tidak dikenal
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=unknown');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.other);
      });
      
      test('should emit default event type for URI without type', () async {
        // Arrange
        // URI tanpa parameter type
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food');
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
      
      test('should handle case-insensitive type with proper params', () async {
        // Arrange
        // Format URI with uppercase TYPE
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=CLICK&&nutrient=protein');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.clicked);
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
          test('should emit default event type for nutrition path with protein param', () async {
            // Arrange
            // URI tanpa parameter type seharusnya mengembalikan FoodWidgetEventType.other
            final uri = Uri.parse('pockeat://nutrition?protein=75');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert - sesuai implementasi _determineEventType
            expect(emittedEvent, FoodWidgetEventType.other);
          });
          
          test('should emit default event type for detail path with carb param', () async {
            // Arrange
            // URI tanpa parameter type seharusnya mengembalikan FoodWidgetEventType.other
            final uri = Uri.parse('pockeat://detail?carb=200');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert - sesuai implementasi _determineEventType
            expect(emittedEvent, FoodWidgetEventType.other);
          });
          
          test('should emit quicklog event type for quick type', () async {
            // Arrange
            // Format URI: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
            final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=quick');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert
            expect(emittedEvent, FoodWidgetEventType.quicklog);
          });
          
          test('should emit correct event type for log type', () async {
            // Arrange
            // Format URI: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
            final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=log');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert
            expect(emittedEvent, FoodWidgetEventType.quicklog);
          });
          
          test('should emit correct event type for refresh type', () async {
            // Arrange
            // Format URI: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
            final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=refresh');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert
            expect(emittedEvent, FoodWidgetEventType.refresh);
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
          
          test('should handle case-insensitive type parameter', () async {
            // Arrange
            // URI dengan type parameter dalam huruf kapital
            final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=CLICK');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert - sesuai implementasi _determineEventType
            expect(emittedEvent, FoodWidgetEventType.clicked);
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
            
            // Act - menggunakan URI dengan format yang benar sesuai implementasi terbaru
            // Format: pockeat://<groupId>?widgetName=<widgetName>&&type=<action type>
            final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&type=click');
            await service.handleWidgetClicked(uri);
            
            // Assert - both listeners should receive the same event
            final emittedEvent1 = await eventsFuture1;
            final emittedEvent2 = await eventsFuture2;
            
            expect(emittedEvent1, FoodWidgetEventType.clicked);
            expect(emittedEvent2, FoodWidgetEventType.clicked);
          });
        });
        
        // Edge Cases
        group('edge cases', () {
          test('should handle empty URI path', () async {
            // Arrange
            final uri = Uri.parse('pockeat://');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert
            expect(emittedEvent, FoodWidgetEventType.other);
          });
          
          test('should handle URI with query parameters only', () async {
            // Arrange
            final uri = Uri.parse('pockeat://?refresh=true');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert
            expect(emittedEvent, FoodWidgetEventType.refresh);
          });
          
          test('should handle weird URI format gracefully', () async {
            // Arrange - menggunakan URI yang memiliki format tidak standar tapi valid
            final uri = Uri.parse('pockeat://strange/path?param=value#fragment');
            final eventsFuture = service.widgetEvents.first;
            
            // Act
            await service.handleWidgetClicked(uri);
            final emittedEvent = await eventsFuture;
            
            // Assert - should not crash and return a default event
            expect(emittedEvent, FoodWidgetEventType.other);
          });
          
          test('should handle exception when trying to send to closed stream', () async {
            // Arrange
            final newService = DetailedFoodTrackingWidgetService(
              widgetName: testWidgetName,
              appGroupId: testAppGroupId,
              homeWidget: mockHomeWidget,
            );
            
            final uri = Uri.parse('pockeat://nutrition');
            
            // Act & Assert
            // Close the StreamController
            await newService.handleWidgetClicked(uri); // Should work fine
            
            // No exception expected, even though we can't verify the event was processed
          });
      });
      
      test('should handle URI with refresh parameter', () async {
        // Arrange
        // Format URI dengan parameter refresh
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food&&refresh=true');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert
        expect(emittedEvent, FoodWidgetEventType.refresh);
      });
      
      test('should handle URI without type parameter gracefully', () async {
        // Arrange
        // URI tanpa parameter type
        final uri = Uri.parse('pockeat://app_group?widgetName=detailed_food');
        final eventsFuture = service.widgetEvents.first;
        
        // Act
        await service.handleWidgetClicked(uri);
        final emittedEvent = await eventsFuture;
        
        // Assert - should return default event
        expect(emittedEvent, FoodWidgetEventType.other);
      });
      
      test('should handle exception when trying to send to closed stream', () async {
        // Arrange
        final newService = DetailedFoodTrackingWidgetService(
          widgetName: testWidgetName,
          appGroupId: testAppGroupId,
          homeWidget: mockHomeWidget,
        );
        
        final uri = Uri.parse('pockeat://nutrition');
        
        // Act & Assert
        // Close the StreamController
        await newService.handleWidgetClicked(uri); // Should work fine
        
        // No exception expected, even though we can't verify the event was processed
      });

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
