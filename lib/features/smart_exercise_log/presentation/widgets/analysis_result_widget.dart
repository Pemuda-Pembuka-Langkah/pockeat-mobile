import 'package:flutter/material.dart';
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

class AnalysisResultWidget extends StatelessWidget {
  final ExerciseAnalysisResult analysisResult;
  final VoidCallback onRetry;
  final VoidCallback onSave;

  const AnalysisResultWidget({
    super.key,
    required this.analysisResult,
    required this.onRetry,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final hasMissingInfo = analysisResult.missingInfo != null &&
        analysisResult.missingInfo!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasil Analisis Olahraga',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Display missing information warning if needed
          if (hasMissingInfo) _buildMissingInfoSection(),

          // Display summary if available
          if (analysisResult.summary != null) ...[
            Text(
              analysisResult.summary!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],

          // Always add the divider regardless of summary existence
          const Divider(height: 24, color: Colors.black12),

          // Display analysis data
          _buildStatRow('Jenis Olahraga', analysisResult.exerciseType),
          _buildStatRow('Durasi', analysisResult.duration),
          _buildStatRow('Intensitas', analysisResult.intensity),
          _buildStatRow(
              'Estimasi Kalori', '${analysisResult.estimatedCalories} kkal'),
          
          // Display MET value if greater than 0
          if (analysisResult.metValue > 0)
            _buildStatRow('MET', analysisResult.metValue.toStringAsFixed(1)),

          const SizedBox(height: 20),

          // Action buttons
          if (analysisResult.isComplete) ...[
            // Tampilkan kedua tombol jika data lengkap
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF9B6BFF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ulangi Input',
                      style: TextStyle(
                        color: Color(0xFF9B6BFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B6BFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Log',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ] else ...[
            // Hanya tampilkan tombol 'Ulangi Input' jika data tidak lengkap
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF9B6BFF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ulangi Input',
                  style: TextStyle(
                    color: Color(0xFF9B6BFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingInfoSection() {
    final missingInfo = analysisResult.missingInfo!;
    final missingLabels = {
      'type': 'Jenis olahraga',
      'duration': 'Durasi olahraga',
      'intensity': 'Intensitas olahraga',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Kurang Lengkap',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Silakan berikan informasi lebih detail tentang:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          ...missingInfo.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${missingLabels[item] ?? item}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}