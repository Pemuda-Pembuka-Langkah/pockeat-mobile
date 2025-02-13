import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ExercisePlanTab extends StatefulWidget {
  const ExercisePlanTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExercisePlanTabState createState() => _ExercisePlanTabState();
}

class _ExercisePlanTabState extends State<ExercisePlanTab> {
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Weekly Workout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today, size: 16, color: primaryGreen),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.bookmark_outline, color: primaryGreen),
                    const SizedBox(width: 16),
                    Icon(Icons.share_outlined, color: primaryGreen),
                  ],
                ),
              ],
            ),
          ),

          // Quick Actions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(CupertinoIcons.sparkles, 'AI Workout'),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildQuickAction(CupertinoIcons.square_list, 'Programs'),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildQuickAction(CupertinoIcons.plus, 'Custom'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Weekly Calendar
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final dates = ['20', '21', '22', '23', '24', '25', '26'];
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                bool isToday = dates[index] == '24';

                return Container(
                  width: 55,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isToday ? primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dates[index],
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Today's Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkoutDot('Morning Run', '30 min', primaryGreen),
                const SizedBox(height: 12),
                _buildWorkoutDot('Upper Body', '45 min', primaryPink),
                const SizedBox(height: 12),
                _buildWorkoutDot('Yoga', '20 min', primaryGreen),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Today's Workouts
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Today's Workouts",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Morning Run
          _buildWorkoutCard(
            title: 'Morning Run',
            time: '06:00 - 06:30',
            duration: '30',
            type: 'Cardio',
            color: primaryGreen,
            exercises: [
              _buildExerciseItem(
                name: '5K Run',
                target: 'Pace: 5:30/km',
                details: '350 calories',
                icon: Icons.directions_run,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Upper Body Workout
          _buildWorkoutCard(
            title: 'Upper Body',
            time: '08:00 - 08:45',
            duration: '45',
            type: 'Strength',
            color: primaryPink,
            exercises: [
              _buildExerciseItem(
                name: 'Push-ups',
                target: '3 sets × 15 reps',
                details: 'Body weight',
                icon: Icons.fitness_center,
              ),
              _buildExerciseItem(
                name: 'Dumbbell Rows',
                target: '3 sets × 12 reps',
                details: '10 kg each',
                icon: Icons.fitness_center,
              ),
              _buildExerciseItem(
                name: 'Shoulder Press',
                target: '3 sets × 12 reps',
                details: '8 kg each',
                icon: Icons.fitness_center,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Evening Yoga
          _buildWorkoutCard(
            title: 'Evening Yoga',
            time: '18:00 - 18:20',
            duration: '20',
            type: 'Flexibility',
            color: primaryGreen,
            exercises: [
              _buildExerciseItem(
                name: 'Sun Salutation',
                target: '10 minutes',
                details: 'Full sequence',
                icon: Icons.self_improvement,
              ),
              _buildExerciseItem(
                name: 'Standing Poses',
                target: '5 minutes',
                details: 'Balance focus',
                icon: Icons.self_improvement,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutDot(String label, String duration, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          duration,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard({
    required String title,
    required String time,
    required String duration,
    required String type,
    required Color color,
    required List<Widget> exercises,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$duration min',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ...exercises,
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem({
    required String name,
    required String target,
    required String details,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryYellow.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  target,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            details,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}