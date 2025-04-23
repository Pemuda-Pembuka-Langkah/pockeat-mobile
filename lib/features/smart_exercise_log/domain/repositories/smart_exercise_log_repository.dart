// Exception for errors during saving or retrieving data
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

abstract class SmartExerciseLogRepository {
  /// Saves exercise analysis results to the database
  ///
  /// Returns a [String] ID of the saved result
  /// Throws [Exception] if an error occurs during saving
  Future<String> saveAnalysisResult(ExerciseAnalysisResult result);

  /// Retrieves analysis results by ID
  ///
  /// Returns [ExerciseAnalysisResult] if found, null if not exists
  /// Throws [Exception] if an error occurs during data retrieval
  Future<ExerciseAnalysisResult?> getAnalysisResultFromId(String id);

  /// Retrieves all analysis results
  ///
  /// Parameter [limit] to restrict the number of returned results, null means no restriction
  /// Returns [List<ExerciseAnalysisResult>] containing all analysis results
  /// Throws [Exception] if an error occurs during data retrieval
  Future<List<ExerciseAnalysisResult>> getAllAnalysisResults({int? limit});

  /// Retrieves analysis results by date
  ///
  /// Parameter [date] to filter results by a specific date
  /// Parameter [limit] to restrict the number of returned results, null means no restriction
  /// Returns [List<ExerciseAnalysisResult>] containing analysis results on the specified date
  /// Throws [Exception] if an error occurs during data retrieval
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByDate(DateTime date,
      {int? limit});

  /// Retrieves analysis results by month and year
  ///
  /// Parameters [month] (1-12) and [year] to filter results
  /// Parameter [limit] to restrict the number of returned results, null means no restriction
  /// Returns [List<ExerciseAnalysisResult>] containing analysis results on the specified month and year
  /// Throws [Exception] if an error occurs during data retrieval
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByMonth(
      int month, int year,
      {int? limit});

  /// Retrieves analysis results by year
  ///
  /// Parameter [year] to filter results
  /// Parameter [limit] to restrict the number of returned results, null means no restriction
  /// Returns [List<ExerciseAnalysisResult>] containing analysis results on the specified year
  /// Throws [Exception] if an error occurs during data retrieval
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByYear(int year,
      {int? limit});

  /// Deletes an analysis result by its ID
  ///
  /// Parameter [id] the unique identifier of the analysis result to delete
  /// Returns [bool] true if successfully deleted, false if the document doesn't exist
  /// Throws [Exception] if an error occurs during deletion
  Future<bool> deleteById(String id);

  /// Retrieves all analysis results for a specific user
  ///
  /// Parameter [userId] to filter results by user ID
  /// Parameter [limit] to restrict the number of returned results, null means no restriction
  /// Returns [List<ExerciseAnalysisResult>] containing analysis results for the specified user
  /// Throws [Exception] if an error occurs during data retrieval
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByUser(String userId,
      {int? limit});

  /// Retrieves analysis results by date for a specific user
  ///
  /// Parameter [userId] to filter results by user ID
  /// Parameter [date] to filter results by a specific date
  /// Parameter [limit] to restrict the number of returned results, null means no restriction
  /// Returns [List<ExerciseAnalysisResult>] containing analysis results for the specified user on the specified date
  /// Throws [Exception] if an error occurs during data retrieval
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByUserAndDate(
      String userId, DateTime date,
      {int? limit});

  /// Retrieves analysis results by month and year for a specific user
  ///
  /// Parameter [userId] to filter results by user ID
  /// Parameters [month] (1-12) and [year] to filter results
  /// Parameter [limit] to restrict the number of returned results, null means no restriction
  /// Returns [List<ExerciseAnalysisResult>] containing analysis results for the specified user on the specified month and year
  /// Throws [Exception] if an error occurs during data retrieval
  Future<List<ExerciseAnalysisResult>> getAnalysisResultsByUserAndMonth(
      String userId, int month, int year,
      {int? limit});
}
