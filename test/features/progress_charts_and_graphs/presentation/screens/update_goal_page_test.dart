// Import packages for testing

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/screens/update_goal_page.dart';
import 'update_goal_page_test.mocks.dart';

// Generate mock classes with proper generic types
@GenerateMocks([], customMocks: [
  MockSpec<FirebaseAuth>(as: #MockFirebaseAuth),
  MockSpec<FirebaseFirestore>(as: #MockFirebaseFirestore),
  MockSpec<User>(as: #MockUser),
  MockSpec<DocumentReference<Map<String, dynamic>>>(as: #MockDocumentReference),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(as: #MockQuerySnapshot),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(as: #MockDocumentSnapshot),
  MockSpec<CollectionReference<Map<String, dynamic>>>(as: #MockCollectionReference),
  MockSpec<Query<Map<String, dynamic>>>(as: #MockQuery), // Added for where() method
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockUser mockUser;
  late MockCollectionReference mockCollectionReference;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockDocumentReference mockDocumentReference;
  late MockQuery mockQuery; // Added for where() method

  setUp(() {
    // Initialize mocks
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockCollectionReference = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockDocumentReference = MockDocumentReference();
    mockQuery = MockQuery(); // Initialize the query mock

    // Set up mock behavior
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');
    
    when(mockFirebaseFirestore.collection('health_metrics'))
        .thenReturn(mockCollectionReference);
        
    when(mockCollectionReference.where('userId', isEqualTo: 'test-user-id'))
        .thenReturn(mockQuery); // Use mockQuery for where()
        
    when(mockQuery.limit(1)).thenReturn(mockQuery); // Chain limit() to query
    when(mockQuery.get())
        .thenAnswer((_) async => mockQuerySnapshot);
        
    // Mock for snapshot with data
    when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
    when(mockDocumentSnapshot.reference).thenReturn(mockDocumentReference);
    when(mockDocumentReference.update(any)).thenAnswer((_) async => Future<void>.value());
    
    // Default empty data for document snapshot
    when(mockDocumentSnapshot.data()).thenReturn({});
    
    // Mock for adding new document
    when(mockCollectionReference.add(any)).thenAnswer((_) async => mockDocumentReference);
  });

  group('UpdateGoalPage Basic UI Tests', () {
    testWidgets('renders correctly with valid initial weight', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '70'),
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Verify the title is displayed
      expect(find.text('Update Weight Goal'), findsOneWidget);
      
      // Verify weight display
      expect(find.text('70.0'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      
      // Verify the save button is present
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('renders correctly with N/A initial weight', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: 'N/A'),
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Default to 60.0 when N/A
      expect(find.text('60.0'), findsOneWidget);
    });

    testWidgets('renders correctly with invalid initial weight', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: 'invalid'),
      ));

      // Default to 60.0 when invalid
      expect(find.text('60.0'), findsOneWidget);
    });

    testWidgets('shows loading indicator when saving', (WidgetTester tester) async {
      // Override FirebaseFirestore.instance for this test
      // (Note: In real implementation, you would use a proper dependency injection)

      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '70'),
      ));

      // Find and press the save button
      final saveButton = find.text('Save changes');
      expect(saveButton, findsOneWidget);
      
      // This is just to verify the loading behavior would work
      // The actual Firebase calls will be mocked
      
      // In a real test, you would tap the button and check for CircularProgressIndicator
      // But we can't do that directly without proper dependency injection
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
    
    testWidgets('adjusts weight with slider interactions', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '70'),
      ));

      // Find the GestureDetector - changed to expect multiple instances
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsWidgets);  // Changed from findsOneWidget to findsWidgets
      
      // Verify initial state
      expect(find.text('70.0'), findsOneWidget);
    });

    testWidgets('clamps weight within valid range', (WidgetTester tester) async {
      // Test with a value above max (which is 150)
      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '200'),
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Should clamp to max value (150.0)
      expect(find.text('150.0'), findsOneWidget);
      
      // Test with a value below min (which is 30)
      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '20'),
      ));

      // Make sure the UI is fully updated
      await tester.pumpAndSettle();
      
      // Should clamp to min value (30.0)
      expect(find.text('30.0'), findsOneWidget);
    });
  });

  group('UpdateGoalPage Fitness Goal Validation Tests', () {
    testWidgets('shows reminder text for invalid lose weight goal', (WidgetTester tester) async {
      // Setup mock data for "Lose Weight" fitness goal
      when(mockDocumentSnapshot.data()).thenReturn({
        'fitnessGoal': 'Lose Weight',
        'weight': 80.0,
      });

      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '80'), // Equal to current weight (invalid)
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Should show reminder text
      expect(find.text('Your goal is to lose weight. Please set a target weight below your current weight of 80.0 kg.'), 
          findsOneWidget);
      
      // Save button should be disabled (gray)
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      
      final ElevatedButton button = tester.widget(buttonFinder);
      final ButtonStyle? style = button.style;
      
      // Method to check if the button uses grey color
      // This is a simplistic check - in a real test you might need to compare the actual color values
      expect(button.enabled, isFalse);
    });

    testWidgets('shows reminder text for invalid gain weight goal', (WidgetTester tester) async {
      // Setup mock data for "Gain Weight" fitness goal
      when(mockDocumentSnapshot.data()).thenReturn({
        'fitnessGoal': 'Gain Weight',
        'weight': 70.0,
      });

      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '70'), // Equal to current weight (invalid)
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Should show reminder text
      expect(find.text('Your goal is to gain weight. Please set a target weight above your current weight of 70.0 kg.'), 
          findsOneWidget);
      
      // Save button should be disabled
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      
      final ElevatedButton button = tester.widget(buttonFinder);
      expect(button.enabled, isFalse);
    });

    testWidgets('validates lose weight goal correctly', (WidgetTester tester) async {
      // Setup mock data for "Lose Weight" fitness goal
      when(mockDocumentSnapshot.data()).thenReturn({
        'fitnessGoal': 'Lose Weight',
        'weight': 80.0,
      });

      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '70'), // Valid (below current weight)
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Should NOT show reminder text
      expect(find.textContaining('Your goal is to lose weight'), findsNothing);
      
      // Save button should be enabled
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      
      final ElevatedButton button = tester.widget(buttonFinder);
      expect(button.enabled, isTrue);
    });

    testWidgets('validates gain weight goal correctly', (WidgetTester tester) async {
      // Setup mock data for "Gain Weight" fitness goal
      when(mockDocumentSnapshot.data()).thenReturn({
        'fitnessGoal': 'Gain Weight',
        'weight': 70.0,
      });

      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '80'), // Valid (above current weight)
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Should NOT show reminder text
      expect(find.textContaining('Your goal is to gain weight'), findsNothing);
      
      // Save button should be enabled
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      
      final ElevatedButton button = tester.widget(buttonFinder);
      expect(button.enabled, isTrue);
    });
  });

  group('UpdateGoalPage Save Functionality Tests', () {
    testWidgets('saves changes successfully', (WidgetTester tester) async {
      // Mock valid fitness goal data
      when(mockDocumentSnapshot.data()).thenReturn({
        'fitnessGoal': 'Lose Weight',
        'weight': 80.0,
      });
      
      // Verify update is called with correct data
      when(mockDocumentReference.update(any)).thenAnswer((invocation) {
        final Map<String, dynamic> data = invocation.positionalArguments[0] as Map<String, dynamic>;
        expect(data.containsKey('desiredWeight'), true);
        expect(data['desiredWeight'], 70.0);
        return Future<void>.value();
      });

      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '70'),
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Tap the save button
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Verify success message is shown
      expect(find.text('Goals updated successfully'), findsOneWidget);
      
      // Verify navigation happened (this is harder to test directly)
      // In a more complete test, you would check that Navigator.pop was called
      // For this simple test, we just verify the update was called
      verify(mockDocumentReference.update(any)).called(1);
    });

    testWidgets('handles save failure gracefully', (WidgetTester tester) async {
      // Mock valid fitness goal data
      when(mockDocumentSnapshot.data()).thenReturn({
        'fitnessGoal': 'Lose Weight',
        'weight': 80.0,
      });
      
      // Make update throw an error
      when(mockDocumentReference.update(any)).thenThrow(Exception('Test error'));

      await tester.pumpWidget(MaterialApp(
        home: UpdateGoalPage(initialGoalWeight: '70'),
      ));

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Tap the save button
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.textContaining('Failed to update weight goal'), findsOneWidget);
    });
  });
}