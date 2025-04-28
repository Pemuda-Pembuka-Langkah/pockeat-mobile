// // Flutter imports:
// import 'package:flutter/material.dart';

// // Package imports:
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';

// // Project imports:
// import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
// import 'package:pockeat/features/food_log_history/presentation/screens/food_history_page.dart';
// import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
// import 'food_history_page_test.mocks.dart';

// @GenerateMocks(
//     [FoodLogHistoryService, firebase_auth.FirebaseAuth, firebase_auth.User])

// void main() {
//   late MockFoodLogHistoryService mockService;
//   late MockFirebaseAuth mockAuth;
//   late MockUser mockUser;

//   setUp(() {
//     mockService = MockFoodLogHistoryService();
//     mockAuth = MockFirebaseAuth();
//     mockUser = MockUser();

//     // Configure mock auth
//     when(mockUser.uid).thenReturn('test-user-id');
//     when(mockAuth.currentUser).thenReturn(mockUser);
//   });

//   final testFoods = [
//     FoodLogHistoryItem(
//       id: 'food1',
//       title: 'Chicken Salad',
//       subtitle: '350 calories',
//       timestamp: DateTime.now(),
//       calories: 350,
//       imageUrl: 'https://example.com/image1.jpg',
//     ),
//     FoodLogHistoryItem(
//       id: 'food2',
//       title: 'Pasta',
//       subtitle: '450 calories',
//       timestamp: DateTime.now().subtract(const Duration(days: 1)),
//       calories: 450,
//       imageUrl: 'https://example.com/image2.jpg',
//     ),
//     FoodLogHistoryItem(
//       id: 'food3',
//       title: 'Burger',
//       subtitle: '650 calories',
//       timestamp: DateTime.now().subtract(const Duration(days: 30)),
//       calories: 650,
//       imageUrl: 'https://example.com/image3.jpg',
//     ),
//   ];

//   Widget createFoodHistoryPage() {
//     return MaterialApp(
//       home: FoodHistoryPage(service: mockService, auth: mockAuth),
//       routes: {
//         '/food-detail': (context) =>
//             const Scaffold(body: Text('Food Detail Page')),
//       },
//     );
//   }

//   group('FoodHistoryPage', () {
//     testWidgets('should display loading indicator when loading',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any)).thenAnswer((_) async {
//         // Don't use a timer in tests as it causes pending timer issues
//         return testFoods;
//       });

//       // Act - Only pump once to capture the loading state
//       await tester.pumpWidget(createFoodHistoryPage());

//       // Assert - initially should show loading
//       expect(find.byType(CircularProgressIndicator), findsOneWidget);
//     });

//     testWidgets('should display food list when loaded',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any)).thenAnswer((_) async => testFoods);

//       // Act
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();

//       // Assert
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsOneWidget);
//       expect(find.text('Burger'), findsOneWidget);
//     });

//     testWidgets('should display empty state when no foods',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any)).thenAnswer((_) async => []);

//       // Act
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();

//       // Assert
//       expect(find.text('No food logs found'), findsOneWidget);
//     });

//     // testWidgets('should filter foods by date', (WidgetTester tester) async {
//     //   // Arrange
//     //   // Mock the initial getAllFoodLogs call
//     //   when(mockService.getAllFoodLogs()).thenAnswer((_) async => testFoods);

//     //   // Mock the getFoodLogsByDate call that will be made after selecting the date filter
//     //   final filteredFoods = [testFoods[0]]; // Only the first food item
//     //   when(mockService.getFoodLogsByDate(any)).thenAnswer((_) async => filteredFoods);

//     //   // Act - Render the page
//     //   await tester.pumpWidget(createFoodHistoryPage());
//     //   await tester.pumpAndSettle();

//     //   // Initially should show all foods
//     //   expect(find.text('Chicken Salad'), findsOneWidget);
//     //   expect(find.text('Pasta'), findsOneWidget);
//     //   expect(find.text('Burger'), findsOneWidget);

//     //   // Find and tap the date filter button
//     //   final dateFilterButton = find.text('By Date');
//     //   await tester.tap(dateFilterButton);
//     //   await tester.pumpAndSettle();

//     //   // Since we can't interact with the date picker in tests,
//     //   // we'll verify that the service method was called with the right filter type
//     //   // when the UI is updated after filter selection

//     //   // Verify that the service method was called
//     //   verify(mockService.getFoodLogsByDate(any)).called(1);
//     // });

//     testWidgets('should search foods by query', (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any)).thenAnswer((_) async => testFoods);

//       // Act
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();

//       // Initially should show all foods
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsOneWidget);
//       expect(find.text('Burger'), findsOneWidget);

//       // Find the search field and enter text
//       final searchField = find.byType(TextField);
//       await tester.tap(searchField);
//       await tester.enterText(searchField, 'Chicken');
//       await tester.pumpAndSettle();

