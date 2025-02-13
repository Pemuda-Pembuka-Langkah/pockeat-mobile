import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExerciseProgressSection extends StatefulWidget {
  @override
  _ExerciseProgressSectionState createState() => _ExerciseProgressSectionState();
}

class _ExerciseProgressSectionState extends State<ExerciseProgressSection> {
  final Color primaryYellow = Color(0xFFFFE893);
  final Color primaryPink = Color(0xFFFF6B6B);
  final Color primaryGreen = Color(0xFF4ECDC4);
  
  bool isWeeklyView = true;

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
            _buildWorkoutOverview(),
            SizedBox(height: 24),
            _buildExerciseDistribution(),
            SizedBox(height: 24),
            _buildPerformanceMetrics(),
            SizedBox(height: 24),
            _buildWorkoutHistory(),
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
            Text(
              'Exercise Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Track your fitness journey',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              _buildToggleButton('Weekly', isWeeklyView),
              _buildToggleButton('Monthly', !isWeeklyView),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutOverview() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Keep pushing harder!',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.running_with_errors, color: primaryGreen, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '95% completed',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWorkoutStat('Duration', '45 min', primaryGreen),
              _buildWorkoutStat('Calories', '320', primaryPink),
              _buildWorkoutStat('Intensity', 'High', Color(0xFFFFB946)),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 180,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 500,
                interval: 100,
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: Colors.black12,
                  dashArray: [5, 5],
                ),
                labelStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              series: <CartesianSeries>[
                ColumnSeries<ExerciseData, String>(
                  color: primaryGreen,
                  width: 0.7,
                  dataSource: _getExerciseData(),
                  xValueMapper: (ExerciseData data, _) => data.day,
                  yValueMapper: (ExerciseData data, _) => data.calories,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDistribution() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Exercise Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildExerciseTypeRow('Running', 45, primaryPink),
          SizedBox(height: 16),
          _buildExerciseTypeRow('Weightlifting', 30, primaryGreen),
          SizedBox(height: 16),
          _buildExerciseTypeRow('HIIT', 25, Color(0xFFFFB946)),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Performance Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Consistency',
                  '92%',
                  'Last week: 87%',
                  primaryPink,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Intensity',
                  '8.5',
                  'Above average',
                  primaryGreen,
                  Icons.speed,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Streak',
                  '14',
                  'Personal best',
                  Color(0xFFFFB946),
                  Icons.local_fire_department,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Recovery',
                  '95%',
                  'Optimal',
                  primaryGreen,
                  Icons.battery_charging_full,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHistory() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Recent Workouts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildWorkoutItem(
            'Morning Run',
            'Running',
            '5.2 km • 320 cal',
            '2h ago',
            primaryPink,
          ),
          SizedBox(height: 16),
          _buildWorkoutItem(
            'Upper Body',
            'Weightlifting',
            '45 min • 280 cal',
            '1d ago',
            primaryGreen,
          ),
          SizedBox(height: 16),
          _buildWorkoutItem(
            'HIIT Session',
            'HIIT',
            '30 min • 350 cal',
            '2d ago',
            Color(0xFFFFB946),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isWeeklyView = text == 'Weekly';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseTypeRow(String type, int percentage, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: color,
                    size: 14,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    String subtext,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


 Widget _buildWorkoutItem(
   String title,
   String type,
   String stats,
   String time,
   Color color,
 ) {
   return Row(
     children: [
       Container(
         width: 40,
         height: 40,
         decoration: BoxDecoration(
           color: color.withOpacity(0.1),
           borderRadius: BorderRadius.circular(8),
         ),
         child: Icon(Icons.fitness_center, color: color),
       ),
       SizedBox(width: 16),
       Expanded(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               title,
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: Colors.black87,
               ),
             ),
             Row(
               children: [
                 Text(
                   type,
                   style: TextStyle(
                     fontSize: 12,
                     color: color,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
                 Text(
                   ' • ',
                   style: TextStyle(
                     fontSize: 12,
                     color: Colors.black54,
                   ),
                 ),
                 Text(
                   stats,
                   style: TextStyle(
                     fontSize: 12,
                     color: Colors.black54,
                   ),
                 ),
               ],
             ),
           ],
         ),
       ),
       Text(
         time,
         style: TextStyle(
           fontSize: 12,
           color: Colors.black54,
         ),
       ),
     ],
   );
 }

 List<ExerciseData> _getExerciseData() {
   if (isWeeklyView) {
     return [
       ExerciseData('M', 320),
       ExerciseData('T', 280),
       ExerciseData('W', 350),
       ExerciseData('T', 290),
       ExerciseData('F', 400),
       ExerciseData('S', 250),
       ExerciseData('S', 300),
     ];
   } else {
     return [
       ExerciseData('Week 1', 1850),
       ExerciseData('Week 2', 2100),
       ExerciseData('Week 3', 1950),
       ExerciseData('Week 4', 2200),
     ];
   }
 }
}

class ExerciseData {
 ExerciseData(this.day, this.calories);
 final String day;
 final double calories;
}