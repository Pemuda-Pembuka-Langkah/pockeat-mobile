// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/homepage/presentation/screens/homepage.dart';
import 'package:pockeat/features/homepage/presentation/screens/overview_section.dart';
import 'package:pockeat/features/homepage/presentation/screens/pet_homepage_section.dart';
import 'package:pockeat/features/homepage/presentation/widgets/streak_counter_widget.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';
import 'homepage_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<NavigatorObserver>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CalorieStatsService>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<PetService>(),
  MockSpec<FoodLogHistoryService>(),
])
void main() async {
  late MockNavigatorObserver mockNavigatorObserver;
  late MockCalorieStatsService mockCalorieStatsService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockPetService mockPetService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
    mockCalorieStatsService = MockCalorieStatsService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockPetService = MockPetService();
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    final getIt = GetIt.instance;

    if (getIt.isRegistered<FirebaseAuth>()) {
      getIt.unregister<FirebaseAuth>();
    }
    if (getIt.isRegistered<User>()) {
      getIt.unregister<User>();
    }
    if (getIt.isRegistered<CalorieStatsService>()) {
      getIt.unregister<CalorieStatsService>();
    }

    if (getIt.isRegistered<PetService>()) {
      getIt.unregister<PetService>();
    }

    if (getIt.isRegistered<FoodLogHistoryService>()) {
      getIt.unregister<FoodLogHistoryService>();
    }

    // Register mock services
    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
    getIt.registerSingleton<CalorieStatsService>(mockCalorieStatsService);
    getIt.registerSingleton<PetService>(mockPetService);
    getIt.registerSingleton<FoodLogHistoryService>(mockFoodLogHistoryService);

    // Setup default mock behaviors
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockCalorieStatsService.calculateStatsForDate(any, any))
        .thenAnswer((_) async => DailyCalorieStats(
              caloriesConsumed: 100,
              caloriesBurned: 100,
              userId: 'test-uid',
              date: DateTime.now(),
            ));
    when(mockFoodLogHistoryService.getFoodStreakDays(any))
        .thenAnswer((_) async => 1);
    when(mockPetService.getPetMood(any)).thenAnswer((_) async => 'happy');
    when(mockPetService.getPetHeart(any)).thenAnswer((_) async => 4);
  });

  // Widget helper untuk membungkus test dengan Provider
  Widget createTestWidget() {
    return MaterialApp(
      navigatorObservers: [mockNavigatorObserver],
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<NavigationProvider>(
            create: (_) => NavigationProvider(),
          ),
        ],
        child: const HomePage(),
      ),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('HomePage should render correctly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Tunggu semua Future selesai
      await tester.pump();

      // Assert
      expect(find.text('Pockeat'), findsOneWidget);
      expect(find.byType(PetHomepageSection), findsOneWidget);
      expect(find.byType(OverviewSection), findsOneWidget);
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
    });

    testWidgets('HomePage should have SliverAppBar with correct properties',
        (WidgetTester tester) async {
      // Arrange
      when(mockFoodLogHistoryService.getFoodStreakDays(any))
          .thenAnswer((_) async => 5);

      // Act - build widget
      await tester.pumpWidget(createTestWidget());

      // Tunggu widget selesai dirender
      await tester.pump();

      // Assert
      final SliverAppBar appBar = tester.widget(find.byType(SliverAppBar));
      expect(appBar.pinned, true);
      expect(appBar.floating, false);
      expect(appBar.backgroundColor, const Color(0xFFFFE893));
      expect(appBar.elevation, 0);
      expect(appBar.toolbarHeight, 60);
    });

    testWidgets(
        'HomePage should display PetHomepageSection and OverviewSection in ListView',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Tunggu widget selesai dirender
      await tester.pump();

      // Assert
      final ListView listView = tester.widget(find.byType(ListView));
      expect(listView.padding,
          const EdgeInsets.symmetric(horizontal: 0, vertical: 20));

      // Check if both sections are children of ListView
      final List<Widget> listViewChildren = tester
          .widgetList<Widget>(find.descendant(
            of: find.byType(ListView),
            matching: find.byWidgetPredicate((widget) =>
                widget is PetHomepageSection || widget is OverviewSection),
          ))
          .toList();

      expect(listViewChildren.length, 2);
      expect(listViewChildren[0] is PetHomepageSection, true);
      expect(listViewChildren[1] is OverviewSection, true);
    });

    testWidgets(
        'HomePage should display PetHomepageSection with correct streak days',
        (WidgetTester tester) async {
      // Arrange - set a specific streak value
      const testStreakDays = 7;
      when(mockFoodLogHistoryService.getFoodStreakDays(any))
          .thenAnswer((_) async => testStreakDays);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Wait for async operations to complete
      await tester.pump();

      // Assert - verify pet section exists with correct streak value
      expect(find.byType(PetHomepageSection), findsOneWidget);

      // Verify the PetHomepageSection received the correct streak days
      final petSection =
          tester.widget<StreakCounterWidget>(find.byType(StreakCounterWidget));
      expect(petSection.streakDays, testStreakDays);
    });

    testWidgets('HomePage should call getFoodStreakDays with correct user ID',
        (WidgetTester tester) async {
      // Arrange
      const testUserId = 'test-uid';
      when(mockFoodLogHistoryService.getFoodStreakDays(any))
          .thenAnswer((_) async => 5);

      // Act - build widget
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify service was called with correct user ID
      verify(mockFoodLogHistoryService.getFoodStreakDays(testUserId)).called(1);
    });

    testWidgets('HomePage should handle case when user is null',
        (WidgetTester tester) async {
      // Arrange - simulate no logged in user
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      when(mockFoodLogHistoryService.getFoodStreakDays(''))
          .thenAnswer((_) async => throw Exception('Test error'));
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - should still render but with default values
      expect(find.byType(PetHomepageSection), findsOneWidget);

      // Verify display error text
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.startsWith('Error'),
        ),
        findsOneWidget,
      );
    });
  });
}
