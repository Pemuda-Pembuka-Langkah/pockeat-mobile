// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/bmi_section.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/calories_chart.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/circular_indicator_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/goal_progress_chart.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_selection_tabs.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/week_selection_tabs.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';

class WeightProgressWidget extends StatefulWidget {
  const WeightProgressWidget({super.key});

  @override
  State<WeightProgressWidget> createState() => _WeightProgressWidgetState();
}

class _WeightProgressWidgetState extends State<WeightProgressWidget> {
  // UI constants
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryBlue = const Color(0xFF3498DB);
  final Color primaryOrange = const Color(0xFFFF9800);

  // State variables
  String selectedPeriod = '1 Week';
  String selectedWeek = 'This week';
  bool _isLoadingCalorieData = true;
  List<CalorieData> _calorieData = [];
  double _totalCalories = 0;

  // Service instance
  late final FoodLogDataService _foodLogDataService;

  // Sample weight data for charts
  final List<WeightData> weekData = [
    WeightData('Sun', 0),
    WeightData('Mon', 0),
    WeightData('Tue', 0),
    WeightData('Wed', 78.10),
    WeightData('Thu', 78.05),
    WeightData('Fri', 78),
    WeightData('Sat', 0),
  ];

  final List<WeightData> monthData = [
    WeightData('Week 1', 78.6),
    WeightData('Week 2', 78.4),
    WeightData('Week 3', 78.2),
    WeightData('Week 4', 78.0),
  ];

  @override
  void initState() {
    super.initState();
    _foodLogDataService = getIt<FoodLogDataService>();
    _loadCalorieData();
  }

// coverage:ignore-start
  Future<void> _loadCalorieData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingCalorieData = true;
    });

    try {
      List<CalorieData> calorieData;

      if (selectedPeriod == '1 Month') {
        calorieData = await _foodLogDataService.getMonthCalorieData();
      } else {
        // Handle different week selections
        switch (selectedWeek) {
          case 'This week':
            calorieData = await _foodLogDataService.getWeekCalorieData();
            break;
          case 'Last week':
            calorieData =
                await _foodLogDataService.getWeekCalorieData(weeksAgo: 1);
            break;
          case '2 wks. ago':
            calorieData =
                await _foodLogDataService.getWeekCalorieData(weeksAgo: 2);
            break;
          case '3 wks. ago':
            calorieData =
                await _foodLogDataService.getWeekCalorieData(weeksAgo: 3);
            break;
          default:
            calorieData = await _foodLogDataService.getWeekCalorieData();
        }
      }

      final totalCalories =
          _foodLogDataService.calculateTotalCalories(calorieData);

      if (mounted) {
        setState(() {
          _calorieData = calorieData;
          _totalCalories = totalCalories;
          _isLoadingCalorieData = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading calorie data: $e');
      if (mounted) {
        setState(() {
          _calorieData = _getDefaultCalorieData();
          _totalCalories = 0;
          _isLoadingCalorieData = false;
        });
      }
    }
  }

  List<CalorieData> _getDefaultCalorieData() {
    return selectedPeriod == '1 Month'
        ? [
            CalorieData('Week 1', 0, 0, 0),
            CalorieData('Week 2', 0, 0, 0),
            CalorieData('Week 3', 0, 0, 0),
            CalorieData('Week 4', 0, 0, 0),
          ]
        : [
            CalorieData('Sun', 0, 0, 0),
            CalorieData('Mon', 0, 0, 0),
            CalorieData('Tue', 0, 0, 0),
            CalorieData('Wed', 0, 0, 0),
            CalorieData('Thu', 0, 0, 0),
            CalorieData('Fri', 0, 0, 0),
            CalorieData('Sat', 0, 0, 0),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWeightIndicators(),
            const SizedBox(height: 24),
            BMISection(
              primaryBlue: primaryBlue,
              primaryGreen: primaryGreen,
              primaryYellow: primaryYellow,
              primaryPink: primaryPink,
            ),
            const SizedBox(height: 24),
            PeriodSelectionTabs(
              selectedPeriod: selectedPeriod,
              onPeriodSelected: (period) {
                setState(() {
                  selectedPeriod = period;
                });
                _loadCalorieData();
              },
              primaryColor: primaryPink,
            ),
            const SizedBox(height: 24),
            GoalProgressChart(
              displayData: selectedPeriod == '1 Month' ? monthData : weekData,
              primaryGreen: primaryGreen,
            ),
            const SizedBox(height: 24),
            if (selectedPeriod != 'All time') ...[
              WeekSelectionTabs(
                selectedWeek: selectedWeek,
                onWeekSelected: (week) {
                  setState(() {
                    selectedWeek = week;
                  });
                  _loadCalorieData();
                },
                primaryColor: primaryPink,
              ),
              const SizedBox(height: 16),
              CaloriesChart(
                calorieData: _calorieData,
                totalCalories: _totalCalories,
                isLoading: _isLoadingCalorieData,
              ),
            ],
          ],
        ),
      ),
    );
  }
// coverage:ignore-end

  Widget _buildCurrentWeightIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CircularIndicatorWidget(
            label: "Weight Goal",
            value: "74 kg",
            icon: Icons.flag_outlined,
            color: primaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CircularIndicatorWidget(
            label: "Current Weight",
            value: "78 kg",
            icon: Icons.scale,
            color: primaryPink,
          ),
        ),
      ],
    );
  }
}
