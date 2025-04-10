import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/nutrition_stat.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/macro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/micro_nutrient.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/models/meal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/calories_nutrition/domain/repositories/nutrition_repository.dart';

// coverage:ignore-start
class NutritionService {
  final NutritionRepository _repository;

  NutritionService(this._repository);

  Future<List<CalorieData>> getCalorieData(bool isWeeklyView) async {
    return await _repository.getCalorieData(isWeeklyView);
  }

  Future<List<NutritionStat>> getNutrientStats() async {
    return await _repository.getNutrientStats();
  }

  Future<List<MacroNutrient>> getMacroNutrients() async {
    return await _repository.getMacroNutrients();
  }

  Future<List<MicroNutrient>> getMicroNutrients() async {
    return await _repository.getMicroNutrients();
  }

  Future<List<Meal>> getMeals() async {
    return await _repository.getMeals();
  }
}
// coverage:ignore-end