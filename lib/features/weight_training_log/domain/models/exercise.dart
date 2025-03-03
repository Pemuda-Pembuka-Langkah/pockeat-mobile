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