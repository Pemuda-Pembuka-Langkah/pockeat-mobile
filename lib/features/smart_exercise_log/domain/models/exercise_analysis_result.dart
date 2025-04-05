import 'package:uuid/uuid.dart';

class ExerciseAnalysisResult {
  final String id;
  final String exerciseType;
  final String duration;
  final String intensity;
  final num estimatedCalories;
  final double metValue; // Field MET baru
  final String? summary;
  final DateTime timestamp;
  final String originalInput;
  final List<String>? missingInfo;

  ExerciseAnalysisResult({
    String? id,
    required this.exerciseType,
    required this.duration,
    required this.intensity,
    required this.estimatedCalories,
    this.metValue = 0.0, // Default value untuk MET
    this.summary,
    required this.timestamp,
    required this.originalInput,
    this.missingInfo,
  }) : id = id ?? const Uuid().v4();

  bool get isComplete => missingInfo == null || missingInfo!.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'exerciseType': exerciseType,
      'duration': duration,
      'intensity': intensity,
      'estimatedCalories': estimatedCalories,
      'metValue': metValue,
      'summary': summary,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'originalInput': originalInput,
      'missingInfo': missingInfo,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  // Factory dari Map (untuk parsing response dari database)
  factory ExerciseAnalysisResult.fromDbMap(
      Map<String, dynamic> map, String id) {
    return ExerciseAnalysisResult(
      id: id,
      exerciseType: map['exerciseType'] ?? 'Unknown',
      duration: map['duration'] ?? 'Tidak ditentukan',
      intensity: map['intensity'] ?? 'Tidak ditentukan',
      estimatedCalories: map['estimatedCalories'] ?? 0,
      metValue: (map['metValue'] ?? 0.0)
          .toDouble(), // Parsing MET value dari database
      summary: map['summary'],
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      originalInput: map['originalInput'] ?? '',
      missingInfo: map['missingInfo'] != null
          ? List<String>.from(map['missingInfo'])
          : null,
    );
  }

  // Copy with method untuk memudahkan update
  ExerciseAnalysisResult copyWith({
    String? id,
    String? exerciseType,
    String? duration,
    String? intensity,
    num? estimatedCalories,
    double? metValue, // Support untuk update MET value
    String? summary,
    DateTime? timestamp,
    String? originalInput,
    List<String>? missingInfo,
  }) {
    return ExerciseAnalysisResult(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      metValue: metValue ??
          this.metValue, // Mempertahankan MET value atau menggantinya
      summary: summary ?? this.summary,
      timestamp: timestamp ?? this.timestamp,
      originalInput: originalInput ?? this.originalInput,
      missingInfo: missingInfo ?? this.missingInfo,
    );
  }

  static Future<ExerciseAnalysisResult> fromJson(jsonDecode) async {
    if (jsonDecode == null) {
      throw ArgumentError('jsonDecode cannot be null');
    }
    return ExerciseAnalysisResult.fromDbMap(jsonDecode, const Uuid().v4());
  }
}
