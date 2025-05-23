// Package imports:
//coverage: ignore-file

// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:pockeat/features/api_scan/models/food_analysis.dart';

/// Model untuk item history log makanan
///
/// Model ini didesain untuk menyatukan berbagai jenis log makanan
/// dalam satu format yang konsisten untuk ditampilkan di history log.
class FoodLogHistoryItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final num calories;
  final String?
      sourceId; // ID dari data sumber (misalnya ID dari FoodAnalysisResult)
  final String? imageUrl; // URL gambar makanan jika ada
  final num? protein;
  final num? carbs;
  final num? fat;

  final double? healthScore;

  FoodLogHistoryItem(
      {String? id,
      required this.title,
      required this.subtitle,
      required this.timestamp,
      required this.calories,
      this.sourceId,
      this.imageUrl,
      this.protein,
      this.carbs,
      this.fat,
      this.healthScore})
      : id = id ?? const Uuid().v4();

  /// Mendapatkan string representasi waktu yang user-friendly (contoh: "1d ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Factory constructor untuk membuat FoodLogHistoryItem dari FoodAnalysisResult
  factory FoodLogHistoryItem.fromFoodAnalysisResult(
      FoodAnalysisResult foodAnalysisResult) {
    // Format subtitle dengan informasi nutrisi penting
    final calories = foodAnalysisResult.nutritionInfo.calories.toInt();
    final protein = foodAnalysisResult.nutritionInfo.protein.toInt();
    final carbs = foodAnalysisResult.nutritionInfo.carbs.toInt();
    final fat = foodAnalysisResult.nutritionInfo.fat.toInt();

    return FoodLogHistoryItem(
      id: foodAnalysisResult.id,
      title: foodAnalysisResult.foodName,
      subtitle: '${protein}g protein • ${carbs}g carbs',
      timestamp: foodAnalysisResult.timestamp,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      sourceId: foodAnalysisResult.id, // Use id if available, otherwise use URL
      imageUrl: foodAnalysisResult.foodImageUrl,
      healthScore:
          foodAnalysisResult.healthScore, // Pass the health score if provided
    );
  }

  /// Mengkonversi objek ke Map untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'calories': calories,
      'sourceId': sourceId,
      'imageUrl': imageUrl,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  /// Membuat objek dari Map
  factory FoodLogHistoryItem.fromJson(Map<String, dynamic> json) {
    return FoodLogHistoryItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      calories: json['calories'],
      sourceId: json['sourceId'],
      imageUrl: json['imageUrl'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
    );
  }
}
