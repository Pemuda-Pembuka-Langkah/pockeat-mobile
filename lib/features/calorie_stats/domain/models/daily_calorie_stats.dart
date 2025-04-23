import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DailyCalorieStats {
  final String id;
  final String userId;
  final DateTime date;
  final int caloriesBurned;
  final int caloriesConsumed;
  final int netCalories;

  DailyCalorieStats({
    String? id,
    required this.userId,
    required this.date,
    required this.caloriesBurned,
    required this.caloriesConsumed,
  })  : id = id ?? const Uuid().v4(),
        netCalories = caloriesConsumed - caloriesBurned;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'caloriesBurned': caloriesBurned,
        'caloriesConsumed': caloriesConsumed,
        'netCalories': netCalories,
      };

  factory DailyCalorieStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyCalorieStats(
      id: doc.id,
      userId: data['userId'],
      date: (data['date'] as Timestamp).toDate(),
      caloriesBurned: data['caloriesBurned'],
      caloriesConsumed: data['caloriesConsumed'],
    );
  }
}
