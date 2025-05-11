// lib/features/homepage/presentation/screens/pet_homepage_section.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/domain/models/daily_calorie_stats.dart';
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/homepage/presentation/widgets/heart_bar_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/pet_companion_widget.dart';
import 'package:pockeat/features/homepage/presentation/widgets/streak_counter_widget.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';
import 'package:pockeat/features/pet_companion/domain/model/pet_information.dart';

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
  final CalorieStatsService _calorieStatsService =
      GetIt.instance<CalorieStatsService>();
  final FoodLogHistoryService _foodLogHistoryService =
      GetIt.instance<FoodLogHistoryService>();

  static const int _goalCalories = 2000;
  final userId = GetIt.instance<FirebaseAuth>().currentUser?.uid ?? '';

  late Future<DailyCalorieStats> _statsFuture;
  late Future<PetInformation> _petInformation;
  late Future<int> _dayStreak;

  @override
  void initState() {
    super.initState();
    _petInformation = _petService.getPetInformation(userId);
    _dayStreak = _foodLogHistoryService.getFoodStreakDays(userId);
    _statsFuture =
        _calorieStatsService.calculateStatsForDate(userId, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          // Heart Bar
          FutureBuilder<PetInformation>(
            future: _petInformation,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return HeartBarWidget(
                  heart: snapshot.data?.heart ?? 0,
                  isCalorieOverTarget:
                      snapshot.data?.isCalorieOverTarget ?? false,
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Pet Companion Widget
          Center(
            child: FutureBuilder<List<dynamic>>(
              future: Future.wait([_petInformation, _statsFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Data is available
                  final String mood = snapshot.data![0].mood;
                  final DailyCalorieStats stats =
                      snapshot.data![1] as DailyCalorieStats;

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
