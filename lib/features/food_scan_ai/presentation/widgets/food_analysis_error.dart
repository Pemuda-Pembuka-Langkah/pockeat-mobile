import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FoodAnalysisError extends StatelessWidget {
  final String errorMessage;
  final Color primaryPink;
  final Color primaryYellow;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const FoodAnalysisError({
    Key? key,
    required this.errorMessage,
    required this.primaryPink,
    required this.primaryYellow,
    required this.onRetry,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon error
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.exclamationmark_circle,
                  size: 60,
                  color: primaryPink,
                ),
              ),
              const SizedBox(height: 32),
              
              // Judul error
              const Text(
                'Makanan Tidak Terdeteksi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Pesan error
              Text(
                'AI kami tidak dapat mengidentifikasi makanan dalam foto. Pastikan makanan terlihat jelas dan coba lagi.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Tips untuk foto yang lebih baik
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.lightbulb_fill, color: primaryPink),
                        const SizedBox(width: 8),
                        const Text(
                          'Tips untuk Foto yang Lebih Baik:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('Pastikan pencahayaan cukup terang'),
                    _buildTipItem('Ambil foto dari sudut atas'),
                    _buildTipItem('Hindari bayangan yang menutupi makanan'),
                    _buildTipItem('Pastikan seluruh makanan terlihat dalam frame'),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: primaryPink),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Kembali',
                        style: TextStyle(
                          color: primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Foto Ulang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
} 