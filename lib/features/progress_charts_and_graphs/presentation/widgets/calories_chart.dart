// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';

class CaloriesChart extends StatelessWidget {
  final List<CalorieData> calorieData;
  final double totalCalories;
  final bool isLoading;

  const CaloriesChart({
    super.key,
    required this.calorieData,
    required this.totalCalories,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');
    final formattedCalories = numberFormat.format(totalCalories.round());

    // Check if data is empty
    final bool hasNoData = calorieData.isEmpty;

    // Calculate average calories per day (only for days with logs)
    final String averageCalories = _calculateAverageCalories();

    // Calculate proportional data
    final List<Map<String, dynamic>> proportionalData =
        hasNoData ? [] : _calculateProportionalData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Calories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                isLoading
                    ? const SizedBox(
                        height: 28,
                        width: 80,
                        child: Center(
                            child: SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))),
                      )
                    : Text(
                        hasNoData ? '0' : formattedCalories,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(width: 4),
                Text(
                  'kcal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            if (!hasNoData && !isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'avg $averageCalories kcal/day',
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
          height: 180,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    // Always show the chart (empty if no data)
                    SfCartesianChart(
                      primaryXAxis: const CategoryAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        axisLine: AxisLine(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        majorGridLines: MajorGridLines(
                          width: 1,
                          color: Colors.grey[200],
                          dashArray: const [5, 5],
                        ),
                        axisLine: const AxisLine(width: 0),
                        minimum: 0,
                        // Use either calculated max or default 500 for empty data
                        maximum: hasNoData ? 500 : _calculateYAxisMaximum(),
                        // Set interval
                        interval:
                            hasNoData ? 100 : _calculateYAxisMaximum() / 5,
                        maximumLabelWidth: 50,
                        labelFormat: '{value}',
                        decimalPlaces: 0,
                      ),
// coverage:ignore-start
                      series: hasNoData
                          ? <CartesianSeries>[]
                          : <CartesianSeries>[
                              StackedColumnSeries<Map<String, dynamic>, String>(
                                dataSource: proportionalData,
                                xValueMapper: (Map<String, dynamic> data, _) =>
                                    data['day'],
                                yValueMapper: (Map<String, dynamic> data, _) =>
                                    data['carbsCalories'],
                                color: Colors.amber,
                                name: 'Carbs',
                                dataLabelMapper:
                                    (Map<String, dynamic> data, _) =>
                                        data['carbs'].toString(),
                              ),
                              StackedColumnSeries<Map<String, dynamic>, String>(
                                dataSource: proportionalData,
                                xValueMapper: (Map<String, dynamic> data, _) =>
                                    data['day'],
                                yValueMapper: (Map<String, dynamic> data, _) =>
                                    data['proteinCalories'],
                                color: const Color(0xFF2196F3),
                                name: 'Protein',
                                dataLabelMapper:
                                    (Map<String, dynamic> data, _) =>
                                        data['protein'].toString(),
                              ),
                              StackedColumnSeries<Map<String, dynamic>, String>(
                                dataSource: proportionalData,
                                xValueMapper: (Map<String, dynamic> data, _) =>
                                    data['day'],
                                yValueMapper: (Map<String, dynamic> data, _) =>
                                    data['fatCalories'],
                                color: const Color(0xFFE57373),
                                name: 'Fats',
                                dataLabelMapper:
                                    (Map<String, dynamic> data, _) =>
                                        data['fats'].toString(),
                              ),
                            ],
                      tooltipBehavior: TooltipBehavior(
                        enable: true && !hasNoData,
                        builder: (dynamic data, dynamic point, dynamic series,
                            int pointIndex, int seriesIndex) {
                          final macroData = proportionalData[pointIndex];
                          String value = '';
                          String macroType = '';

                          if (seriesIndex == 0) {
                            value = macroData['carbs'];
                            macroType = 'Carbs';
                          } else if (seriesIndex == 1) {
                            value = macroData['protein'];
                            macroType = 'Protein';
                          } else if (seriesIndex == 2) {
                            value = macroData['fats'];
                            macroType = 'Fats';
                          }

                          final String fullDayName =
                              _getFullDayName(macroData['day']);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
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
                                                color: Colors.white,
                                                width: 1))),
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
                                    '$macroType: $value g',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Show "No food logs" message if data is empty
                    if (hasNoData)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 30,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "No food logs for this week",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Your nutrition data will appear here once you log meals",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        if (!hasNoData)
          Row(
            children: [
              _buildColorIndicator(Colors.amber, 'Carbs'),
              const SizedBox(width: 16),
              _buildColorIndicator(const Color(0xFF2196F3), 'Protein'),
              const SizedBox(width: 16),
              _buildColorIndicator(const Color(0xFFE57373), 'Fats'),
            ],
          ),
      ],
    );
  }

  String _calculateAverageCalories() {
    if (calorieData.isEmpty) return '0';

    // Count days with actual calorie logs
    int daysWithLogs = 0;
    double totalCaloriesForAverage = 0;

    for (var data in calorieData) {
      final dailyCalories = data.calories > 0
          ? data.calories
          : _calculateCaloriesFromMacros(data);

      if (dailyCalories > 0) {
        daysWithLogs++;
        totalCaloriesForAverage += dailyCalories;
      }
    }

    if (daysWithLogs == 0) return '0';

    final average = totalCaloriesForAverage / daysWithLogs;
    final numberFormat = NumberFormat('#,###');
    return numberFormat.format(average.round());
  }

  List<Map<String, dynamic>> _calculateProportionalData() {
    // Definisikan urutan hari yang benar (Senin-Minggu)
    final dayOrder = {
      'Mon': 0,
      'Tue': 1,
      'Wed': 2,
      'Thu': 3,
      'Fri': 4,
      'Sat': 5,
      'Sun': 6
    };

    List<Map<String, dynamic>> result = [];

    for (var data in calorieData) {
      final dailyCalories = data.calories > 0
          ? data.calories
          : _calculateCaloriesFromMacros(data);

      // Calculate the proportion of each macronutrient
      final totalGrams = data.protein + data.carbs + data.fats;

      double proteinCalories, carbsCalories, fatCalories;

      if (totalGrams > 0) {
        // Calculate proportional calories
        proteinCalories = (data.protein / totalGrams) * dailyCalories;
        carbsCalories = (data.carbs / totalGrams) * dailyCalories;
        fatCalories = (data.fats / totalGrams) * dailyCalories;
      } else {
        // If no macronutrient data, calculate based on standard calorie values
        proteinCalories = data.protein * 4;
        carbsCalories = data.carbs * 4;
        fatCalories = data.fats * 9;
      }

      final dayOrderValue = data.day.startsWith('Week')
          ? int.parse(data.day.split(' ')[1]) *
              10 // Untuk 'Week X', gunakan nilai tinggi
          : dayOrder[data.day] ??
              999; // Default tinggi untuk data yang tidak dikenal

      result.add({
        'day': data.day,
        'calories': dailyCalories,
        'proteinCalories': proteinCalories,
        'carbsCalories': carbsCalories,
        'fatCalories': fatCalories,
        // Store original gram values for tooltip display
        'protein': data.protein.toStringAsFixed(1),
        'carbs': data.carbs.toStringAsFixed(1),
        'fats': data.fats.toStringAsFixed(1),
        // Tambahkan nilai urutan hari untuk pengurutan
        'dayOrder': dayOrderValue,
      });
    }

    // Urutkan hasil berdasarkan urutan hari yang kita definisikan
    result
        .sort((a, b) => (a['dayOrder'] as int).compareTo(b['dayOrder'] as int));

    return result;
  }

  double _calculateCaloriesFromMacros(CalorieData data) {
    // Standard calorie calculations: protein & carbs = 4cal/g, fat = 9cal/g
    return (data.protein * 4) + (data.carbs * 4) + (data.fats * 9);
  }

  double _calculateYAxisMaximum() {
    // Find the maximum daily calorie total in the data
    double maxDailyCalories = 0;

    for (var data in calorieData) {
      // Use either stored calories value or calculate from macronutrients
      final dailyCalories = data.calories > 0
          ? data.calories
          : _calculateCaloriesFromMacros(data);

      if (dailyCalories > maxDailyCalories) {
        maxDailyCalories = dailyCalories;
      }
    }

    // Round up to the nearest 100 for better visualization
    // e.g., if max calories is 1243, round up to 1300
    // Ensure minimum is 500 for better visualization when values are very small
    return math.max(500, ((maxDailyCalories / 100).ceil() * 100)).toDouble();
  }

  Widget _buildColorIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getFullDayName(String abbreviatedDay) {
    switch (abbreviatedDay) {
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
      case 'Sun':
        return 'Sunday';
      default:
        return abbreviatedDay;
    }
  }
}
// coverage:ignore-end
