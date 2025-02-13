import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeightProgressSection extends StatefulWidget {
  @override
  _WeightProgressSectionState createState() => _WeightProgressSectionState();
}

class _WeightProgressSectionState extends State<WeightProgressSection> {
  String selectedPeriod = 'Weekly';
  final Color primaryPink = Color(0xFFFF6B6B);
  final Color primaryGreen = Color(0xFF4ECDC4);
  final Color primaryYellow = Color(0xFFFFE893);
  
  

  // Enhanced data dengan exercise metrics
  final Map<String, List<WeightDataComplete>> periodData = {
    'Daily': [
      WeightDataComplete('Jan 1', 75.5, 400, 45, 'Running'),
      WeightDataComplete('Jan 2', 75.4, 350, 60, 'Weightlifting'),
      WeightDataComplete('Jan 3', 75.3, 300, 30, 'HIIT'),
      WeightDataComplete('Jan 4', 75.1, 450, 50, 'Running'),
      WeightDataComplete('Jan 5', 75.0, 500, 65, 'Weightlifting'),
      WeightDataComplete('Jan 6', 74.8, 380, 40, 'HIIT'),
      WeightDataComplete('Jan 7', 74.7, 420, 45, 'Running'),
      WeightDataComplete('Jan 8', 74.5, 460, 55, 'Weightlifting'),
      WeightDataComplete('Jan 9', 74.3, 350, 35, 'HIIT'),
      WeightDataComplete('Jan 10', 74.2, 400, 45, 'Running'),
      WeightDataComplete('Jan 11', 74.0, 480, 60, 'Weightlifting'),
      WeightDataComplete('Jan 12', 73.8, 320, 30, 'HIIT'),
      WeightDataComplete('Jan 13', 73.6, 440, 50, 'Running'),
      WeightDataComplete('Jan 14', 73.4, 500, 65, 'Weightlifting'),
    ],
    'Weekly': [
      WeightDataComplete('Week 1', 75.5, 1200, 180, 'Running'),
      WeightDataComplete('Week 2', 74.8, 1500, 210, 'Weightlifting'),
      WeightDataComplete('Week 3', 74.0, 1800, 240, 'Running'),
      WeightDataComplete('Week 4', 73.4, 1600, 200, 'HIIT'),
    ],
    'Monthly': [
      WeightDataComplete('Nov', 76.0, 4800, 600, 'Mixed'),
      WeightDataComplete('Dec', 75.0, 5200, 680, 'Mixed'),
      WeightDataComplete('Jan', 73.4, 6100, 830, 'Mixed'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24),
            _buildCurrentWeightCard(),
            SizedBox(height: 24),
            _buildGoalsCard(),
            SizedBox(height: 24),
            _buildWeeklyAnalysis(),
            SizedBox(height: 24),
            _buildProgressChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Weight Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                _buildAchievementBadge(),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Last 30 days',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        _buildBMIIndicator(22.5),
      ],
    );
  }

  Widget _buildAchievementBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: primaryPink, size: 14),
          SizedBox(width: 4),
          Text(
            'Consistent',
            style: TextStyle(
              color: primaryPink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeightCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '73.0 kg',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Current Weight',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_downward, color: primaryGreen, size: 20),
                      Text(
                        '2.5 kg',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'from starting weight',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildProgressBarWithMetrics(),
        ],
      ),
    );
  }

  Widget _buildProgressBarWithMetrics() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress to Goal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '71%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryGreen,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.71,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                minHeight: 12,
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: MediaQuery.of(context).size.width * 0.3,
              child: Container(
                width: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '👟 Exercise: 45%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '🍎 Diet: 55%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Insights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildInsightCard(
                icon: Icons.fitness_center,
                title: '20% Faster',
                description: 'Weight loss on strength training days',
                color: primaryPink,
              ),
              SizedBox(width: 12),
              _buildInsightCard(
                icon: Icons.schedule,
                title: 'Morning Effect',
                description: 'Better results with AM workouts',
                color: primaryGreen,
              ),
              SizedBox(width: 12),
              _buildInsightCard(
                icon: Icons.restaurant,
                title: 'Protein Impact',
                description: 'Higher loss during protein-rich weeks',
                color: Color(0xFFFFB946),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyAnalysis() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week\'s Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnalysisItem(
                icon: Icons.arrow_downward,
                label: 'Weight Change',
                value: '-0.3 kg',
                color: primaryGreen,
              ),
              _buildAnalysisItem(
                icon: Icons.local_fire_department,
                label: 'Calories Burned',
                value: '1,200 cal',
                color: primaryPink,
              ),
              _buildAnalysisItem(
                icon: Icons.speed,
                label: 'Progress Rate',
                value: '105%',
                color: Color(0xFFFFB946),
              ),
            ],
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.85,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
          ),
          SizedBox(height: 8),
          Text(
            '85% of weekly goal achieved',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ... rest of the existing methods with updated styling
  Widget _buildBMIIndicator(double bmi) {
    String category = '';
    Color color;
    
    if (bmi < 18.5) {
      category = 'Underweight';
      color = Color(0xFFFFB946);
    } else if (bmi < 25) {
      category = 'Healthy';
      color = primaryGreen;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = Color(0xFFFFB946);
    } else {
      category = 'Obese';
      color = primaryPink;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            category,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight Goals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'On Track',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGoalDetail('Starting', '75.5 kg', 'Dec 1, 2024', Icons.history),
              Container(height: 40, width: 1, color: Colors.grey[200]),
              _buildGoalDetail('Target', '70.0 kg', 'Mar 1, 2025', Icons.flag),
              Container(height: 40, width: 1, color: Colors.grey[200]),
              _buildGoalDetail('To Go', '3.0 kg', '35 days left', Icons.trending_down),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryYellow.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates, color: Color(0xFFFFB946), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maintaining current activity level, you\'ll reach your goal 5 days ahead of schedule!',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalDetail(String label, String value, String subtitle, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryPink, size: 16),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress Chart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPeriod,
                        isDense: true,
                        icon: Icon(Icons.keyboard_arrow_down, size: 20),
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        items: ['Daily', 'Weekly', 'Monthly']
                            .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedPeriod = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey[200],
                    dashArray: [5, 5],
                  ),
                  axisLine: AxisLine(width: 0),
                  labelStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 66,
                  maximum: 78,
                  interval: 2,
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey[200],
                    dashArray: [5, 5],
                  ),
                  axisLine: AxisLine(width: 0),
                  labelStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                series: <CartesianSeries<WeightDataComplete, String>>[
                  // Target Weight Line
                  LineSeries<WeightDataComplete, String>(
                    name: 'Target Weight',
                    color: Colors.grey[300],
                    width: 1,
                    dashArray: [2, 2],
                    dataSource: [
                      for (var data in periodData[selectedPeriod]!)
                        WeightDataComplete(data.label, 70.0, 0, 0, '')
                    ],
                    xValueMapper: (WeightDataComplete data, _) => data.label,
                    yValueMapper: (WeightDataComplete data, _) => data.weight,
                  ),
                  // Actual Weight Line
                  LineSeries<WeightDataComplete, String>(
                    name: 'Actual Weight',
                    color: primaryPink,
                    width: 2,
                    dataSource: periodData[selectedPeriod]!,
                    xValueMapper: (WeightDataComplete data, _) => data.label,
                    yValueMapper: (WeightDataComplete data, _) => data.weight,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      shape: DataMarkerType.circle,
                      borderWidth: 2,
                      borderColor: primaryPink,
                      color: Colors.white,
                    ),
                  ),
                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tambahan model data untuk exercise impact
  class WeightDataComplete {
    final String label;
    final double weight;
    final int caloriesBurned;
    final int exerciseMinutes;
    final String dominantExercise;

    WeightDataComplete(this.label, this.weight, this.caloriesBurned, 
        this.exerciseMinutes, this.dominantExercise);
  }