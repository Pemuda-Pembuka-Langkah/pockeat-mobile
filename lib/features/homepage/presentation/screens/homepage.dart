// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/caloric_requirement/domain/models/caloric_requirement_model.dart';
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
  late Future<Map<String, int>> _currentMacrosFuture;
  late Future<CaloricRequirementModel?> _caloricRequirementModelFuture;

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

    // Initialize the new futures
    _caloricRequirementModelFuture =
        caloricRequirementRepository.getCaloricRequirement(userId);
    _currentMacrosFuture = _calculateCurrentMacros();
  }

  // New method to calculate current macronutrients consumed today
  Future<Map<String, int>> _calculateCurrentMacros() async {
    try {
      final logs = await _foodLogHistoryService.getFoodLogsByDate(
          userId, DateTime.now());

      int proteinTotal = 0;
      int carbsTotal = 0;
      int fatTotal = 0;

      for (var log in logs) {
        proteinTotal += (log.protein ?? 0).round();
        carbsTotal += (log.carbs ?? 0).round();
        fatTotal += (log.fat ?? 0).round();
      }

      return {
        'protein': proteinTotal,
        'carbs': carbsTotal,
        'fat': fatTotal,
      };
    } catch (e) {
      debugPrint('Error calculating macros: $e');
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }
  }
  // coverage:ignore-start
  // Show exit confirmation dialog
  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  // This will close the app
                  SystemNavigator.pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
    
    return shouldExit;
  }
  // coverage:ignore-end
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
              centerTitle: true, // Tambahkan centerTitle: true
              title: Image.asset(
                'assets/icons/LogoPanjang_PockEat_draft_transparent.png',
                width: 100,
                height: 100,
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
              _currentMacrosFuture,
              _caloricRequirementModelFuture,
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
                      targetCalories: snapshot.data?[3] as int?,
                    ),
                    OverviewSection(
                      isLoading:
                          snapshot.connectionState == ConnectionState.waiting,
                      stats: snapshot.data?[1] as DailyCalorieStats?,
                      targetCalories: snapshot.data?[3] as int?,
                      isCalorieCompensationEnabled: snapshot.data?[4] as bool?,
                      isRolloverCaloriesEnabled: snapshot.data?[5] as bool?,
                      rolloverCalories: snapshot.data?[6] as int?,
                      currentMacros: snapshot.data?[7] as Map<String, int>?,
                      targetMacros:
                          snapshot.data?[8] as CaloricRequirementModel?,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    ));
  }
}
