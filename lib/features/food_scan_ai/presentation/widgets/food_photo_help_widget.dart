import 'package:flutter/material.dart';

class FoodPhotoHelpWidget extends StatelessWidget {
  final Color primaryColor;

  const FoodPhotoHelpWidget({
    super.key,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How to Take a Good Food Photo',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            _buildTipItem(
              Icons.brightness_5,
              'Good Lighting',
              'Try to take photos in natural light. Avoid harsh shadows.',
            ),
            _buildTipItem(
              Icons.center_focus_strong,
              'Center Your Food',
              'Keep the food inside the scanning frame.',
            ),
            _buildTipItem(
              Icons.height,
              'Appropriate Distance',
              'Not too close, not too far. 8-12 inches is ideal.',
            ),
            _buildTipItem(
              Icons.stay_current_portrait,
              'Steady Hand',
              'Hold your phone steady to avoid blur.',
            ),
            _buildTipItem(
              Icons.highlight,
              'Avoid Reflections',
              'Avoid glare from shiny surfaces or packaging.',
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
              ),
              child: const Text(
                'Got it!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: primaryColor, size: 24.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14.0,
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
