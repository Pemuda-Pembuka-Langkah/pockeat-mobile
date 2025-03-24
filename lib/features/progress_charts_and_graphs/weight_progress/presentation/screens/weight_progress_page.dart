import 'package:flutter/material.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_goal.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weekly_analysis.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/domain/models/weight_status.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/services/weight_service.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/header_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/current_weight_card_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/goals_card_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/weekly_analysis_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/weight_progress/presentation/widgets/progress_chart_widget.dart';

class WeightProgressPage extends StatefulWidget {
  final WeightService service;
  
  const WeightProgressPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<WeightProgressPage> createState() => _WeightProgressPageState();
}

class _WeightProgressPageState extends State<WeightProgressPage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  
  late Future<String> _selectedPeriodFuture;
  late Future<Map<String, List<WeightData>>> _weightDataFuture;
  late Future<WeightStatus> _weightStatusFuture;
  late Future<WeightGoal> _weightGoalFuture;
  late Future<WeeklyAnalysis> _weeklyAnalysisFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _selectedPeriodFuture = widget.service.getSelectedPeriod();
    _weightDataFuture = widget.service.getWeightData();
    _weightStatusFuture = widget.service.getWeightStatus();
    _weightGoalFuture = widget.service.getWeightGoal();
    _weeklyAnalysisFuture = widget.service.getWeeklyAnalysis();
  }

  void _onPeriodChanged(String? newPeriod) async {
    if (newPeriod != null) {
      // Just save the period but don't trigger a rebuild of the entire page
      await widget.service.setSelectedPeriod(newPeriod);
      // We don't call setState here - the chart widget handles its own state
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<WeightStatus>(
              future: _weightStatusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                return HeaderWidget(
                  weightStatus: snapshot.data!,
                  primaryPink: primaryPink,
                );
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<WeightStatus>(
              future: _weightStatusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                return CurrentWeightCardWidget(
                  weightStatus: snapshot.data!,
                  primaryGreen: primaryGreen,
                );
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<WeightGoal>(
              future: _weightGoalFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                return GoalsCardWidget(
                  weightGoal: snapshot.data!,
                  primaryGreen: primaryGreen,
                  primaryPink: primaryPink,
                  primaryYellow: primaryYellow,
                );
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<WeeklyAnalysis>(
              future: _weeklyAnalysisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                return WeeklyAnalysisWidget(
                  weeklyAnalysis: snapshot.data!,
                  primaryGreen: primaryGreen,
                  primaryPink: primaryPink,
                );
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<dynamic>>(
              future: Future.wait([
                _weightDataFuture,
                _selectedPeriodFuture,
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final weightData = snapshot.data![0] as Map<String, List<WeightData>>;
                final selectedPeriod = snapshot.data![1] as String;
                
                return ProgressChartWidget(
                  periodData: weightData,
                  selectedPeriod: selectedPeriod,
                  onPeriodChanged: _onPeriodChanged,
                  primaryPink: primaryPink,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}