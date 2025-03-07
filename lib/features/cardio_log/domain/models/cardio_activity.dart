import 'package:uuid/uuid.dart';

/// Enum untuk tipe aktivitas kardio
enum CardioType { 
  running, 
  cycling, 
  swimming 
}

/// Model dasar untuk semua aktivitas kardio
abstract class CardioActivity {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double caloriesBurned;
  final CardioType type;

  CardioActivity({
    String? id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.caloriesBurned,
    required this.type,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.duration = endTime.difference(startTime);

  /// Metode untuk konversi ke Map (untuk penyimpanan)
  Map<String, dynamic> toMap();

  /// Metode untuk menghitung kalori yang terbakar
  double calculateCalories();
} 