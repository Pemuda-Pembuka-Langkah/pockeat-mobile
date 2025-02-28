import 'package:uuid/uuid.dart';

class AnalysisResult {
  final String id;
  final String exerciseType;
  final String duration;
  final String intensity;
  final int estimatedCalories;
  final String? summary;
  final DateTime timestamp;
  final String originalInput;
  final List<String>? missingInfo;

  AnalysisResult({
    String? id,
    required this.exerciseType,
    required this.duration,
    required this.intensity,
    required this.estimatedCalories,
    this.summary,
    required this.timestamp,
    required this.originalInput,
    this.missingInfo,
  }) : id = id ?? const Uuid().v4();

  bool get isComplete => missingInfo == null || missingInfo!.isEmpty;

  // Factory dari Map (untuk parsing response dari API)
  factory AnalysisResult.fromMap(Map<String, dynamic> map, String originalInput, {String? id}) {
    return AnalysisResult(
      id: id,
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

  // Factory dari Map (untuk parsing response dari database)
  factory AnalysisResult.fromDbMap(Map<String, dynamic> map, String id) {
    return AnalysisResult(
      id: id,
      exerciseType: map['exerciseType'] ?? 'Unknown',
      duration: map['duration'] ?? 'Tidak ditentukan',
      intensity: map['intensity'] ?? 'Tidak ditentukan',
      estimatedCalories: map['estimatedCalories'] ?? 0,
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

  // Copy with method untuk memudahkan update
  AnalysisResult copyWith({
    String? id,
    String? exerciseType,
    String? duration,
    String? intensity,
    int? estimatedCalories,
    String? summary,
    DateTime? timestamp,
    String? originalInput,
    List<String>? missingInfo,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      summary: summary ?? this.summary,
      timestamp: timestamp ?? this.timestamp,
      originalInput: originalInput ?? this.originalInput,
      missingInfo: missingInfo ?? this.missingInfo,
    );
  }
}