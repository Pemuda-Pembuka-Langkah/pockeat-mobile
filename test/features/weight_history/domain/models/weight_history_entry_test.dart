// lib/features/weights_history/domain/models/weight_history_entry_test.dart

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// Project imports:
import 'package:pockeat/features/weight_history/domain/models/weight_history_entry.dart';

void main() {
  group('WeightHistoryEntry', () {
    test('toMap() should correctly convert WeightHistoryEntry to Map', () {
      // Arrange
      final entry = WeightHistoryEntry(
        weight: 70.5,
        timestamp: DateTime(2025, 4, 26, 22, 30),
      );

      // Act
      final map = entry.toMap();

      // Assert
      expect(map['weight'], 70.5);
      expect(map['timestamp'], isA<DateTime>());
      expect((map['timestamp'] as DateTime).year, 2025);
      expect((map['timestamp'] as DateTime).month, 4);
      expect((map['timestamp'] as DateTime).day, 26);
    });

    test('fromMap() should correctly create WeightHistoryEntry from Map', () {
      // Arrange
      final now = Timestamp.fromDate(DateTime(2025, 4, 26, 22, 30));
      final map = {
        'weight': 70.5,
        'timestamp': now,
      };

      // Act
      final entry = WeightHistoryEntry.fromMap(map);

      // Assert
      expect(entry.weight, 70.5);
      expect(entry.timestamp, now.toDate());
    });
  });
}