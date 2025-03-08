class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final double metValue;
  List<ExerciseSet> sets;

  Exercise({
    String? id,
    required this.name,
    required this.bodyPart,
    required this.metValue,
    List<ExerciseSet>? sets,
  })  : id = id ?? DateTime.now().toString(),
        sets = sets ?? [];

  // Convert Exercise object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'metValue': metValue,
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }

  // Create Exercise object from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      bodyPart: json['bodyPart'],
      metValue: json['metValue'],
      sets: json['sets'] != null
          ? List<ExerciseSet>.from(
              json['sets'].map((x) => ExerciseSet.fromJson(x)))
          : [],
    );
  }
}

class ExerciseSet {
  final double weight;
  final int reps;
  final double duration;

  ExerciseSet({
    required this.weight,
    required this.reps,
    required this.duration,
  }) : assert(weight > 0, 'Weight must be greater than 0'),
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
  factory ExerciseSet.fromJson(Map<String, dynamic> json) {

    if (json['weight'] == null || json['reps'] == null || json['duration'] == null) {
      throw ArgumentError('Missing required fields in ExerciseSet JSON');
    }

    final weight = json['weight'].toDouble();
    final reps = json['reps'];
    final duration = json['duration'].toDouble();

    if (weight <= 0 || reps <= 0 || duration <= 0) {
      throw ArgumentError('Weight, reps, and duration must be greater than 0');
    }

    return ExerciseSet(
      weight: weight,
      reps: reps,
      duration: duration,
    );
  }
}