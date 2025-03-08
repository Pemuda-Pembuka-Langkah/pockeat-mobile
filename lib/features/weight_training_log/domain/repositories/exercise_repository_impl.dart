import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';
import '../models/exercise_factory.dart';
import 'exercise_repository.dart';

/// Implementasi ExerciseRepository menggunakan Firebase Firestore
class ExerciseRepositoryImpl implements ExerciseRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'exercises';
  
  // Data statis untuk kategori latihan dan nilai MET
  static const Map<String, Map<String, double>> exercisesByCategory = {
    'Upper Body': {
      'Bench Press': 5.0,
      'Shoulder Press': 5.0,
      'Bicep Curls': 3.5,
      'Tricep Extensions': 3.5,
      'Pull Ups': 8.0,
      'Push Ups': 3.8,
      'Lateral Raises': 4.0,
    },
    'Lower Body': {
      'Squats': 6.0,
      'Deadlifts': 7.0,
      'Leg Press': 5.0,
      'Lunges': 5.0,
      'Calf Raises': 3.0,
      'Leg Extensions': 4.0,
      'Hamstring Curls': 4.0,
    },
    'Core': {
      'Crunches': 3.0,
      'Planks': 2.8,
      'Russian Twists': 4.0,
      'Leg Raises': 3.5,
      'Ab Rollouts': 5.0,
      'Side Planks': 2.5,
    },
    'Full Body': {
      'Clean and Press': 8.0,
      'Burpees': 8.0,
      'Turkish Get-ups': 6.0,
      'Thrusters': 8.0,
      'Mountain Climbers': 8.0,
    },
  };
  
  ExerciseRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;
  
  @override
  Future<String> saveExercise(Exercise exercise) async {
    try {
      final docRef = _firestore.collection(_collection).doc(exercise.id);
      await docRef.set(exercise.toJson());
      return exercise.id;
    } catch (e) {
      throw Exception('Failed to save exercise: $e');
    }
  }
  
  @override
  Future<Exercise?> getExerciseById(String id) async {
    try {
      final docSnapshot = await _firestore.collection(_collection).doc(id).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      return Exercise.fromJson(data);
    } catch (e) {
      throw Exception('Failed to retrieve exercise: $e');
    }
  }
  
  @override
  Future<List<Exercise>> getAllExercises() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve exercises: $e');
    }
  }
  
  @override
  Future<List<Exercise>> getExercisesByBodyPart(String bodyPart) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('bodyPart', isEqualTo: bodyPart)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve exercises by body part: $e');
    }
  }
  
  @override
  Future<bool> deleteExercise(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete exercise: $e');
    }
  }
  
  @override
  Future<List<Exercise>> filterByDate(DateTime date) async {
    try {
      // Extract date string to use as a filter
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('dateCreated', isEqualTo: dateString)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter exercises by date: $e');
    }
  }
  
  @override
  Future<List<Exercise>> filterByMonth(int month, int year) async {
    // Validasi bulan - dipindahkan ke luar dari try-catch
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
    
    try {
      // Create month prefix for string comparison
      final monthPrefix = "$year-${month.toString().padLeft(2, '0')}";
      
      // Need to get all exercises and filter manually since Firestore doesn't support
      // direct substring matching in where clauses
      final querySnapshot = await _firestore.collection(_collection).get();
      
      final filteredDocs = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final dateStr = data['dateCreated'] as String?;
        return dateStr != null && dateStr.startsWith(monthPrefix);
      }).toList();
      
      return filteredDocs.map((doc) => Exercise.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to filter exercises by month: $e');
    }
  }
  
  @override
  Future<List<Exercise>> getExercisesWithLimit(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve exercises with limit: $e');
    }
  }
  
  @override
  List<String> getExerciseCategories() {
    return exercisesByCategory.keys.toList();
  }
  
  @override
  Map<String, double> getExercisesByCategoryName(String category) {
    return exercisesByCategory[category] ?? {};
  }
  
  @override
  double getExerciseMETValue(String exerciseName, [String? category]) {
    if (category != null && exercisesByCategory.containsKey(category)) {
      return exercisesByCategory[category]?[exerciseName] ?? 3.0; // Default MET value if not found
    }
    
    // Search in all categories if category not specified
    for (final categoryMap in exercisesByCategory.values) {
      if (categoryMap.containsKey(exerciseName)) {
        return categoryMap[exerciseName] ?? 3.0;
      }
    }
    
    return 3.0; // Default MET value if exercise not found
  }
}