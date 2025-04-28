// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/firebase/firebase_repository.dart';

//coverage: ignore-file

/// Repository for managing nutrition database meal entries
///
/// Provides methods to save, retrieve, and delete meal data in Firebase
class NutritionDatabaseRepository
    extends BaseFirestoreRepository<FoodAnalysisResult> {
  static const String _timestampField = 'timestamp';

  NutritionDatabaseRepository({super.firestore})
      : super(
          collectionName: 'food_analysis',
          toMap: (item) => item.toJson(),
          fromMap: (map, id) => FoodAnalysisResult.fromJson({
            ...map,
            'id': 'meal_$id', // Add meal_ prefix for internal identification
            'additional_information': {
              ...(map['additional_information'] as Map<String, dynamic>? ?? {}),
              'is_meal': true,
              'meal_id': id,
              'saved_to_firebase': true,
            },
          }),
        );

  /// Get all nutrition database items with optional limit and ordering
  ///
  /// Returns a list of food analysis results ordered by timestamp (newest first)
  @override
  Future<List<FoodAnalysisResult>> getAll({
    String? orderBy,
    bool descending = true,
    int? limit,
  }) async {
    return super.getAll(
      orderBy: orderBy ?? _timestampField,
      descending: descending,
      limit: limit,
    );
  }

  /// Get analysis results for a specific date
  ///
  /// Parameter [date] the date to filter by
  /// Parameter [limit] optional limit on the number of results
  /// Returns a list of food analysis results for the specified date
  Future<List<FoodAnalysisResult>> getAnalysisResultsByDate(DateTime date,
      {int? limit}) async {
    return super.getByDate(
      date: date,
      timestampField: _timestampField,
      limit: limit,
      descending: true,
    );
  }

  /// Get analysis results for a specific month and year
  ///
  /// Parameter [month] the month (1-12)
  /// Parameter [year] the year
  /// Parameter [limit] optional limit on the number of results
  /// Returns a list of food analysis results for the specified month and year
  Future<List<FoodAnalysisResult>> getAnalysisResultsByMonth(
      int month, int year,
      {int? limit}) async {
    return super.getByMonth(
      month: month,
      year: year,
      timestampField: _timestampField,
      limit: limit,
      descending: true,
    );
  }

  /// Get analysis results for a specific year
  ///
  /// Parameter [year] the year
  /// Parameter [limit] optional limit on the number of results
  /// Returns a list of food analysis results for the specified year
  Future<List<FoodAnalysisResult>> getAnalysisResultsByYear(int year,
      {int? limit}) async {
    return super.getByYear(
      year: year,
      timestampField: _timestampField,
      limit: limit,
      descending: true,
    );
  }
}
