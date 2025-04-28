// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/bmi_section.dart';
// import 'package:pockeat/features/health_metrics/domain/models/health_metrics_model.dart';
// import 'package:pockeat/features/health_metrics/domain/repositories/health_metrics_repository.dart';

// class BMILoader extends StatelessWidget {
//   final String userId;
//   final Color primaryBlue;
//   final Color primaryGreen;
//   final Color primaryYellow;
//   final Color primaryPink;

//   const BMILoader({
//     super.key,
//     required this.userId,
//     required this.primaryBlue,
//     required this.primaryGreen,
//     required this.primaryYellow,
//     required this.primaryPink,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final healthMetricsRepository = context.read<HealthMetricsRepository>();

//     return FutureBuilder<HealthMetricsModel?>(
//       future: healthMetricsRepository.getHealthMetrics(userId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data == null) {
//           return const Center(child: Text('No BMI data found.'));
//         }

//         final healthMetrics = snapshot.data!;

//         return BMISection(
//           primaryBlue: primaryBlue,
//           primaryGreen: primaryGreen,
//           primaryYellow: primaryYellow,
//           primaryPink: primaryPink,
//           bmiValue: healthMetrics.bmi,
//         );
//       },
//     );
//   }
// }