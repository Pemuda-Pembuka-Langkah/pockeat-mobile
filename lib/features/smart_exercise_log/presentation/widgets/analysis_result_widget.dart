import 'package:flutter/material.dart';

class AnalysisResultWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;
  final VoidCallback onRetry;
  final VoidCallback onSave;

  const AnalysisResultWidget({
    Key? key,
    required this.analysisData,
    required this.onRetry,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasMissingInfo = analysisData.containsKey('missingInfo') && 
                         (analysisData['missingInfo'] as List).isNotEmpty;

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
          if (analysisData.containsKey('summary') && analysisData['summary'] != null) ...[
            Text(
              analysisData['summary'].toString(),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
          
          // Always add the divider regardless of summary existence
          const Divider(height: 24, color: Colors.black12),
          
          // Display analysis data
          _buildStatRow('Jenis Olahraga', analysisData['type'].toString()),
          _buildStatRow('Durasi', analysisData['duration'].toString()),
          _buildStatRow('Intensitas', analysisData['intensity'].toString()),
          _buildStatRow('Estimasi Kalori', '${analysisData['estimatedCalories']} kkal'),
          
          const SizedBox(height: 20),
          
          // Action buttons
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
          ),
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
    final missingInfo = analysisData['missingInfo'] as List;
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