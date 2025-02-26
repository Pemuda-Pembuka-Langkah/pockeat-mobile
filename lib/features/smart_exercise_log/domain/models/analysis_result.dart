class AnalysisResult {
  final String exerciseType;
  final String duration;
  final String intensity;
  final int estimatedCalories;
  final String? summary;
  final DateTime timestamp;
  final String originalInput;
  final List<String>? missingInfo;

  AnalysisResult({
    required this.exerciseType,
    required this.duration,
    required this.intensity,
    required this.estimatedCalories,
    this.summary,
    required this.timestamp,
    required this.originalInput,
    this.missingInfo,
  });

  bool get isComplete => missingInfo == null || missingInfo!.isEmpty;

  // Factory dari Map (untuk parsing response)
  factory AnalysisResult.fromMap(Map<String, dynamic> map, String originalInput) {
    return AnalysisResult(
      exerciseType: map['type'] ?? 'Unknown',
      duration: map['duration'] ?? 'Tidak ditentukan',
      intensity: map['intensity'] ?? 'Tidak ditentukan',
      estimatedCalories: map['estimatedCalories'] ?? 0,
      summary: map['summary'],
      timestamp: DateTime.now(),
      originalInput: originalInput,
      missingInfo: map['missingInfo'] != null 
          ? List<String>.from(map['missingInfo']) 
          : null,
    );
  }

  // Konversi ke Map (untuk penyimpanan)
  Map<String, dynamic> toMap() {
    return {
      'exerciseType': exerciseType,
      'duration': duration,
      'intensity': intensity,
      'estimatedCalories': estimatedCalories,
      'summary': summary,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'originalInput': originalInput,
      'missingInfo': missingInfo,
      'isComplete': isComplete,
    };
  }
 
}