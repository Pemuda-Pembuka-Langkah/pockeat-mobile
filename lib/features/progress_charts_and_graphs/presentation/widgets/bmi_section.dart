// import 'package:flutter/material.dart';

// class BMISection extends StatelessWidget {
//   final Color primaryBlue;
//   final Color primaryGreen;
//   final Color primaryYellow;
//   final Color primaryPink;
  
//   final double bmiValue;

//   const BMISection({
//     super.key,
//     required this.primaryBlue,
//     required this.primaryGreen,
//     required this.primaryYellow,
//     required this.primaryPink,
//     required this.bmiValue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bmiCategory = _getBMICategory(bmiValue);  

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Your BMI',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         Row(
//           children: [
//             Text(
//               bmiValue.toStringAsFixed(1), // <-- show calculated BMI
//               style: const TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Your weight is ',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: _getCategoryColor(bmiCategory), // Dynamic color
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 bmiCategory,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Container(
//           width: double.infinity,
//           height: 12,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(6),
//             gradient: LinearGradient(
//               colors: [
//                 primaryBlue,
//                 primaryGreen,
//                 primaryYellow,
//                 primaryPink,
//               ],
//             ),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 left: (bmiValue / 40).clamp(0.0, 1.0) * MediaQuery.of(context).size.width, 
//                 top: 0,
//                 bottom: 0,
//                 child: Container(
//                   width: 3,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _buildBMICategory(primaryBlue, 'Underweight'),
//             _buildBMICategory(primaryGreen, 'Healthy'),
//             _buildBMICategory(primaryYellow, 'Overweight'),
//             _buildBMICategory(primaryPink, 'Obese'),
//           ],
//         ),
//       ],
//     );
//   }

//   // --- Helper to derive category from BMI ---
//   String _getBMICategory(double bmi) {
//     if (bmi < 18.5) {
//       return 'Underweight';
//     } else if (bmi < 24.9) {
//       return 'Healthy';
//     } else if (bmi < 29.9) {
//       return 'Overweight';
//     } else {
//       return 'Obese';
//     }
//   }

//   Color _getCategoryColor(String category) {
//     switch (category.toLowerCase()) {
//       case 'underweight':
//         return primaryBlue;
//       case 'healthy':
//         return primaryGreen;
//       case 'overweight':
//         return primaryYellow;
//       case 'obese':
//         return primaryPink;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildBMICategory(Color color, String label) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: color,
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }
// }
