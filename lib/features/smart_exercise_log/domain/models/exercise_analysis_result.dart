import 'package:uuid/uuid.dart';

class ExerciseAnalysisResult {
  final String id;
  final String exerciseType;
  final String duration;
  final String intensity;
  final num estimatedCalories;
  final double metValue;
  final String? summary;
  final DateTime timestamp;
  final String originalInput;
  final List<String>? missingInfo;
  final String userId; // Added userId field

  ExerciseAnalysisResult({
    String? id,
    required this.exerciseType,
    required this.duration,
    required this.intensity,
    required this.estimatedCalories,
    this.metValue = 0.0,
    this.summary,
    required this.timestamp,
    required this.originalInput,
    this.missingInfo,
    required this.userId, // Required userId parameter
  }) : id = id ?? const Uuid().v4();

  bool get isComplete => missingInfo == null || missingInfo!.isEmpty;

  // Factory dari Map (untuk parsing response dari database)
  factory ExerciseAnalysisResult.fromDbMap(
      Map<String, dynamic> map, String id) {
    return ExerciseAnalysisResult(
      id: id,
      exerciseType: map['exerciseType'] ?? 'Unknown',
      duration: map['duration'] ?? 'Tidak ditentukan',
      intensity: map['intensity'] ?? 'Tidak ditentukan',
      estimatedCalories: map['estimatedCalories'] ?? 0,
      metValue: (map['metValue'] ?? 0.0).toDouble(),
      summary: map['summary'],
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      originalInput: map['originalInput'] ?? '',
      missingInfo: map['missingInfo'] != null
          ? List<String>.from(map['missingInfo'])
          : null,
      userId: map['userId'] ?? '', // Parse userId from database
    );
  }

  // Konversi ke Map (untuk penyimpanan)
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
      'isComplete': isComplete,
      'userId': userId, // Add userId to map
    };
  }

  // Copy with method untuk memudahkan update
  ExerciseAnalysisResult copyWith({
    String? id,
    String? exerciseType,
    String? duration,
    String? intensity,
    num? estimatedCalories,
    double? metValue,
    String? summary,
    DateTime? timestamp,
    String? originalInput,
    List<String>? missingInfo,
    String? userId, // Added userId parameter
  }) {
    return ExerciseAnalysisResult(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      metValue: metValue ?? this.metValue,
      summary: summary ?? this.summary,
      timestamp: timestamp ?? this.timestamp,
      originalInput: originalInput ?? this.originalInput,
      missingInfo: missingInfo ?? this.missingInfo,
      userId: userId ?? this.userId, // Maintain userId when copying
    );
  }

  static Future<ExerciseAnalysisResult> fromJson(jsonDecode) async {
    if (jsonDecode == null) {
      throw ArgumentError('jsonDecode cannot be null');
    }
    return ExerciseAnalysisResult.fromDbMap(jsonDecode, const Uuid().v4());
  }
}