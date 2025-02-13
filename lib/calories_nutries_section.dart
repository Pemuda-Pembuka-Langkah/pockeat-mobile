import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NutritionProgressSection extends StatefulWidget {
  @override
  _NutritionProgressSectionState createState() => _NutritionProgressSectionState();
}

class _NutritionProgressSectionState extends State<NutritionProgressSection> {
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
            _buildProgressOverview(),
            SizedBox(height: 24),
            _buildNutrientProgress(),
            SizedBox(height: 24),
            _buildMealPatterns(),
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
              'Nutrition Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Track your nutrition goals',
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

  Widget _buildProgressOverview() {
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
                    'Daily Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You\'re doing great!',
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
                    Icon(Icons.local_fire_department,
                        color: primaryGreen, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '92% of goal',
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
              _buildNutrientStat('Consumed', '1,850', primaryPink),
              _buildNutrientStat('Burned', '450', primaryGreen),
              _buildNutrientStat('Net', '1,400', primaryPink),
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
                maximum: 3000,
                interval: 500,
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
                ColumnSeries<CalorieData, String>(
                  color: primaryPink,
                  width: 0.7,
                  dataSource: _getCalorieData(),
                  xValueMapper: (CalorieData data, _) => data.day,
                  yValueMapper: (CalorieData data, _) => data.calories,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrient Balance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                'Protein',
                25,
                '75g/120g',
                primaryPink,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMacroCard(
                'Carbs',
                55,
                '138g/250g',
                primaryGreen,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMacroCard(
                'Fat',
                20,
                '32g/65g',
                Color(0xFFFFB946),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
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
            children: [
              _buildNutrientRow('Fiber', '12g', '25g', 0.48, primaryGreen),
              _buildNutrientRow('Sugar', '18g', '30g', 0.6, primaryPink),
              _buildNutrientRow('Sodium', '1200mg', '2300mg', 0.52, primaryGreen),
              _buildNutrientRow('Iron', '12mg', '18mg', 0.67, primaryPink),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealPatterns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meal Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Well Balanced',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
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
            children: [
              _buildMealRow('Breakfast', 550, 2150, '7:30 AM', primaryPink),
              SizedBox(height: 16),
              _buildMealRow('Lunch', 750, 2150, '12:30 PM', primaryGreen),
              SizedBox(height: 16),
              _buildMealRow('Dinner', 650, 2150, '7:00 PM', Color(0xFFFFB946)),
            ],
          ),
        ),
      ],
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
          color: isSelected ? primaryPink : Colors.transparent,
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

  Widget _buildNutrientStat(String label, String value, Color color) {
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
        Row(
          children: [
            if (label == 'Burned') Text('-'),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          'kcal',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(
    String label,
    int percentage,
    String detail,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            detail,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(
    String nutrient,
    String current,
    String target,
    double progress,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              nutrient,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$current / $target',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }Widget _buildMealRow(
   String meal,
   int calories,
   int totalCalories,
   String time,
   Color color,
 ) {
   final percentage = calories / totalCalories;
   return Column(
     children: [
       Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Row(
             children: [
               Text(
                 meal,
                 style: TextStyle(
                   fontSize: 14,
                   color: Colors.black87,
                   fontWeight: FontWeight.w500,
                 ),
               ),
               SizedBox(width: 8),
               Text(
                 time,
                 style: TextStyle(
                   fontSize: 12,
                   color: Colors.black54,
                 ),
               ),
             ],
           ),
           Text(
             '$calories kcal',
             style: TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.w500,
               color: color,
             ),
           ),
         ],
       ),
       SizedBox(height: 8),
       Row(
         children: [
           Expanded(
             child: ClipRRect(
               borderRadius: BorderRadius.circular(4),
               child: LinearProgressIndicator(
                 value: percentage,
                 backgroundColor: color.withOpacity(0.1),
                 valueColor: AlwaysStoppedAnimation<Color>(color),
                 minHeight: 4,
               ),
             ),
           ),
           SizedBox(width: 8),
           Text(
             '${(percentage * 100).toInt()}%',
             style: TextStyle(
               fontSize: 12,
               color: Colors.black54,
             ),
           ),
         ],
       ),
     ],
   );
 }

 List<CalorieData> _getCalorieData() {
   if (isWeeklyView) {
     return [
       CalorieData('M', 2100),
       CalorieData('T', 2300),
       CalorieData('W', 1950),
       CalorieData('T', 2200),
       CalorieData('F', 2400),
       CalorieData('S', 1800),
       CalorieData('S', 2000),
     ];
   } else {
     return [
       CalorieData('Week 1', 2150),
       CalorieData('Week 2', 2250),
       CalorieData('Week 3', 2050),
       CalorieData('Week 4', 2180),
     ];
   }
 }
}

class CalorieData {
 CalorieData(this.day, this.calories);
 final String day;
 final double calories;
}