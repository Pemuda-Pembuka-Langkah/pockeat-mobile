// Package imports:
import 'package:uuid/uuid.dart';

class WeightLifting {
  final String id;
  final String name;
  final String bodyPart;
  final double metValue;
  final DateTime timestamp;
  final String userId;
  List<WeightLiftingSet> sets;

  WeightLifting({
    String? id,
    required this.name,
    required this.bodyPart,
    required this.metValue,
    List<WeightLiftingSet>? sets,
    DateTime? timestamp,
    required this.userId,
  })  : id = id ?? const Uuid().v4(),
        sets = sets ?? [],
        timestamp = timestamp ?? DateTime.now();

  // Convert Exercise object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'metValue': metValue,
      'sets': sets.map((set) => set.toJson()).toList(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Create Exercise object from JSON
  factory WeightLifting.fromJson(Map<String, dynamic> json) {
    // Safe conversion for metValue
    final metValue = json['metValue'] is int
        ? (json['metValue'] as int).toDouble()
        : double.parse(json['metValue'].toString());

    return WeightLifting(
      id: json['id'],
      name: json['name'],
      bodyPart: json['bodyPart'],
      metValue: metValue,
      sets: json['sets'] != null
          ? List<WeightLiftingSet>.from(
              json['sets'].map((x) => WeightLiftingSet.fromJson(x)))
          : [],
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
      userId: json['userId'] ?? '',
    );
  }
}

class WeightLiftingSet {
  final double weight;
  final int reps;
  final double duration;

  WeightLiftingSet({
    required this.weight,
    required this.reps,
    required this.duration,
  })  : assert(weight > 0, 'Weight must be greater than 0'),
        assert(reps > 0, 'Reps must be greater than 0'),
        assert(duration > 0, 'Duration must be greater than 0');

  // Convert ExerciseSet object to JSON
  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
      'duration': duration,
    };
  }

  // Create ExerciseSet object from JSON
  factory WeightLiftingSet.fromJson(Map<String, dynamic> json) {
    if (json['weight'] == null ||
        json['reps'] == null ||
        json['duration'] == null) {
      throw ArgumentError('Missing required fields in ExerciseSet JSON');
    }

    final weight = json['weight'].toDouble();
    final reps = json['reps'];
    final duration = json['duration'].toDouble();

    if (weight <= 0 || reps <= 0 || duration <= 0) {
      throw ArgumentError('Weight, reps, and duration must be greater than 0');
    }

    return WeightLiftingSet(
      weight: weight,
      reps: reps,
      duration: duration,
    );
  }
}
