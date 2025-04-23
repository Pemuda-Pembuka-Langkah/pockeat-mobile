import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weight_lifting.dart';
import 'weight_lifting_repository.dart';

/// Implementasi ExerciseRepository menggunakan Firebase Firestore
class WeightLiftingRepositoryImpl implements WeightLiftingRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'weight_lifting_logs';

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

  WeightLiftingRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<String> saveExercise(WeightLifting exercise) async {
    try {
      if (exercise.userId.isEmpty) {
        throw Exception('Exercise must have a user ID');
      }

      final docRef = _firestore.collection(_collection).doc(exercise.id);
      await docRef.set(exercise.toJson());
      return exercise.id;
    } catch (e) {
      throw Exception('Failed to save exercise: $e');
    }
  }

  @override
  Future<WeightLifting?> getExerciseById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(id).get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      return WeightLifting.fromJson(data);
    } catch (e) {
      throw Exception('Failed to retrieve exercise: $e');
    }
  }

  @override
  Future<List<WeightLifting>> getAllExercises() async {
    try {
      final querySnapshot =
          await _firestore.collection(_collection).orderBy('name').get();

      return querySnapshot.docs
          .map((doc) => WeightLifting.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve exercises: $e');
    }
  }

  @override
  Future<List<WeightLifting>> getExercisesByBodyPart(String bodyPart) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('bodyPart', isEqualTo: bodyPart)
          .get();

      return querySnapshot.docs
          .map((doc) => WeightLifting.fromJson(doc.data()))
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
  Future<List<WeightLifting>> filterByDate(DateTime date) async {
    try {
      // Create start and end timestamps for the given date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay =
          DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('timestamp',
              isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('timestamp',
              isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
          .get();

      return querySnapshot.docs
          .map((doc) => WeightLifting.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter exercises by date: $e');
    }
  }

  @override
  Future<List<WeightLifting>> filterByMonth(int month, int year) async {
    // Validasi bulan - dipindahkan ke luar dari try-catch
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }

    try {
      // Create start and end timestamps for the given month
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = month < 12
          ? DateTime(year, month + 1, 1)
              .subtract(const Duration(milliseconds: 1))
          : DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('timestamp',
              isGreaterThanOrEqualTo: startOfMonth.millisecondsSinceEpoch)
          .where('timestamp',
              isLessThanOrEqualTo: endOfMonth.millisecondsSinceEpoch)
          .get();

      return querySnapshot.docs
          .map((doc) => WeightLifting.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter exercises by month: $e');
    }
  }

  @override
  Future<List<WeightLifting>> filterByYear(int year) async {
    // Validate year
    if (year <= 0) {
      throw ArgumentError('Year must be a positive number');
    }

    try {
      // Create start and end timestamps for the given year
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear =
          DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('timestamp',
              isGreaterThanOrEqualTo: startOfYear.millisecondsSinceEpoch)
          .where('timestamp',
              isLessThanOrEqualTo: endOfYear.millisecondsSinceEpoch)
          .get();

      return querySnapshot.docs
          .map((doc) => WeightLifting.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter exercises by year: $e');
    }
  }

  @override
  Future<List<WeightLifting>> getExercisesWithLimit(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => WeightLifting.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve exercises with limit: $e');
    }
  }

// coverage:ignore-start
  @override
  Future<List<WeightLifting>> getExercisesByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => WeightLifting.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve user exercises: $e');
    }
  }
// coverage:ignore-end

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
      return exercisesByCategory[category]?[exerciseName] ??
          3.0; // Default MET value if not found
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
