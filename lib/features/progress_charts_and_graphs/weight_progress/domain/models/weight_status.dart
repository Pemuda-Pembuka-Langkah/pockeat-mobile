class WeightStatus {
  final double currentWeight;
  final double weightLoss;
  final double progressToGoal;
  final double exerciseContribution;
  final double dietContribution;
  final double bmiValue;
  final String bmiCategory;

  WeightStatus({
    required this.currentWeight,
    required this.weightLoss,
    required this.progressToGoal,
    required this.exerciseContribution,
    required this.dietContribution,
    required this.bmiValue,
    required this.bmiCategory,
  });
}
