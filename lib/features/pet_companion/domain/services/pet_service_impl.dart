// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

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
    try {
      // Validate input
      if (userId.isEmpty) {
        throw ArgumentError('userId cannot be empty');
      }

      final stats = await calorieStatsService.calculateStatsForDate(
          userId, DateTime.now());

      final targetCaloriesDoc =
          await firestore.collection('caloric_requirements').doc(userId).get();

      // Check if document exists
      if (!targetCaloriesDoc.exists) {
        throw Exception('Caloric requirements not found for user $userId');
      }

      // Get data with null safety
      final data = targetCaloriesDoc.data();
      if (data == null || !data.containsKey('tdee')) {
        throw Exception('TDEE value not found in caloric requirements');
      }

      final tdee = data['tdee'] as num;

      // Avoid division by zero
      if (tdee <= 0) {
        throw Exception('TDEE must be greater than zero');
      }

      final percentage = stats.caloriesConsumed / tdee;

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
    } catch (e) {
      // Log error
      debugPrint('Error in getPetHeart: $e');

      // Return a default value for graceful degradation
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
    final caloricRequirementDoc =
        await firestore.collection('caloric_requirements').doc(userId).get();

    final stats =
        await calorieStatsService.calculateStatsForDate(userId, DateTime.now());

    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final isLogToday =
        await foodLogHistoryService.getFoodLogsByDate(userId, today);

    final data = caloricRequirementDoc.data();

    final tdee = data?['tdee'] as num;

    final caloriesConsumed = stats.caloriesConsumed;

    final percentage = caloriesConsumed / tdee;

    final isCalorieOverTarget = percentage > 1;

    var heart = 0;
    var mood = '';

    if (percentage > 0.75) {
      heart = 4;
    } else if (percentage > 0.5) {
      heart = 3;
    } else if (percentage > 0.25) {
      heart = 2;
    } else if (percentage > 0) {
      heart = 1;
    } else {
      heart = 0;
    }

    if (isLogToday.isNotEmpty) {
      mood = 'happy';
    } else {
      mood = 'sad';
    }

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
