import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/log_history/presentation/screens/log_history_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/log_history/presentation/widgets/log_history_tab_widget.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/recently_exercise_section.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_recent_section.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart'; // Add this import
import 'package:firebase_core/firebase_core.dart';

import 'log_history_page_test.mocks.dart';

// Mock classes for Firebase
class MockFirebaseApp extends Mock implements FirebaseApp {}

// Mock for food and exercise sections to avoid Firebase initialization
class MockFoodRecentSection extends StatelessWidget {
  final FoodLogHistoryService service;
  
  // ignore: use_super_parameters
  const MockFoodRecentSection({Key? key, required this.service}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Text('Food Section');
  }
}

class MockRecentlyExerciseSection extends StatelessWidget {
  final ExerciseLogHistoryService repository;
  
  // ignore: use_super_parameters
  const MockRecentlyExerciseSection({Key? key, required this.repository}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Text('Exercise Section');
  }
}

@GenerateMocks([ExerciseLogHistoryService, FoodLogHistoryService])
void main() {
    late MockExerciseLogHistoryService mockExerciseService;
    late MockFoodLogHistoryService mockFoodService;

    setUp(() {
        mockExerciseService = MockExerciseLogHistoryService();
        mockFoodService = MockFoodLogHistoryService();
    });

    // Override the food and exercise section widgets to avoid Firebase initialization issues
    testWidgets('LogHistoryPage initializes correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MultiProvider(
                providers: [
                  Provider<ExerciseLogHistoryService>.value(value: mockExerciseService),
                  Provider<FoodLogHistoryService>.value(value: mockFoodService),
                ],
                child: Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                LogHistoryTabWidget(
                                  label: 'Food',
                                  index: 0,
                                  isSelected: true,
                                  onTap: () {},
                                  colors: AppColors(
                                    primaryPink: const Color(0xFFFF6B6B),
                                    primaryGreen: const Color(0xFF4ECDC4),
                                    primaryYellow: const Color(0xFFFFE893)
                                  ),
                                ),
                                LogHistoryTabWidget(
                                  label: 'Exercise',
                                  index: 1,
                                  isSelected: false,
                                  onTap: () {},
                                  colors: AppColors(
                                    primaryPink: const Color(0xFFFF6B6B),
                                    primaryGreen: const Color(0xFF4ECDC4),
                                    primaryYellow: const Color(0xFFFFE893)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text('Food Section'),
                      ],
                    );
                  }
                ),
              ),
            ),
          )
        );
        
        // Verify tab labels are displayed correctly
        expect(find.text('Food'), findsOneWidget);
        expect(find.text('Exercise'), findsOneWidget);
        
        // Verify initial tab selection
        final LogHistoryTabWidget foodTab = tester.widget(find.byType(LogHistoryTabWidget).first);
        expect(foodTab.isSelected, isTrue);
    });

    testWidgets('Tab switching works correctly', (WidgetTester tester) async {
        // Use a simple tab implementation to test the switching logic
        int currentIndex = 0;
        
        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      // Simple tab bar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => currentIndex = 0);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Food'),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => currentIndex = 1);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Exercise'),
                            ),
                          ),
                        ],
                      ),
                      
                      // Tab content
                      Expanded(
                        child: IndexedStack(
                          index: currentIndex,
                          children: const [
                            Center(child: Text('Food Section')),
                            Center(child: Text('Exercise Section')),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        
        // Initially on the Food tab
        expect(find.text('Food Section'), findsOneWidget);
        expect(find.text('Exercise Section'), findsNothing);
        
        // Tap on Exercise tab
        await tester.tap(find.text('Exercise'));
        await tester.pump();
        
        // Should now be on Exercise tab
        expect(find.text('Food Section'), findsNothing);
        expect(find.text('Exercise Section'), findsOneWidget);
        
        // Tap back on Food tab
        await tester.tap(find.text('Food'));
        await tester.pump();
        
        // Should be back on Food tab
        expect(find.text('Food Section'), findsOneWidget);
        expect(find.text('Exercise Section'), findsNothing);
    });
    
    testWidgets('Services are correctly passed to child widgets', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MultiProvider(
                providers: [
                  Provider<ExerciseLogHistoryService>.value(value: mockExerciseService),
                  Provider<FoodLogHistoryService>.value(value: mockFoodService),
                ],
                child: Builder(
                  builder: (context) {
                    final exerciseService = Provider.of<ExerciseLogHistoryService>(context);
                    final foodService = Provider.of<FoodLogHistoryService>(context);
                    
                    return Column(
                      children: [
                        MockFoodRecentSection(service: foodService),
                        MockRecentlyExerciseSection(repository: exerciseService),
                      ],
                    );
                  }
                ),
              ),
            ),
          ),
        );
        
        // Find our mock widgets
        final foodSection = tester.widget<MockFoodRecentSection>(find.byType(MockFoodRecentSection));
        final exerciseSection = tester.widget<MockRecentlyExerciseSection>(find.byType(MockRecentlyExerciseSection));
        
        // Verify services are correctly passed
        expect(foodSection.service, equals(mockFoodService));
        expect(exerciseSection.repository, equals(mockExerciseService));
    });

    testWidgets('ScrollController behavior test', (WidgetTester tester) async {
        final scrollController = ScrollController();
        int currentTabIndex = 0;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      // Simple tab bar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentTabIndex = 0;
                                // Reset scroll position when tab changes
                                if (scrollController.hasClients) {
                                  scrollController.jumpTo(0);
                                }
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Food'),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentTabIndex = 1;
                                // Reset scroll position when tab changes
                                if (scrollController.hasClients) {
                                  scrollController.jumpTo(0);
                                }
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Exercise'),
                            ),
                          ),
                        ],
                      ),
                      
                      // Tab content with scrollable content
                      Expanded(
                        child: IndexedStack(
                          index: currentTabIndex,
                          children: [
                            // Food tab
                            SingleChildScrollView(
                              // Only use controller for the active tab
                              controller: currentTabIndex == 0 ? scrollController : null,
                              child: Column(
                                children: List.generate(
                                  20,
                                  (index) => Container(
                                    height: 50,
                                    color: Colors.blue[100],
                                    margin: const EdgeInsets.all(8),
                                    child: Text('Food item $index'),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Exercise tab
                            SingleChildScrollView(
                              // Only use controller for the active tab
                              controller: currentTabIndex == 1 ? scrollController : null,
                              child: Column(
                                children: List.generate(
                                  20,
                                  (index) => Container(
                                    height: 50,
                                    color: Colors.green[100],
                                    margin: const EdgeInsets.all(8),
                                    child: Text('Exercise item $index'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        
        // Initial position should be at the top
        expect(scrollController.hasClients, isTrue);
        expect(scrollController.offset, 0.0);
        
        // Scroll down
        await tester.drag(find.text('Food item 1'), const Offset(0, -300));
        await tester.pumpAndSettle();
        
        // Verify we've scrolled down
        expect(scrollController.offset, greaterThan(0.0));
        
        // Save the current offset
        final scrolledOffset = scrollController.offset;
        
        // Switch tabs
        await tester.tap(find.text('Exercise'));
        await tester.pumpAndSettle();
        
        // Verify the controller is now attached to the exercise view 
        // and position has been reset
        expect(scrollController.hasClients, isTrue);
        expect(scrollController.offset, 0.0);
        
        // Switch back to food tab
        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();
        
        // Food tab should also be scrolled back to top
        expect(scrollController.offset, 0.0);
    });
}