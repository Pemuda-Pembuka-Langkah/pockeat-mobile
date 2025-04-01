import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_recent_section.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([FoodLogHistoryService, FirebaseAuth, User])
import 'food_recent_section_test.mocks.dart';

void main() {
  late MockFoodLogHistoryService mockService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  final testUserId = 'test-user-id';

  setUp(() {
    mockService = MockFoodLogHistoryService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    
    // Set up the mock user
    when(mockUser.uid).thenReturn(testUserId);
    
    // Set up the mock auth
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
  });

  group('FoodRecentSection Widget', () {
    final foodItems = [
      FoodLogHistoryItem(
        id: 'food1',
        title: 'Chicken Salad',
        subtitle: '350 cal, 20g protein',
        timestamp: DateTime.now(),
        calories: 350,
        sourceId: 'source1',
        imageUrl: 'https://example.com/image1.jpg',
      ),
      FoodLogHistoryItem(
        id: 'food2',
        title: 'Pasta',
        subtitle: '450 cal, 15g protein',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        calories: 450,
        sourceId: 'source2',
        imageUrl: 'https://example.com/image2.jpg',
      ),
    ];

    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      // Arrange - Use a Completer to control when the future completes
      when(mockService.getAllFoodLogs(testUserId, limit: 5)).thenAnswer((_) async {
        // Don't use a timer in tests as it causes pending timer issues
        return foodItems;
      });
      
      // Act - Only pump once to capture the loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
              auth: mockFirebaseAuth,
            ),
          ),
        ),
      );
      
      // Assert - initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display food items when loaded', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs(testUserId, limit: 5)).thenAnswer((_) async => foodItems);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
              auth: mockFirebaseAuth,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Chicken Salad'), findsOneWidget);
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Recent Foods'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display empty state when no foods', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs(testUserId, limit: 5)).thenAnswer((_) async => []);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
              auth: mockFirebaseAuth,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('No food history yet'), findsOneWidget);
    });
    
    testWidgets('should navigate to food history page when tapping see all', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs(testUserId, limit: 5)).thenAnswer((_) async => foodItems);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
              auth: mockFirebaseAuth,
            ),
          ),
          routes: {
            '/food-history': (context) => const Scaffold(body: Text('Food History Page')),
          },
        ),
      );
      await tester.pumpAndSettle();
      
      // Tap the "Show All" button
      await tester.tap(find.text('Show All'));
      await tester.pumpAndSettle();
      
      // Assert - should navigate to food history page
      expect(find.text('Food History Page'), findsOneWidget);
    });
    
    testWidgets('should navigate to food detail when tapping a food item', (WidgetTester tester) async {
      // Arrange
      when(mockService.getAllFoodLogs(testUserId, limit: 5)).thenAnswer((_) async => foodItems);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodRecentSection(
              service: mockService,
              limit: 5,
              auth: mockFirebaseAuth,
            ),
          ),
          routes: {
            '/food-detail': (context) => const Scaffold(body: Text('Food Detail Page')),
          },
        ),
      );
      await tester.pumpAndSettle();
      
      // Tap the first food item
      await tester.tap(find.text('Chicken Salad'));
      await tester.pumpAndSettle();
      
      // Assert - should navigate to food detail page
      expect(find.text('Food Detail Page'), findsOneWidget);
    });
  });
}
