// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class WeightHistoryEntry {
  final double weight;
  final DateTime timestamp;

  WeightHistoryEntry({
    required this.weight,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'timestamp': timestamp,
    };
  }

  factory WeightHistoryEntry.fromMap(Map<String, dynamic> map) {
    return WeightHistoryEntry(
      weight: (map['weight'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
