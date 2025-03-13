import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FoodAnalysisLoading extends StatelessWidget {
  final Color primaryYellow;
  final Color primaryPink;
  final String message;

  const FoodAnalysisLoading({
    Key? key,
    required this.primaryYellow,
    required this.primaryPink,
    this.message = 'Analyzing Food',
  }) : super(key: key);

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

          const SizedBox(height: 32),

          // Indikator tahapan analisis
          _buildAnalysisSteps(),
        ],
      ),
    );
  }

  Widget _buildAnalysisSteps() {
    bool isCorrection = message != 'Analyzing Food';
    
    return Column(
      children: [
        _buildAnalysisStep(
          icon: CupertinoIcons.camera,
          text: 'Identifying food',
          isCompleted: true,
        ),
        _buildAnalysisStep(
          icon: isCorrection ? CupertinoIcons.pencil : CupertinoIcons.chart_bar,
          text: isCorrection ? 'Correcting analysis' : 'Calculating nutrition',
          isActive: true,
        ),
      ],
    );
  }

  Widget _buildAnalysisStep({
    required IconData icon,
    required String text,
    bool isCompleted = false,
    bool isActive = false,
  }) {
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      iconColor = Colors.green;
      textColor = Colors.black87;
    } else if (isActive) {
      iconColor = primaryPink;
      textColor = Colors.black87;
    } else {
      iconColor = Colors.grey.shade400;
      textColor = Colors.grey.shade600;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}