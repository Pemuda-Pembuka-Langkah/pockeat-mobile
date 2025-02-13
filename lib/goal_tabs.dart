import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class GoalsTab extends StatefulWidget {
  const GoalsTab({super.key});

  @override
  _GoalsTabState createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentGoalsSummary(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Weight Goals', primaryPink),
            const SizedBox(height: 16),
            _buildWeightGoalsCard(),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Exercise Goals', primaryGreen),
            const SizedBox(height: 16),
            _buildExerciseGoalsCard(),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Nutrition Goals', primaryPink),
            const SizedBox(height: 16),
            _buildNutritionGoalsCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentGoalsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryPink, primaryPink.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Goals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'On Track',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: 'Weight Goal',
                  value: '70.0 kg',
                  subtext: '3.0 kg to go',
                ),
              ),
              Container(height: 40, width: 1, color: Colors.white24),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Exercise',
                  value: '4/5',
                  subtext: 'workouts/week',
                ),
              ),
              Container(height: 40, width: 1, color: Colors.white24),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Timeline',
                  value: '35 days',
                  subtext: 'remaining',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required String subtext,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subtext,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {
            // Show edit dialog
          },
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                'Edit',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGoalRow(
            label: 'Current Weight',
            value: '73.0 kg',
            icon: CupertinoIcons.arrow_down,
            iconColor: primaryGreen,
            subtitle: '↓ 2.5 kg from start',
          ),
          const SizedBox(height: 16),
          
          _buildGoalRow(
            label: 'Target Weight',
            value: '70.0 kg',
            icon: CupertinoIcons.flag_fill,
            iconColor: primaryPink,
            subtitle: '3.0 kg to go',
          ),
          const SizedBox(height: 16),
          
          _buildGoalRow(
            label: 'Weekly Goal',
            value: '0.5 kg/week',
            icon: CupertinoIcons.chart_bar_fill,
            iconColor: const Color(0xFFFFB946),
            subtitle: 'Healthy rate',
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateColumn('Started', 'Dec 1, 2024'),
              _buildDateColumn('Target', 'Mar 1, 2025'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGoalRow(
            label: 'Weekly Workouts',
            value: '5 sessions',
            icon: CupertinoIcons.calendar,
            iconColor: primaryGreen,
            subtitle: '4/5 this week',
          ),
          const SizedBox(height: 16),

          _buildGoalRow(
            label: 'Duration/Session',
            value: '45 minutes',
            icon: CupertinoIcons.timer,
            iconColor: primaryPink,
            subtitle: 'Avg. 42 min',
          ),
          const SizedBox(height: 16),

          const Text(
            'Workout Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildExerciseTypeItem(
                  'Cardio',
                  '40%',
                  '2×/week',
                  primaryPink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExerciseTypeItem(
                  'Strength',
                  '40%',
                  '2×/week',
                  primaryGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExerciseTypeItem(
                  'HIIT',
                  '20%',
                  '1×/week',
                  const Color(0xFFFFB946),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),

          _buildGoalRow(
            label: 'Monthly Target',
            value: '20 workouts',
            icon: CupertinoIcons.flag_fill,
            iconColor: const Color(0xFFFFB946),
            subtitle: '15 completed',
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGoalRow(
            label: 'Daily Calories',
            value: '2,150 kcal',
            icon: CupertinoIcons.flame_fill,
            iconColor: primaryPink,
            subtitle: '92% adherence',
          ),
          const SizedBox(height: 20),

          const Text(
            'Macronutrient Goals',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMacroItem(
                  label: 'Protein',
                  percentage: '30%',
                  grams: '160g',
                  color: primaryPink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroItem(
                  label: 'Carbs',
                  percentage: '45%',
                  grams: '240g',
                  color: primaryGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroItem(
                  label: 'Fat',
                  percentage: '25%',
                  grams: '60g',
                  color: const Color(0xFFFFB946),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),

          const Text(
            'Additional Goals',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildNutrientRow('Fiber', '25g', 0.72, primaryGreen),
          const SizedBox(height: 8),
          _buildNutrientRow('Sugar', '<50g', 0.85, primaryPink),
          const SizedBox(height: 8),
          _buildNutrientRow('Sodium', '<2300mg', 0.65, const Color(0xFFFFB946)),
        ],
      ),
    );
  }



 Widget _buildGoalRow({
   required String label,
   required String value,
   required IconData icon,
   required Color iconColor,
   required String subtitle,
 }) {
   return Row(
     children: [
       Container(
         padding: const EdgeInsets.all(8),
         decoration: BoxDecoration(
           color: iconColor.withOpacity(0.1),
           borderRadius: BorderRadius.circular(8),
         ),
         child: Icon(
           icon,
           color: iconColor,
           size: 16,
         ),
       ),
       const SizedBox(width: 12),
       Expanded(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               label,
               style: const TextStyle(
                 color: Colors.black54,
                 fontSize: 12,
               ),
             ),
             Text(
               value,
               style: const TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
                 color: Colors.black87,
               ),
             ),
           ],
         ),
       ),
       Text(
         subtitle,
         style: const TextStyle(
           color: Colors.black54,
           fontSize: 12,
         ),
       ),
     ],
   );
 }

 Widget _buildDateColumn(String label, String date) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text(
         label,
         style: const TextStyle(
           color: Colors.black54,
           fontSize: 12,
         ),
       ),
       const SizedBox(height: 4),
       Text(
         date,
         style: const TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w500,
           color: Colors.black87,
         ),
       ),
     ],
   );
 }

 Widget _buildMacroItem({
   required String label,
   required String percentage,
   required String grams,
   required Color color,
 }) {
   return Container(
     padding: const EdgeInsets.all(12),
     decoration: BoxDecoration(
       color: color.withOpacity(0.1),
       borderRadius: BorderRadius.circular(12),
     ),
     child: Column(
       children: [
         Text(
           label,
           style: const TextStyle(
             color: Colors.black87,
             fontSize: 12,
           ),
         ),
         const SizedBox(height: 4),
         Text(
           percentage,
           style: TextStyle(
             color: color,
             fontSize: 16,
             fontWeight: FontWeight.w600,
           ),
         ),
         const SizedBox(height: 2),
         Text(
           grams,
           style: const TextStyle(
             color: Colors.black54,
             fontSize: 12,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildExerciseTypeItem(
   String type,
   String percentage,
   String frequency,
   Color color,
 ) {
   return Container(
     padding: const EdgeInsets.all(12),
     decoration: BoxDecoration(
       color: color.withOpacity(0.1),
       borderRadius: BorderRadius.circular(12),
     ),
     child: Column(
       children: [
         Text(
           type,
           style: const TextStyle(
             color: Colors.black87,
             fontSize: 12,
           ),
         ),
         const SizedBox(height: 4),
         Text(
           percentage,
           style: TextStyle(
             color: color,
             fontSize: 16,
             fontWeight: FontWeight.w600,
           ),
         ),
         const SizedBox(height: 2),
         Text(
           frequency,
           style: const TextStyle(
             color: Colors.black54,
             fontSize: 12,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildNutrientRow(
   String nutrient,
   String target,
   double progress,
   Color color,
 ) {
   return Row(
     children: [
       Expanded(
         flex: 2,
         child: Text(
           nutrient,
           style: const TextStyle(
             fontSize: 14,
             color: Colors.black87,
           ),
         ),
       ),
       Expanded(
         flex: 1,
         child: Text(
           target,
           style: const TextStyle(
             fontSize: 14,
             fontWeight: FontWeight.w500,
             color: Colors.black54,
           ),
         ),
       ),
       Expanded(
         flex: 2,
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
   );
 }
}