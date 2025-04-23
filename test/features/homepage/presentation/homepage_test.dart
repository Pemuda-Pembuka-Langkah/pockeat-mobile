import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/homepage/presentation/screens/homepage.dart';
import 'package:pockeat/features/homepage/presentation/screens/overview_section.dart';
import 'package:pockeat/features/homepage/presentation/screens/pet_homepage_section.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';

@GenerateNiceMocks([
  MockSpec<NavigatorObserver>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CalorieStatsService>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
])
import 'homepage_test.mocks.dart';

void main() async {
  late MockNavigatorObserver mockNavigatorObserver;
  late MockCalorieStatsService mockCalorieStatsService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
    mockCalorieStatsService = MockCalorieStatsService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

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

    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
    getIt.registerSingleton<User>(mockUser);
    getIt.registerSingleton<CalorieStatsService>(mockCalorieStatsService);

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockCalorieStatsService.calculateStatsForDate(any, any)).thenAnswer((_) async => DailyCalorieStats(
      caloriesConsumed: 100,
      caloriesBurned: 100,
      userId: 'test-uid',
      date: DateTime.now(),
    ));
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
    testWidgets('HomePage should render correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Tunggu widget selesai dirender
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pockeat'), findsOneWidget);
      expect(find.byType(NestedScrollView), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(PetHomepageSection), findsOneWidget);
      expect(find.byType(OverviewSection), findsOneWidget);
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
    });

    testWidgets('HomePage should have SliverAppBar with correct properties', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Tunggu widget selesai dirender
      await tester.pumpAndSettle();

      // Assert
      final SliverAppBar appBar = tester.widget(find.byType(SliverAppBar));
      expect(appBar.pinned, true);
      expect(appBar.floating, false);
      expect(appBar.backgroundColor, const Color(0xFFFFE893));
      expect(appBar.elevation, 0);
      expect(appBar.toolbarHeight, 60);
    });

    testWidgets('HomePage should display PetHomepageSection and OverviewSection in ListView', 
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Tunggu widget selesai dirender
      await tester.pumpAndSettle();

      // Assert
      final ListView listView = tester.widget(find.byType(ListView));
      expect(listView.padding, const EdgeInsets.symmetric(horizontal: 0, vertical: 20));
      
      // Check if both sections are children of ListView
      final List<Widget> listViewChildren = tester.widgetList<Widget>(find.descendant(
        of: find.byType(ListView),
        matching: find.byWidgetPredicate((widget) => 
          widget is PetHomepageSection || widget is OverviewSection),
      )).toList();
      
      expect(listViewChildren.length, 2);
      expect(listViewChildren[0] is PetHomepageSection, true);
      expect(listViewChildren[1] is OverviewSection, true);
    });
  });
}