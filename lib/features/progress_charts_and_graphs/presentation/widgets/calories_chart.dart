import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';
import 'package:intl/intl.dart';

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
    
    // Calculate proportional data
    final proportionalData = _calculateProportionalData();
    
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
          children: [
            isLoading 
              ? const SizedBox(
                  height: 28, 
                  width: 80,
                  child: Center(
                    child: SizedBox(
                      height: 16, 
                      width: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  ),
                )
              : Text(
                  formattedCalories,
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
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Colors.grey[200],
                      dashArray: const [5, 5],
                    ),
                    axisLine: const AxisLine(width: 0),
                    minimum: 0,
                    // Dynamic maximum based on highest calorie day rounded up to nearest 100
                    maximum: _calculateYAxisMaximum(),
                    // Set interval to evenly divide the axis into 5 parts (showing 6 values including 0 and max)
                    interval: _calculateYAxisMaximum() / 5,
                    // Show label for maximum value
                    maximumLabelWidth: 50,
                    labelFormat: '{value}',
                    decimalPlaces: 0,
                  ),
// coverage:ignore-start
                  series: <CartesianSeries>[
                    StackedColumnSeries<Map<String, dynamic>, String>(
                      dataSource: proportionalData,
                      xValueMapper: (Map<String, dynamic> data, _) => data['day'],
                      yValueMapper: (Map<String, dynamic> data, _) => data['carbsCalories'],
                      color: Colors.amber,
                      name: 'Carbs',
                      // Add this field to store the gram value for tooltip display
                      dataLabelMapper: (Map<String, dynamic> data, _) => data['carbs'].toString(),
                    ),
                    StackedColumnSeries<Map<String, dynamic>, String>(
                      dataSource: proportionalData,
                      xValueMapper: (Map<String, dynamic> data, _) => data['day'],
                      yValueMapper: (Map<String, dynamic> data, _) => data['proteinCalories'],
                      color: const Color(0xFF2196F3),
                      name: 'Protein',
                      // Add this field to store the gram value for tooltip display
                      dataLabelMapper: (Map<String, dynamic> data, _) => data['protein'].toString(),
                    ),
                    StackedColumnSeries<Map<String, dynamic>, String>(
                      dataSource: proportionalData,
                      xValueMapper: (Map<String, dynamic> data, _) => data['day'],
                      yValueMapper: (Map<String, dynamic> data, _) => data['fatCalories'],
                      color: const Color(0xFFE57373),
                      name: 'Fats',
                      // Add this field to store the gram value for tooltip display
                      dataLabelMapper: (Map<String, dynamic> data, _) => data['fats'].toString(),
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    // Use a custom builder instead of format
                    builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                      // Get the corresponding macronutrient data
                      final macroData = proportionalData[pointIndex];
                      String value = '';
                      String macroType = '';
                      
                      // Select the right macronutrient based on series index
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
                      
                      // Convert abbreviated day to full name
                      final String fullDayName = _getFullDayName(macroData['day']);
                      
                      // Create improved tooltip with centered text
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Remove the fixed width constraints to let it adjust to content
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Day name - bold, centered, underlined
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white, width: 1)
                                  )
                                ),
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
                              // Macronutrient value - centered
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
        ),
        const SizedBox(height: 8),
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

  List<Map<String, dynamic>> _calculateProportionalData() {
    List<Map<String, dynamic>> result = [];
    
    for (var data in calorieData) {
      final dailyCalories = data.calories > 0 ? data.calories : _calculateCaloriesFromMacros(data);
      
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
      });
    }
    
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
      final dailyCalories = data.calories > 0 ? data.calories : _calculateCaloriesFromMacros(data);
      
      if (dailyCalories > maxDailyCalories) {
        maxDailyCalories = dailyCalories;
      }
    }
    
    // Round up to the nearest 100 for better visualization
    // e.g., if max calories is 1243, round up to 1300
    return ((maxDailyCalories / 100).ceil() * 100).toDouble();
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