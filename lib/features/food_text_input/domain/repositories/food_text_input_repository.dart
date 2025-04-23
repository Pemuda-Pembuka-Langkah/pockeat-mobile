// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';
import 'package:pockeat/firebase/firebase_repository.dart';

/// Repository for managing food text input analysis results
///
/// Provides methods to save, retrieve, and filter food analysis data
class FoodTextInputRepository
    extends BaseFirestoreRepository<FoodAnalysisResult> {
  static const String _timestampField = 'timestamp';

  FoodTextInputRepository({super.firestore})
      : super(
          collectionName: 'food_analysis',
          toMap: (item) => item.toJson(),
          fromMap: (map, id) => FoodAnalysisResult.fromJson(map),
        );

  /// Get all food text input analysis results with optional limit and ordering
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

  /// Get food analysis results for a specific date
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

  /// Get food analysis results for a specific month and year
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

  /// Get food analysis results for a specific year
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

  /// Delete a food analysis result by ID
  ///
  /// Parameter [id] the ID of the food analysis result to delete
  /// Returns true if deletion was successful, false if the item wasn't found
  @override
  Future<bool> deleteById(String id) async {
    return super.deleteById(id);
  }
}
