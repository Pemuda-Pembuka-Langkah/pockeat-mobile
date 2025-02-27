import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/analysis_result.dart';
import 'package:pockeat/features/smart_exercise_log/domain/repositories/smart_exercise_log_repository.dart';

class SmartExerciseLogRepositoryImpl implements SmartExerciseLogRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'exerciseAnalysis';
  
  SmartExerciseLogRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<String> saveAnalysisResult(AnalysisResult result) async {
    try {
      final docRef = _firestore.collection(_collection).doc(result.id);
      await docRef.set(result.toMap());
      return result.id;
    } catch (e) {
      throw Exception('Failed to save analysis result: $e');
    }
  }
  
  @override
  Future<AnalysisResult?> getAnalysisResultFromId(String id) async {
    try {
      final docSnapshot = await _firestore.collection(_collection).doc(id).get();
      if (!docSnapshot.exists) return null;
      
      return AnalysisResult.fromDbMap(
        docSnapshot.data() as Map<String, dynamic>, 
        docSnapshot.id
      );
    } catch (e) {
      throw Exception('Failed to retrieve analysis result: $e');
    }
  }
  
  @override
  Future<List<AnalysisResult>> getAllAnalysisResults() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) => 
        AnalysisResult.fromDbMap(
          doc.data(), 
          doc.id
        )
      ).toList();
    } catch (e) {
      throw Exception('Failed to retrieve analysis results: $e');
    }
  }
}