//       // The search is done locally in the _filterFoods method, not via a service call
//       // So we don't need to verify a service method, just check if the UI is updated

//       // After searching, only "Chicken Salad" should be visible
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsNothing);
//       expect(find.text('Burger'), findsNothing);
//     });

//     testWidgets('should navigate to food detail page when tapping a food item',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any)).thenAnswer((_) async => testFoods);

//       // Act
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();

//       // Tap on a food item
//       await tester.tap(find.text('Chicken Salad'));
//       await tester.pumpAndSettle();

//       // Assert
//       expect(find.text('Food Detail Page'), findsOneWidget);
//     });

//     testWidgets('should show empty state when no food items are available',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any, limit: anyNamed('limit')))
//           .thenAnswer((_) async => []);

//       // Act
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();

//       // Assert - pesan yang benar adalah 'No food logs found'
//       expect(find.text('No food logs found'), findsOneWidget);
//     });
    
//     testWidgets('should show error state when loading fails',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any, limit: anyNamed('limit')))
//           .thenThrow(Exception('Network error'));

//       // Act
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();

//       // Assert - verify error message is shown
//       expect(find.text('Error loading foods'), findsOneWidget);
//       expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
//     });
    
//     testWidgets('should reload foods when retry button is pressed',
//         (WidgetTester tester) async {
//       // Arrange - first call throws error, second call succeeds
//       when(mockService.getAllFoodLogs(any, limit: anyNamed('limit')))
//           .thenAnswer((_) => Future.error(Exception('Network error')));

//       // Act - Initial load fails
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();
      
//       // Verify error state
//       expect(find.text('Error loading foods'), findsOneWidget);
      
//       // Now change the mock to return success on next call
//       when(mockService.getAllFoodLogs(any, limit: anyNamed('limit')))
//           .thenAnswer((_) async => testFoods);
          
//       // Tap the retry button
//       await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
//       await tester.pumpAndSettle();
      
//       // Verify foods loaded successfully after retry
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsOneWidget);
//       expect(find.text('Error loading foods'), findsNothing);
//     });
    
//     testWidgets('should display filter chip for date selection',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any, limit: anyNamed('limit')))
//           .thenAnswer((_) async => testFoods);

//       // Act - load page
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();
      
//       // Initially all foods should be shown
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsOneWidget);
//       expect(find.text('Burger'), findsOneWidget);
      
//       // Verify filter chip is present
//       expect(find.text('By Date').first, findsOneWidget);
      
//       // Test that the chip is tappable
//       await tester.tap(find.text('By Date').first);
//       await tester.pumpAndSettle();
      
//       // Verify the filter is in an active state (implementation would typically show 
//       // a date picker or change the chip appearance)
//       // We can't fully mock the date picker interaction in this test
      
//       // Verify foods are still visible since no date was actually selected
//       expect(find.text('Chicken Salad'), findsOneWidget);
//     });
    
//     testWidgets('should display filter chip for month selection',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any, limit: anyNamed('limit')))
//           .thenAnswer((_) async => testFoods);
          
//       // Act - load page
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();
      
//       // Initially all foods should be shown
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsOneWidget);
//       expect(find.text('Burger'), findsOneWidget);
      
//       // Verify filter chip is present
//       expect(find.text('By Month').first, findsOneWidget);
      
//       // Test that the chip is tappable
//       await tester.tap(find.text('By Month').first);
//       await tester.pumpAndSettle();
      
//       // Verify the filter is in an active state
//       // We can't fully mock the month picker interaction in this test
      
//       // Verify foods are still visible since no month was actually selected
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsOneWidget);
//     });
    
//     testWidgets('should show search field and allow filtering',
//         (WidgetTester tester) async {
//       // Arrange
//       when(mockService.getAllFoodLogs(any, limit: anyNamed('limit')))
//           .thenAnswer((_) async => testFoods);

//       // Act - load page
//       await tester.pumpWidget(createFoodHistoryPage());
//       await tester.pumpAndSettle();
      
//       // Verify search field exists
//       expect(find.byType(TextField), findsOneWidget);
      
//       // Verify initially all items are visible
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsOneWidget);
//       expect(find.text('Burger'), findsOneWidget);
      
//       // Enter search query that should match only one item
//       await tester.enterText(find.byType(TextField), 'Chicken');
//       await tester.pumpAndSettle();
      
//       // Verify items are filtered correctly
//       expect(find.text('Chicken Salad'), findsOneWidget);
      
//       // Now clear the text field by entering empty text
//       await tester.enterText(find.byType(TextField), '');
//       await tester.pumpAndSettle();
      
//       // Verify all items are visible again
//       expect(find.text('Chicken Salad'), findsOneWidget);
//       expect(find.text('Pasta'), findsOneWidget);
//       expect(find.text('Burger'), findsOneWidget);
//     });
//   });
// }
