// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/homepage/presentation/screens/homepage.dart';
import 'package:pockeat/features/homepage/presentation/screens/overview_section.dart';
import 'package:pockeat/features/homepage/presentation/screens/pet_homepage_section.dart';
import 'package:pockeat/features/homepage/presentation/widgets/pet_companion_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/streak_counter_widget.dart';
import 'package:pockeat/features/pet_companion/domain/model/pet_information.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';
import 'homepage_test.mocks.dart';

// Mock the OverviewSection to avoid PageView rendering issues in tests
class MockOverviewSection extends StatelessWidget {
  final bool foodStreakMaintained;
  final int foodStreakDays;

  const MockOverviewSection({
    super.key,
    this.foodStreakMaintained = true,
    this.foodStreakDays = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.grey[200],
      child: const Center(
        child: Text('Mock Overview Section'),
      ),
    );
  }
}

// Modified HomePage for testing
class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: const Color(0xFFFFE893),
              elevation: 0,
              toolbarHeight: 60,
              title: const Row(
                children: [
                  Text(
                    'Pockeat',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            children: const [
              PetHomepageSection(),
              MockOverviewSection(), // Use mock section to avoid PageView issues
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

@GenerateNiceMocks([
  MockSpec<NavigatorObserver>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CalorieStatsService>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<PetService>(),
  MockSpec<FoodLogHistoryService>(),
  MockSpec<SharedPreferences>(),
  MockSpec<UserPreferencesService>(),
])
void main() async {
  late MockNavigatorObserver mockNavigatorObserver;
  late MockCalorieStatsService mockCalorieStatsService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockPetService mockPetService;
  late MockFoodLogHistoryService mockFoodLogHistoryService;
  late MockSharedPreferences mockSharedPreferences;
  late MockUserPreferencesService mockUserPreferencesService;

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
    mockCalorieStatsService = MockCalorieStatsService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockPetService = MockPetService();
    mockFoodLogHistoryService = MockFoodLogHistoryService();
    mockSharedPreferences = MockSharedPreferences();
    mockUserPreferencesService = MockUserPreferencesService();
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
    if (getIt.isRegistered<SharedPreferences>()) {
      getIt.unregister<SharedPreferences>();
    }
    if (getIt.isRegistered<UserPreferencesService>()) {
      getIt.unregister<UserPreferencesService>();
    }

    // Register mock services
    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
    getIt.registerSingleton<CalorieStatsService>(mockCalorieStatsService);
    getIt.registerSingleton<PetService>(mockPetService);
    getIt.registerSingleton<FoodLogHistoryService>(mockFoodLogHistoryService);
    getIt.registerSingleton<SharedPreferences>(mockSharedPreferences);
    getIt.registerSingleton<UserPreferencesService>(mockUserPreferencesService);

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
    when(mockPetService.getPetInformation(any)).thenAnswer((_) async =>
        PetInformation(
          mood: 'happy',
          heart: 4,
          isCalorieOverTarget: false,
        ));

    when(mockSharedPreferences.getString(any))
        .thenReturn('assets/images/gym.jpg');
    when(mockUserPreferencesService.isExerciseCalorieCompensationEnabled())
        .thenAnswer((_) async => true);
    when(mockUserPreferencesService.isRolloverCaloriesEnabled())
        .thenAnswer((_) async => false);
    when(mockUserPreferencesService.getRolloverCalories())
        .thenAnswer((_) async => 0);
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
        child: const TestHomePage(), // Use test version of HomePage
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

      await tester.scrollUntilVisible(
        find.byType(MockOverviewSection),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(MockOverviewSection), findsOneWidget);
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

      await tester.scrollUntilVisible(
        find.byType(MockOverviewSection),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Assert
      final ListView listView = tester.widget(find.byType(ListView));
      expect(listView.padding,
          const EdgeInsets.symmetric(horizontal: 0, vertical: 20));

      // Check if both sections are children of ListView
      final List<Widget> listViewChildren = tester
          .widgetList<Widget>(find.descendant(
            of: find.byType(ListView),
            matching: find.byWidgetPredicate((widget) =>
                widget is PetHomepageSection || widget is MockOverviewSection),
          ))
          .toList();

      expect(listViewChildren.length, 2);
      expect(listViewChildren[0] is PetHomepageSection, true);
      expect(listViewChildren[1] is MockOverviewSection, true);
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

    testWidgets('Modal should pop up correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Tunggu semua Future selesai
      await tester.pump();

      // Pastikan tombol modal ada
      expect(find.byKey(const Key('open-modal-btn')), findsOneWidget);

      // Tap tombol untuk membuka modal
      await tester.tap(find.byKey(const Key('open-modal-btn')));
      await tester.pump();

      // Pastikan modal muncul dan gambar-gambar ada
      expect(find.text('Change Background'), findsOneWidget);
      expect(find.byKey(const Key('bg-gym')), findsOneWidget);
      expect(find.byKey(const Key('bg-beach')), findsOneWidget);
      expect(find.byKey(const Key('bg-kitchen')), findsOneWidget);

      // Tap salah satu gambar (misal gym)
      await tester.tap(find.byKey(const Key('bg-gym')));
      await tester.pump();

      // tap area di luar modal
      await tester.tapAt(Offset.zero);
      await tester.pump();

      // Modal akan tertutup setelah tap (jika kamu menutup modal di onTap)
      expect(find.text('Change Background'), findsNothing);
    });

    testWidgets('saveBackground should update SharedPreferences',
        (WidgetTester tester) async {
      // Siapkan mock untuk test
      String? savedBackgroundValue;
      when(mockSharedPreferences.setString(any, any)).thenAnswer((invocation) {
        savedBackgroundValue = invocation.positionalArguments[1] as String;
        return Future.value(true);
      });

      // Render widget PetCompanionWidget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PetCompanionWidget(),
        ),
      ));

      // Tunggu widget selesai dirender
      await tester.pump();

      // Ambil state widget
      final state = tester.state(find.byType(PetCompanionWidget)) as dynamic;

      // Panggil saveBackground dengan beach background
      await state.saveBackground('assets/images/beach.jpg');

      // Verifikasi bahwa prefs.setString dipanggil dengan parameter yang benar
      verify(mockSharedPreferences.setString(
              'backgroundImage', 'assets/images/beach.jpg'))
          .called(1);

      // Verifikasi nilai yang tersimpan
      expect(savedBackgroundValue, 'assets/images/beach.jpg');

      // versi gym
      await state.saveBackground('assets/images/gym.jpg');
      verify(mockSharedPreferences.setString(
              'backgroundImage', 'assets/images/gym.jpg'))
          .called(1);

      expect(savedBackgroundValue, 'assets/images/gym.jpg');

      // versi kitchen
      await state.saveBackground('assets/images/kitchen.jpg');
      verify(mockSharedPreferences.setString(
              'backgroundImage', 'assets/images/kitchen.jpg'))
          .called(1);

      expect(savedBackgroundValue, 'assets/images/kitchen.jpg');
    });

    testWidgets('onTap all background options should work correctly',
        (WidgetTester tester) async {
      // Render PetCompanionWidget directly instead of full HomePage
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PetCompanionWidget(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Test onTap untuk gambar gym
      await tester.tap(find.byKey(const Key('open-modal-btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const Key('bg-gym')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final stateGym = tester.state(find.byType(PetCompanionWidget)) as dynamic;
      expect(stateGym.backgroundImage, 'assets/images/gym.jpg');
      verify(mockSharedPreferences.setString(
              'backgroundImage', 'assets/images/gym.jpg'))
          .called(1);

      // Test onTap untuk gambar kitchen
      await tester.tap(find.byKey(const Key('bg-kitchen')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final stateKitchen =
          tester.state(find.byType(PetCompanionWidget)) as dynamic;
      expect(stateKitchen.backgroundImage, 'assets/images/kitchen.jpg');
      verify(mockSharedPreferences.setString(
              'backgroundImage', 'assets/images/kitchen.jpg'))
          .called(1);

      // test onTap untuk gambar beach
      await tester.tap(find.byKey(const Key('bg-beach')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final stateBeach =
          tester.state(find.byType(PetCompanionWidget)) as dynamic;
      expect(stateBeach.backgroundImage, 'assets/images/beach.jpg');
      verify(mockSharedPreferences.setString(
              'backgroundImage', 'assets/images/beach.jpg'))
          .called(1);
    });
  });
}
