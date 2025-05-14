// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/circular_indicator_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// Mock service
class MockFoodLogDataService implements FoodLogDataService {
  @override
  Future<List<CalorieData>> getWeekCalorieData({int weeksAgo = 0}) async {
    return [
      CalorieData('Mon', 2000, 500, 1500),
      CalorieData('Tue', 1800, 400, 1400),
    ];
  }

  @override
  Future<List<CalorieData>> getMonthCalorieData() async {
    return [
      CalorieData('Week 1', 14000, 3500, 10500),
      CalorieData('Week 2', 13800, 3400, 10400),
    ];
  }

  @override
  double calculateTotalCalories(List<CalorieData> data) {
    return 3800;
  }
}

// Test widget wrapper to isolate the part we want to test
class TestWeightIndicator extends StatefulWidget {
  const TestWeightIndicator({Key? key}) : super(key: key);

  @override
  _TestWeightIndicatorState createState() => _TestWeightIndicatorState();
}

class _TestWeightIndicatorState extends State<TestWeightIndicator> {
  bool isLoadingWeight = true;
  String currentWeight = "0";
  bool isLoadingWeightGoal = true;
  String weightGoal = "0";

  void updateWeight(String weight, bool isLoading) {
    setState(() {
      currentWeight = weight;
      isLoadingWeight = isLoading;
    });
  }

  void updateWeightGoal(String goal, bool isLoading) {
    setState(() {
      weightGoal = goal;
      isLoadingWeightGoal = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CircularIndicatorWidget(
                label: "Weight Goal",
                value: isLoadingWeightGoal ? "Loading..." : "$weightGoal kg",
                icon: Icons.flag_outlined,
                color: const Color(0xFF4ECDC4), // primaryGreen
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CircularIndicatorWidget(
                label: "Current Weight",
                value: isLoadingWeight ? "Loading..." : "$currentWeight kg",
                icon: Icons.scale,
                color: const Color(0xFFFF6B6B), // primaryPink
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  // Setup mocks
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  
  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    
    // Setup GetIt for food log service
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<FoodLogDataService>()) {
      getIt.registerSingleton<FoodLogDataService>(MockFoodLogDataService());
    } else {
      getIt.unregister<FoodLogDataService>();
      getIt.registerSingleton<FoodLogDataService>(MockFoodLogDataService());
    }
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<FoodLogDataService>()) {
      getIt.unregister<FoodLogDataService>();
    }
  });

  // Test the simpler test widget first to verify the indicator works
  group('Weight Indicator Widget', () {
    testWidgets('shows loading state initially for both indicators', (WidgetTester tester) async {
      await tester.pumpWidget(const TestWeightIndicator());
      expect(find.text('Loading...'), findsNWidgets(2));
      expect(find.text('Weight Goal'), findsOneWidget);
      expect(find.text('Current Weight'), findsOneWidget);
    });

    testWidgets('updates to show current weight', (WidgetTester tester) async {
      await tester.pumpWidget(const TestWeightIndicator());
      
      // Get state and update it
      final state = tester.state<_TestWeightIndicatorState>(find.byType(TestWeightIndicator));
      state.updateWeight('80', false);
      await tester.pump();
      
      expect(find.text('80 kg'), findsOneWidget);
      // Weight Goal should still be Loading...
      expect(find.text('Loading...'), findsOneWidget);
    });
    
    testWidgets('updates to show weight goal', (WidgetTester tester) async {
      await tester.pumpWidget(const TestWeightIndicator());
      
      // Get state and update it
      final state = tester.state<_TestWeightIndicatorState>(find.byType(TestWeightIndicator));
      state.updateWeightGoal('65', false);
      await tester.pump();
      
      expect(find.text('65 kg'), findsOneWidget);
      // Current Weight should still be Loading...
      expect(find.text('Loading...'), findsOneWidget);
    });
    
    testWidgets('shows "N/A kg" when weight data is not available', (WidgetTester tester) async {
      await tester.pumpWidget(const TestWeightIndicator());
      
      final state = tester.state<_TestWeightIndicatorState>(find.byType(TestWeightIndicator));
      state.updateWeight('N/A', false);
      await tester.pump();
      
      expect(find.text('N/A kg'), findsOneWidget);
    });
    
    testWidgets('shows "N/A kg" when weight goal is not available', (WidgetTester tester) async {
      await tester.pumpWidget(const TestWeightIndicator());
      
      final state = tester.state<_TestWeightIndicatorState>(find.byType(TestWeightIndicator));
      state.updateWeightGoal('N/A', false);
      await tester.pump();
      
      expect(find.text('N/A kg'), findsOneWidget);
    });
    
    testWidgets('shows "Error kg" when there is an error loading weight', (WidgetTester tester) async {
      await tester.pumpWidget(const TestWeightIndicator());
      
      final state = tester.state<_TestWeightIndicatorState>(find.byType(TestWeightIndicator));
      state.updateWeight('Error', false);
      await tester.pump();
      
      expect(find.text('Error kg'), findsOneWidget);
    });
    
    testWidgets('shows "Error kg" when there is an error loading weight goal', (WidgetTester tester) async {
      await tester.pumpWidget(const TestWeightIndicator());
      
      final state = tester.state<_TestWeightIndicatorState>(find.byType(TestWeightIndicator));
      state.updateWeightGoal('Error', false);
      await tester.pump();
      
      expect(find.text('Error kg'), findsOneWidget);
    });
    
    testWidgets('updates both weight and weight goal correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TestWeightIndicator());
      
      final state = tester.state<_TestWeightIndicatorState>(find.byType(TestWeightIndicator));
      state.updateWeight('78', false);
      state.updateWeightGoal('70', false);
      await tester.pump();
      
      expect(find.text('78 kg'), findsOneWidget);
      expect(find.text('70 kg'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });
  });
}