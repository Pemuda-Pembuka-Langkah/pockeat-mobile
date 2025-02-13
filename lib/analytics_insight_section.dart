import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class InsightsAnalyticsSection extends StatelessWidget {
  final Color primaryYellow = Color(0xFFFFE893);
  final Color primaryPink = Color(0xFFFF6B6B);
  final Color primaryGreen = Color(0xFF4ECDC4);

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
            _buildTodayInsights(),
            SizedBox(height: 20),
            _buildPerformanceMetrics(),
            SizedBox(height: 20),
            _buildNutritionInsights(),
            SizedBox(height: 20),
            _buildExerciseAnalysis(),
            SizedBox(height: 20),
            _buildDetailedAnalysis(),
            SizedBox(height: 20),
            _buildWeeklyPatterns(),
            SizedBox(height: 20),
            _buildSmartRecommendations(),
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
              'Insights & Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Your health journey insights',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
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
              Icon(Icons.trending_up, color: primaryGreen, size: 16),
              SizedBox(width: 4),
              Text(
                'On Track',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayInsights() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.star_fill, color: primaryPink, size: 20),
              SizedBox(width: 8),
              Text(
                'Today\'s Focus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildFocusItem(
            icon: CupertinoIcons.heart_fill,
            title: 'Complete your protein target',
            subtitle: '15g remaining to reach 120g daily goal',
            color: primaryPink,
          ),
          SizedBox(height: 12),
          _buildFocusItem(
            icon: CupertinoIcons.flame_fill,
            title: 'Hit your exercise goal',
            subtitle: '20 minutes left for today\'s target',
            color: primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildFocusItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
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
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  label: 'Health Score',
                  value: '92',
                  subtext: '↑ 5 points',
                  color: primaryPink,
                ),
              ),
              Container(height: 40, width: 1, color: Colors.black12),
              Expanded(
                child: _buildMetricItem(
                  label: 'Consistency',
                  value: '8.5',
                  subtext: 'Top 15%',
                  color: primaryGreen,
                ),
              ),
              Container(height: 40, width: 1, color: Colors.black12),
              Expanded(
                child: _buildMetricItem(
                  label: 'Streak',
                  value: '5',
                  subtext: 'days',
                  color: Color(0xFFFFB946),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtext,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNutritionInsights() {
    return _buildInsightCard(
      title: 'Nutrition Analysis',
      icon: CupertinoIcons.chart_pie_fill,
      color: primaryPink,
      insights: [
        {
          'icon': CupertinoIcons.chart_bar_fill,
          'title': 'Macro Distribution',
          'description': 'Protein: 15% (Target: 20-25%)',
          'action': 'Add lean proteins to meals',
        },
        {
          'icon': CupertinoIcons.graph_circle_fill,
          'title': 'Calorie Timing',
          'description': '60% calories before 4 PM',
          'action': 'Better distribute daily calories',
        },
      ],
    );
  }

  Widget _buildExerciseAnalysis() {
    return _buildInsightCard(
      title: 'Exercise Impact',
      icon: CupertinoIcons.flame_fill,
      color: primaryGreen,
      insights: [
        {
          'icon': CupertinoIcons.arrow_up_right_circle_fill,
          'title': 'Workout Efficiency',
          'description': 'HIIT burns 30% more calories',
          'action': 'Increase HIIT frequency to 3x/week',
        },
        {
          'icon': CupertinoIcons.clock_fill,
          'title': 'Optimal Timing',
          'description': '45-min sessions most effective',
          'action': 'Maintain 45-min workout blocks',
        },
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> insights,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    insight['icon'] as IconData,
                    size: 16,
                    color: color,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        insight['description']!,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        insight['action']!,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildAnalysisItem(
            title: 'Exercise vs. Diet Impact',
            value: '40% Exercise, 60% Diet',
            trend: 'Balanced approach',
            color: primaryGreen,
          ),
          SizedBox(height: 12),
          _buildAnalysisItem(
            title: 'Recovery Quality',
            value: 'Optimal on rest days',
            trend: 'Sleep: 7.5h avg',
            color: primaryPink,
          ),
          SizedBox(height: 12),
          _buildAnalysisItem(
            title: 'Progress Rate',
            value: '0.5kg/week',
            trend: 'Sustainable pace',
            color: Color(0xFFFFB946),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem({
    required String title,
    required String value,
    required String trend,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPatterns() {
   return _buildInsightCard(
     title: 'Weekly Patterns',
     icon: CupertinoIcons.calendar,
     color: Color(0xFFFFB946),
     insights: [
       {
         'icon': CupertinoIcons.chart_bar_alt_fill,
         'title': 'Weekend Effect',
         'description': '35% higher calorie intake on weekends',
         'action': 'Plan weekend meals in advance',
       },
       {
         'icon': CupertinoIcons.arrow_right_circle_fill,
         'title': 'Strong Days',
         'description': 'Best performance on Tuesday & Thursday',
         'action': 'Schedule key workouts on strong days',
       },
     ],
   );
 }

 Widget _buildSmartRecommendations() {
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
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           children: [
             Icon(CupertinoIcons.lightbulb_fill, color: primaryGreen, size: 20),
             SizedBox(width: 8),
             Text(
               'Smart Recommendations',
               style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
                 color: Colors.black87,
               ),
             ),
           ],
         ),
         SizedBox(height: 16),
         _buildRecommendationItem(
           icon: CupertinoIcons.arrow_up_circle_fill,
           text: 'Increase protein at breakfast (target: 25-30g)',
           detail: 'Try eggs, Greek yogurt, or protein shake',
           color: primaryPink,
         ),
         SizedBox(height: 12),
         _buildRecommendationItem(
           icon: CupertinoIcons.timer,
           text: 'Schedule workouts before 10 AM',
           detail: '28% better performance in morning sessions',
           color: primaryGreen,
         ),
         SizedBox(height: 12),
         _buildRecommendationItem(
           icon: CupertinoIcons.arrow_down_circle_fill,
           text: 'Reduce evening snacking',
           detail: 'High correlation with daily calorie excess',
           color: Color(0xFFFFB946),
         ),
       ],
     ),
   );
 }

 Widget _buildRecommendationItem({
   required IconData icon,
   required String text,
   required String detail,
   required Color color,
 }) {
   return Row(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Container(
         padding: EdgeInsets.all(8),
         decoration: BoxDecoration(
           color: color.withOpacity(0.1),
           borderRadius: BorderRadius.circular(12),
         ),
         child: Icon(icon, color: color, size: 16),
       ),
       SizedBox(width: 12),
       Expanded(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               text,
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: Colors.black87,
               ),
             ),
             SizedBox(height: 2),
             Text(
               detail,
               style: TextStyle(
                 fontSize: 12,
                 color: Colors.black54,
               ),
             ),
           ],
         ),
       ),
     ],
   );
 }
}