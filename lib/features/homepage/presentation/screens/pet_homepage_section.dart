// lib/features/homepage/presentation/screens/pet_homepage_section.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockeat/features/homepage/presentation/widgets/pet_companion_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/heart_bar_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/streak_counter_widget.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:get_it/get_it.dart';

class PetHomepageSection extends StatefulWidget {
  final String petName;

  const PetHomepageSection({
    super.key,
    this.petName = 'Panda',
  });

  @override
  State<PetHomepageSection> createState() => _PetHomepageSectionState();
}

class _PetHomepageSectionState extends State<PetHomepageSection> {
  final PetService _petService = GetIt.instance<PetService>();
  final FoodLogHistoryService _foodLogHistoryService =
      GetIt.instance<FoodLogHistoryService>();
  final CalorieStatsService _calorieStatsService = 
      GetIt.instance<CalorieStatsService>();

  static const int _goalCalories = 2000;
  final userId = GetIt.instance<FirebaseAuth>().currentUser?.uid ?? '';

  late Future<String> _petMood;
  late Future<int> _dayStreak;
  late Future<int> _petHeart;
  late Future<DailyCalorieStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _petMood = _petService.getPetMood(userId);
    _dayStreak = _foodLogHistoryService.getFoodStreakDays(userId);
    _petHeart = _petService.getPetHeart(userId);
    _statsFuture = _calorieStatsService.calculateStatsForDate(userId, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          // Heart Bar
          FutureBuilder<int>(
            future: _petHeart,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return HeartBarWidget(heart: snapshot.data ?? 0);
              }
            },
          ),
          const SizedBox(height: 24),

          // Pet Companion Widget
          Center(
            child: FutureBuilder<List<dynamic>>(
              future: Future.wait([_petMood, _statsFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Data is available
                  final String mood = snapshot.data![0] as String;
                  final DailyCalorieStats stats = snapshot.data![1] as DailyCalorieStats;
                  
                  // Calculate calorie progress percentage
                  final consumed = stats.caloriesConsumed;
                  final progress = (consumed / _goalCalories).clamp(0.0, 1.0);
                  
                  // Determine image path based on mood
                  final String imagePath = mood == 'happy'
                      ? 'assets/images/panda_happy.json'
                      : 'assets/images/panda_sad.json';

                  return PetCompanionWidget(
                    petName: widget.petName,
                    petImagePath: imagePath,
                    calorieProgress: progress,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Streak Counter
          FutureBuilder<int>(
            future: _dayStreak,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final streakDays = snapshot.data ?? 0;

                return StreakCounterWidget(streakDays: streakDays);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}