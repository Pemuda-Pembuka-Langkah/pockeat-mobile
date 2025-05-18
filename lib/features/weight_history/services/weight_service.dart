// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Firebase imports:

// coverage:ignore-start
/// Service untuk menangani operasi terkait berat badan pengguna
class WeightService {
  /// Update berat badan untuk hari ini dan menyimpan ke history
  Future<void> updateTodayWeight(String userId, double weight) async {
    try {
      // Format tanggal hari ini
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 1. Cari dokumen health_metrics yang terkait dengan pengguna
      DocumentSnapshot? healthMetricsDoc;

      // Coba ambil dengan ID langsung dahulu
      final directDoc = await FirebaseFirestore.instance
          .collection('health_metrics')
          .doc(userId)
          .get();

      if (directDoc.exists) {
        healthMetricsDoc = directDoc;
      } else {
        // Jika tidak ada, coba dengan query userId
        final healthMetricsQuery = await FirebaseFirestore.instance
            .collection('health_metrics')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (healthMetricsQuery.docs.isEmpty) {
          throw Exception('No health metrics found for this user');
        }

        healthMetricsDoc = healthMetricsQuery.docs.first;
      }

      final healthMetricsId = healthMetricsDoc.id;

      // 2. Update dokumen utama health_metrics dengan berat badan terbaru
      await FirebaseFirestore.instance
          .collection('health_metrics')
          .doc(healthMetricsId)
          .update({
        'weight': weight,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Update atau buat riwayat berat badan di subcollection weight_history
      await FirebaseFirestore.instance
          .collection('health_metrics')
          .doc(healthMetricsId)
          .collection('weight_history')
          .doc(today)
          .set({
        'weight': weight,
        'date': today,
        'updatedAt': FieldValue.serverTimestamp(),
        // Jika dokumen baru dibuat, tambahkan createdAt
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Hitung dan update BMI pada dokumen health_metrics
      final userDoc = healthMetricsDoc.data() as Map<String, dynamic>?;
      if (userDoc != null && userDoc.containsKey('height')) {
        final double height = userDoc['height']?.toDouble() ?? 0.0;
        if (height > 0) {
          final double bmi = weight / ((height / 100) * (height / 100));

          // Update BMI
          await FirebaseFirestore.instance
              .collection('health_metrics')
              .doc(healthMetricsId)
              .update({
            'bmi': double.parse(bmi.toStringAsFixed(2)),
          });
        }
      }

      debugPrint('Successfully updated weight to $weight kg for user $userId');
    } catch (e) {
      debugPrint('Error updating weight: $e');
      rethrow; // Re-throw untuk penanganan error di UI
    }
  }

  /// Mengambil berat badan terbaru dari dokumen health_metrics
  Future<double> getLatestWeight(String userId) async {
    try {
      // Cari dokumen health_metrics yang terkait dengan pengguna
      final snapshot = await FirebaseFirestore.instance
          .collection('health_metrics')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No health metrics found for user');
      }

      final healthMetricsDoc = snapshot.docs.first;
      final weight = healthMetricsDoc.data()['weight'] as double? ?? 0.0;

      return weight;
    } catch (e) {
      debugPrint('Error getting latest weight: $e');
      rethrow;
    }
  }
}
// coverage:ignore-end
