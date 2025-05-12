// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pockeat/features/calorie_stats/services/calorie_stats_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
import 'package:pockeat/features/pet_companion/domain/model/pet_information.dart';
import 'package:pockeat/features/pet_companion/domain/services/pet_service.dart';

class PetServiceImpl implements PetService {
  final GetIt _getIt = GetIt.instance;
  late final FoodLogHistoryService foodLogHistoryService;
  late final CalorieStatsService calorieStatsService;
  late final FirebaseFirestore firestore;

  PetServiceImpl() {
    foodLogHistoryService = _getIt<FoodLogHistoryService>();
    calorieStatsService = _getIt<CalorieStatsService>();
    firestore = _getIt<FirebaseFirestore>();
  }

  @override
  Future<String> getPetMood(String userId) async {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final isLogToday =
        await foodLogHistoryService.getFoodLogsByDate(userId, today);

    if (isLogToday.isNotEmpty) {
      return 'happy';
    } else {
      return 'sad';
    }
  }

  @override
  Future<int> getPetHeart(String userId) async {
    final stats =
        await calorieStatsService.calculateStatsForDate(userId, DateTime.now());

    final targetCalories =
        await firestore.collection('caloric_requirements').doc(userId).get();

    final percentage = stats.caloriesConsumed / targetCalories.data()!['tdee'];

    if (percentage > 0.75) {
      return 4;
    } else if (percentage > 0.5) {
      return 3;
    } else if (percentage > 0.25) {
      return 2;
    } else if (percentage > 0) {
      return 1;
    } else {
      return 0;
    }
  }

  @override
  Future<bool> getIsPetCalorieOverTarget(String userId) async {
    try {
      // Validate input
      if (userId.isEmpty) {
        throw ArgumentError('userId cannot be empty');
      }

      // Get calories consumed
      final stats = await calorieStatsService.calculateStatsForDate(
          userId, DateTime.now());
      final caloriesConsumed = stats.caloriesConsumed;

      // Get caloric requirement
      final caloricRequirementDoc =
          await firestore.collection('caloric_requirements').doc(userId).get();

      // Check if document exists
      if (!caloricRequirementDoc.exists) {
        throw Exception('Caloric requirements not found for user $userId');
      }

      // Get data with null safety
      final data = caloricRequirementDoc.data();
      if (data == null || !data.containsKey('tdee')) {
        throw Exception('TDEE value not found in caloric requirements');
      }

      final targetCalories = data['tdee'] as num;

      return (caloriesConsumed - targetCalories) > 0;
    } catch (e) {
      // Log the error (you may want to add proper logging)
      debugPrint('Error in getIsPetCalorieOverTarget: $e');

      // Return a default value for graceful degradation
      // Assuming false (not over target) is the safe default
      return false;
    }
  }

  @override
  Future<PetInformation> getPetInformation(String userId) async {
    final isCalorieOverTarget = await getIsPetCalorieOverTarget(userId);
    final heart = await getPetHeart(userId);
    var mood = await getPetMood(userId);
    if (isCalorieOverTarget) {
      mood = 'sad';
    }
    return PetInformation(
      isCalorieOverTarget: isCalorieOverTarget,
      heart: heart,
      mood: mood,
    );
  }
}
