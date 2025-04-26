// coverage:ignore-start
class ExerciseData {
  final dynamic date; // Can be String or DateTime
  final double value;

  ExerciseData(this.date, this.value);

  // Helper to get formatted label based on date
  String get label {
    if (date is String) {
      return date as String;
    } else if (date is DateTime) {
      // Format the DateTime to appropriate string
      final dt = date as DateTime;
      return '${dt.day}/${dt.month}';
    }
    return date.toString();
  }
}
// coverage:ignore-end
