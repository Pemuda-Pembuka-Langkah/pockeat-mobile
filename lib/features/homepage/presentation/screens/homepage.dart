// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/caloric_requirement/domain/repositories/caloric_requirement_repository.dart';
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/homepage/presentation/screens/overview_section.dart';
import 'package:pockeat/features/homepage/presentation/screens/pet_homepage_section.dart';
import 'package:pockeat/features/pet_companion/domain/model/pet_information.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  // Services
  final PetService _petService = GetIt.instance<PetService>();
  final CalorieStatsService _calorieStatsService =
      GetIt.instance<CalorieStatsService>();
  final FoodLogHistoryService _foodLogHistoryService =
      GetIt.instance<FoodLogHistoryService>();
  final userId = GetIt.instance<FirebaseAuth>().currentUser?.uid ?? '';
  final caloricRequirementRepository =
      GetIt.instance<CaloricRequirementRepository>();
  final preferencesService = GetIt.instance<UserPreferencesService>();

  // Futures
  late Future<PetInformation> _petInformation;
  late Future<DailyCalorieStats> _statsFuture;
  late Future<int> _dayStreak;
  late Future<int> _targetCalories;
  late Future<bool> _isCalorieCompensationEnabledFuture;
  late Future<bool> _isRolloverCaloriesEnabledFuture;
  late Future<int> _rolloverCaloriesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _petInformation = _petService.getPetInformation(userId);
    _dayStreak = _foodLogHistoryService.getFoodStreakDays(userId);
    _statsFuture =
        _calorieStatsService.calculateStatsForDate(userId, DateTime.now());
    _targetCalories = caloricRequirementRepository
        .getCaloricRequirement(userId)
        .then((value) => value?.tdee.toInt() ?? 0);
    _rolloverCaloriesFuture = preferencesService.getRolloverCalories();
    _isCalorieCompensationEnabledFuture =
        preferencesService.isExerciseCalorieCompensationEnabled();
    _isRolloverCaloriesEnabledFuture =
        preferencesService.isRolloverCaloriesEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 60,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Image.asset(
                    'assets/icons/LogoPanjang_PockEat_draft_transparent.png',
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),
          ],
          body: FutureBuilder<List<dynamic>>(
            future: Future.wait([
              _petInformation,
              _statsFuture,
              _dayStreak,
              _targetCalories,
              _isCalorieCompensationEnabledFuture,
              _isRolloverCaloriesEnabledFuture,
              _rolloverCaloriesFuture,
            ]),
            builder: (context, snapshot) {
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _loadData(); // Reload all the data
                  });
                },
                color: primaryPink, // Use app color theme
                backgroundColor: Colors.white,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  children: [
                    PetHomepageSection(
                      isLoading:
                          snapshot.connectionState == ConnectionState.waiting,
                      petInfo: snapshot.data?[0] as PetInformation?,
                      stats: snapshot.data?[1] as DailyCalorieStats?,
                      streakDays: snapshot.data?[2] as int?,
                    ),
                    OverviewSection(
                      isLoading:
                          snapshot.connectionState == ConnectionState.waiting,
                      stats: snapshot.data?[1] as DailyCalorieStats?,
                      targetCalories: snapshot.data?[3] as int?,
                      isCalorieCompensationEnabled: snapshot.data?[4] as bool?,
                      isRolloverCaloriesEnabled: snapshot.data?[5] as bool?,
                      rolloverCalories: snapshot.data?[6] as int?,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
