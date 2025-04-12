class CaloricRequirementModel {
  final double bmr;
  final double tdee;

  CaloricRequirementModel({
    required this.bmr,
    required this.tdee,
  });

  Map<String, dynamic> toMap() {
    return {
      'bmr': bmr,
      'tdee': tdee,
    };
  }

  factory CaloricRequirementModel.fromMap(Map<String, dynamic> map) {
    return CaloricRequirementModel(
      bmr: (map['bmr'] as num).toDouble(),
      tdee: (map['tdee'] as num).toDouble(),
    );
  }
}