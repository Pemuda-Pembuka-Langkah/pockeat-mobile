import 'package:flutter/material.dart';

class FoodAnalysisLoading extends StatelessWidget {
  final Color primaryYellow;
  final Color primaryPink;
  final String message;

  const FoodAnalysisLoading({
    super.key,
    required this.primaryYellow,
    required this.primaryPink,
    this.message = 'Analyzing Food',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animasi loading
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryPink),
                  strokeWidth: 6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Judul
          Text(
            message,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message == 'Analyzing Food'
                  ? 'Our AI is identifying the food and calculating its nutritional value...'
                  : 'Our AI is updating the analysis based on your correction...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
