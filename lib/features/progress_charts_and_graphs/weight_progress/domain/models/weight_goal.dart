class WeightGoal {
  final String startingWeight;
  final String startingDate;
  final String targetWeight;
  final String targetDate;
  final String remainingWeight;
  final String daysLeft;
  final bool isOnTrack;
  final String insightMessage;

  WeightGoal({
    required this.startingWeight,
    required this.startingDate,
    required this.targetWeight,
    required this.targetDate,
    required this.remainingWeight,
    required this.daysLeft,
    required this.isOnTrack,
    required this.insightMessage,
  });
}
