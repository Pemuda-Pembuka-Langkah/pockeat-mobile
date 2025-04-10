import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';

// coverage:ignore-start
abstract class NutritionRepository {
  Future<List<CalorieData>> getCalorieData(bool isWeeklyView);
  Future<List<NutritionStat>> getNutrientStats();
  Future<List<MacroNutrient>> getMacroNutrients();
  Future<List<MicroNutrient>> getMicroNutrients();
  Future<List<Meal>> getMeals();
  Future<String?> getUserId();
}
// coverage:ignore-end