// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:syncfusion_flutter_charts/charts.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/weight_data.dart';

// coverage:ignore-start
class GoalProgressChart extends StatelessWidget {
  final List<WeightData> displayData;
  final Color primaryGreen;
  final double currentWeight;
  final double? goalWeight; // Add parameter for goal weight
  final double? initialWeight; // Add parameter for initial weight

  const GoalProgressChart({
    super.key,
    required this.displayData,
    required this.primaryGreen,
    required this.currentWeight,
    this.goalWeight, // Make it optional for backward compatibility
    this.initialWeight, // Make it optional for backward compatibility
  });

  // Calculate goal progress percentage
  String _calculateGoalPercentage() {
    // Debug log for input values
    debugPrint('Goal Progress Calculation - Inputs:');
    debugPrint('  Current Weight: $currentWeight kg');
    debugPrint('  Goal Weight: ${goalWeight ?? "null"} kg');
    debugPrint('  Initial Weight: ${initialWeight ?? "null"} kg');

    // If any of the required values is missing, return a default value
    if (goalWeight == null ||
        initialWeight == null ||
        initialWeight == goalWeight) {
      debugPrint(
          'Goal Progress Calculation - Missing values or initial weight equals goal weight');
      debugPrint('  Returning default: 0.0% of goal');
      return '0.0% of goal';
    }

    // Calculate progress percentage:
    // (initialWeight - currentWeight) / (initialWeight - goalWeight) * 100
    double progressPercentage =
        (initialWeight! - currentWeight) / (initialWeight! - goalWeight!) * 100;

    debugPrint('Goal Progress Calculation - Raw result:');
    debugPrint(
        '  Formula: (${initialWeight!} - $currentWeight) / (${initialWeight!} - ${goalWeight!}) * 100');
    debugPrint('  Raw Progress: $progressPercentage%');

    // Handle edge cases
    if (progressPercentage.isNaN || progressPercentage.isInfinite) {
      debugPrint(
          'Goal Progress Calculation - Invalid result (NaN or Infinite)');
      debugPrint('  Returning default: 0.0% of goal');
      return '0.0% of goal';
    }

    // Handle negative progress (gaining weight when goal is to lose weight, or vice versa)
    if (progressPercentage < 0) {
      debugPrint('Goal Progress Calculation - Negative progress detected');
      debugPrint('  Capping at 0%');
      progressPercentage = 0;
    }

    // Cap progress at 100%
    if (progressPercentage > 100) {
      debugPrint('Goal Progress Calculation - Progress exceeds 100%');
      debugPrint('  Capping at 100%');
      progressPercentage = 100;
    }

    // Round to 1 decimal place
    String result = '${progressPercentage.toStringAsFixed(1)}% of goal';
    debugPrint('Goal Progress Calculation - Final result: $result');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Hitung minimum dan maximum untuk y-axis berdasarkan berat saat ini
    final double yAxisMinimum = _calculateYAxisMinimum();
    final double yAxisMaximum = _calculateYAxisMaximum();

    // Get the calculated goal percentage
    final String goalPercentage = _calculateGoalPercentage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weight Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    goalPercentage, // Use the calculated goal percentage
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              axisLine: AxisLine(width: 0),
            ),
            primaryYAxis: NumericAxis(
              // Use dynamically calculated values
              minimum: yAxisMinimum,
              maximum: yAxisMaximum,
              interval: _calculateYAxisInterval(yAxisMinimum, yAxisMaximum),
              majorGridLines: MajorGridLines(
                width: 1,
                color: Colors.grey[300],
              ),
              axisLine: const AxisLine(width: 0),
            ),
            // Enable tooltip for the chart
            tooltipBehavior: TooltipBehavior(
              enable: true,
              // Show tooltip only on tap, not on hover
              activationMode: ActivationMode.singleTap,
              // Use a custom tooltip builder instead of format
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                // Get the actual WeightData object
                final WeightData weightData = displayData[pointIndex];

                // Map abbreviated day names to full names
                final String fullDayName = _getFullDayName(weightData.week);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Triangle pointer pointing to the data point
                    Positioned(
                      bottom: -8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                          transform: Matrix4.rotationZ(3.14159),
                        ),
                      ),
                    ),
                    // Main tooltip container
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.white, width: 1))),
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                fullDayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
                              'Weight: ${weightData.weight.toStringAsFixed(2)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              // Don't need these when using builder
              color: Colors.transparent,
              borderWidth: 0,
            ),
            series: <CartesianSeries>[
              LineSeries<WeightData, String>(
                dataSource: displayData,
                xValueMapper: (WeightData data, _) => data.week,
                yValueMapper: (WeightData data, _) =>
                    data.weight > 0 ? data.weight : null,
                color: Colors.black,
                width: 2,
                emptyPointSettings: const EmptyPointSettings(
                  mode: EmptyPointMode.gap,
                ),
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.circle,
                  height: 8,
                  width: 8,
                ),
                // Turn off permanent data labels
                dataLabelSettings: const DataLabelSettings(isVisible: false),
                // Enable showing marker when selected
                enableTooltip: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method untuk menghitung minimum y-axis dengan hasil bilangan bulat
  double _calculateYAxisMinimum() {
    // Bulatkan currentWeight ke bilangan bulat terdekat
    double roundedCurrentWeight = (currentWeight + 0.5).floor().toDouble();

    // Default ke roundedCurrentWeight - 3 (selalu bilangan bulat)
    double minValue = roundedCurrentWeight - 3;

    // Cari nilai terendah dalam data yang ditampilkan
    if (displayData.isNotEmpty) {
      final lowestWeight = displayData
          .map((data) => data.weight)
          .where((weight) => weight > 0) // Abaikan nilai 0 atau negatif
          .fold<double>(double.infinity, (a, b) => a < b ? a : b);

      // Jika ada nilai terendah yang valid dan lebih rendah dari default
      if (lowestWeight < double.infinity && lowestWeight < minValue) {
        // Bulatkan ke bawah dan kurangi 1 untuk memastikan nilai data tidak berada di batas minimum
        minValue = lowestWeight.floor() - 1.0;
      }
    }

    // Pastikan rentang minimum tidak kurang dari 30
    return math.max(30.0, minValue); // Menggunakan math.max (huruf kecil)
  }

  // Method untuk menghitung maximum y-axis dengan hasil bilangan bulat
  double _calculateYAxisMaximum() {
    // Bulatkan currentWeight ke bilangan bulat terdekat
    double roundedCurrentWeight = (currentWeight + 0.5).floor().toDouble();

    // Default ke roundedCurrentWeight + 3 (selalu bilangan bulat)
    double maxValue = roundedCurrentWeight + 3;

    // Cari nilai tertinggi dalam data yang ditampilkan
    if (displayData.isNotEmpty) {
      final highestWeight = displayData
          .map((data) => data.weight)
          .where((weight) => weight > 0) // Abaikan nilai 0 atau negatif
          .fold<double>(0, (a, b) => a > b ? a : b);

      // Jika ada nilai tertinggi yang valid dan lebih tinggi dari default
      if (highestWeight > 0 && highestWeight > maxValue) {
        // Bulatkan ke atas dan tambahkan 1 untuk memastikan nilai data tidak berada di batas maksimum
        maxValue = highestWeight.ceil() + 1.0;
      }
    }

    // Pastikan rentang maksimum tidak melebihi 300
    return math.min(300.0, maxValue); // Menggunakan math.min (huruf kecil)
  }

  // Method baru untuk menghitung interval y-axis yang dinamis
  double _calculateYAxisInterval(double min, double max) {
    // Hitung range nilai
    double range = max - min;

    // Kita ingin sekitar 5-8 interval di y-axis
    double idealDivisor = range / 6; // Target ~6 interval

    // Pilih interval yang merupakan bilangan bulat dan membagi range dengan baik
    {
      if (idealDivisor <= 1) {
        return 1; // Minimal interval 1
      } else if (idealDivisor <= 2) {
        return 2;
      } else if (idealDivisor <= 5) {
        return 5;
      } else if (idealDivisor <= 10) {
        return 10;
      } else if (idealDivisor <= 20) {
        return 20;
      } else if (idealDivisor <= 25) {
        return 25;
      } else if (idealDivisor <= 50) {
        return 50;
      } else {
        return 100;
      }
    }
  }

  // Helper method to convert abbreviated day names to full names
  String _getFullDayName(String abbreviatedDay) {
    switch (abbreviatedDay) {
      case 'Sun':
        return 'Sunday';
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      case 'Fri':
        return 'Friday';
      case 'Sat':
        return 'Saturday';
      // Handle week labels for month view
      case 'Week 1':
      case 'Week 2':
      case 'Week 3':
      case 'Week 4':
        return abbreviatedDay;
      default:
        return abbreviatedDay;
    }
  }
}
// coverage:ignore-end
