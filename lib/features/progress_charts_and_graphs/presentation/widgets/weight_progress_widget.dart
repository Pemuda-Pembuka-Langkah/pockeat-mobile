// import 'package:flutter/material.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/domain/models/weight_data.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/circular_indicator_widget.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_selection_tabs.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/week_selection_tabs.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/goal_progress_chart.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/calories_chart.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/bmi_section.dart';
// import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';
// import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
// import 'package:pockeat/core/di/service_locator.dart';
// import 'package:provider/provider.dart';

// class WeightProgressWidget extends StatefulWidget {
//   const WeightProgressWidget({super.key});

//   @override
//   State<WeightProgressWidget> createState() => _WeightProgressWidgetState();
// }

// class _WeightProgressWidgetState extends State<WeightProgressWidget> {
//   String selectedPeriod = '1 Week';
//   String selectedWeek = 'This week';
//   final Color primaryPink = const Color(0xFFFF6B6B);
//   final Color primaryGreen = const Color(0xFF4ECDC4);
//   final Color primaryYellow = const Color(0xFFFFE893);
//   final Color primaryBlue = const Color(0xFF3498DB);
//   final Color primaryOrange = const Color(0xFFFF9800);
  
//   // Services
//   late FoodLogDataService _foodLogDataService;
  
//   // States
//   bool _isLoadingCalorieData = true;
//   List<CalorieData> _calorieData = [];
//   double _totalCalories = 0;

//   // Data untuk tampilan Goal Progress Chart
//   final List<WeightData> weekData = [
//     WeightData('Sun', 0),
//     WeightData('Mon', 0),
//     WeightData('Tue', 0),
//     WeightData('Wed', 78.10),
//     WeightData('Thu', 78.05),
//     WeightData('Fri', 78),
//     WeightData('Sat', 0),
//   ];

//   final List<WeightData> monthData = [
//     WeightData('Week 1', 78.6),
//     WeightData('Week 2', 78.4),
//     WeightData('Week 3', 78.2),
//     WeightData('Week 4', 78.0),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeFoodLogService();
//     _loadCalorieData();
//   }
  
//   void _initializeFoodLogService() {
//     try {
//       // Try to get the service from the global service locator
//       _foodLogDataService = getIt<FoodLogDataService>();
//     } catch (e) {
//       debugPrint('Error getting FoodLogDataService: $e');
//       // If not available in service locator, get from Provider
//       try {
//         _foodLogDataService = FoodLogDataService(
//           foodLogService: Provider.of<FoodLogHistoryService>(context, listen: false),
//         );
//       } catch (e) {
//         debugPrint('Error creating FoodLogDataService: $e');
//         // Create a mock service for development/testing
//         _foodLogDataService = _createMockFoodLogDataService();
//       }
//     }
//   }
  
//   FoodLogDataService _createMockFoodLogDataService() {
//     // This creates a mock service for development and testing
//     return FoodLogDataService(
//       foodLogService: Provider.of<FoodLogHistoryService>(context, listen: false),
//     );
//   }
  
//   Future<void> _loadCalorieData() async {
//     if (!mounted) return;
    
//     setState(() {
//       _isLoadingCalorieData = true;
//     });
    
//     try {
//       final calorieData = selectedPeriod == '1 Month' 
//           ? await _foodLogDataService.getMonthCalorieData()
//           : await _foodLogDataService.getWeekCalorieData();
      
//       // Get direct calorie total from log data
//       final totalCalories = await _foodLogDataService.calculateTotalCalories(calorieData);
      
//       if (mounted) {
//         setState(() {
//           _calorieData = calorieData;
//           _totalCalories = totalCalories;
//           _isLoadingCalorieData = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading calorie data: $e');
//       if (mounted) {
//         setState(() {
//           _calorieData = _getDefaultCalorieData();
//           _totalCalories = 0;
//           _isLoadingCalorieData = false;
//         });
//       }
//     }
//   }

//   List<CalorieData> _getDefaultCalorieData() {
//     return selectedPeriod == '1 Month' 
//         ? [
//             CalorieData('Week 1', 0, 0, 0),
//             CalorieData('Week 2', 0, 0, 0),
//             CalorieData('Week 3', 0, 0, 0),
//             CalorieData('Week 4', 0, 0, 0),
//           ]
//         : [
//             CalorieData('Sun', 0, 0, 0),
//             CalorieData('Mon', 0, 0, 0),
//             CalorieData('Tue', 0, 0, 0),
//             CalorieData('Wed', 0, 0, 0),
//             CalorieData('Thu', 0, 0, 0),
//             CalorieData('Fri', 0, 0, 0),
//             CalorieData('Sat', 0, 0, 0),
//           ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildCurrentWeightIndicators(),
//             const SizedBox(height: 24),
//             BMISection(
//               primaryBlue: primaryBlue,
//               primaryGreen: primaryGreen,
//               primaryYellow: primaryYellow,
//               primaryPink: primaryPink,
//             ),
//             const SizedBox(height: 24),
//             PeriodSelectionTabs(
//               selectedPeriod: selectedPeriod,
//               onPeriodSelected: (period) {
//                 setState(() {
//                   selectedPeriod = period;
//                 });
//                 _loadCalorieData(); // Reload data when period changes
//               },
//               primaryColor: primaryPink,
//             ),
//             const SizedBox(height: 24),
//             GoalProgressChart(
//               displayData: selectedPeriod == '1 Month' ? monthData : weekData,
//               primaryGreen: primaryGreen,
//             ),
//             const SizedBox(height: 24),
//             if (selectedPeriod != 'All time') ...[
//               WeekSelectionTabs(
//                 selectedWeek: selectedWeek,
//                 onWeekSelected: (week) {
//                   setState(() {
//                     selectedWeek = week;
//                   });
//                   _loadCalorieData(); // Reload data when week changes
//                 },
//                 primaryColor: primaryPink,
//               ),
//               const SizedBox(height: 16),
//               CaloriesChart(
//                 calorieData: _calorieData, 
//                 totalCalories: _totalCalories,
//                 isLoading: _isLoadingCalorieData,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentWeightIndicators() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Weight Goal Section
//         Expanded(
//           child: CircularIndicatorWidget(
//             label: "Weight Goal",
//             value: "74 kg",
//             icon: Icons.flag_outlined,
//             color: primaryGreen,
//           ),
//         ),
//         const SizedBox(width: 16),
        
//         // Current Weight Section
//         Expanded(
//           child: CircularIndicatorWidget(
//             label: "Current Weight",
//             value: "78 kg",
//             icon: Icons.scale,
//             color: primaryPink,
//           ),
//         ),
//       ],
//     );
//   }
// }