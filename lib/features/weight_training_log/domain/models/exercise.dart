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
}

class ExerciseSet {
  final double weight;
  final int reps;
  final double duration;

  ExerciseSet({
    required this.weight,
    required this.reps,
    required this.duration,
  });
}