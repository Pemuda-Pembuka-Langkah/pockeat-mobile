import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RecentExerciseSection extends StatefulWidget {
  const RecentExerciseSection({super.key});

  @override
  _RecentExerciseSectionState createState() => _RecentExerciseSectionState();
}

class _RecentExerciseSectionState extends State<RecentExerciseSection> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color purpleColor = const Color(0xFF9B6BFF);
  final Color coinColor = const Color(0xFFFFD700);

  // Sample data for recent exercises
  final List<Map<String, dynamic>> recentExercises = [
    {
      'type': 'running',
      'title': 'Evening Run',
      'subtitle': '5.2 km • 350 cal',
      'time': '2h ago',
      'color': const Color(0xFFFF6B6B),
      'icon': Icons.directions_run,
      'reward': {'coins': 150, 'exp': 200},
      'streakDay': 3,
    },
    {
      'type': 'weightlifting',
      'title': 'Upper Body',
      'subtitle': '6 exercises • 280 cal',
      'time': '1d ago',
      'color': const Color(0xFF4ECDC4),
      'icon': CupertinoIcons.arrow_up_circle_fill,
      'reward': {'coins': 200, 'exp': 250},
      'streakDay': 2,
    },
    {
      'type': 'smart_workout',
      'title': 'HIIT Session',
      'subtitle': '25 min • 320 cal',
      'time': '2d ago',
      'color': const Color(0xFF9B6BFF),
      'icon': CupertinoIcons.text_badge_checkmark,
      'reward': {'coins': 180, 'exp': 220},
      'streakDay': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Exercises',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Show All',
                  style: TextStyle(
                    color: primaryPink,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentExercises.length,
          itemBuilder: (context, index) => _buildExerciseCard(recentExercises[index]),
        ),
      ],
    
    ));
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
      child: InkWell(
        onTap: () {
          // Navigate to detail page
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: exercise['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      exercise['icon'],
                      color: exercise['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Exercise Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exercise['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              exercise['time'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise['subtitle'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Rewards Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: exercise['color'].withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Streak
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: primaryPink,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise['streakDay']} day streak!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Rewards
                    Row(
                      children: [
                        _buildRewardBadge(
                          Icons.monetization_on,
                          '+${exercise['reward']['coins']}',
                          coinColor,
                        ),
                        const SizedBox(width: 8),
                        _buildRewardBadge(
                          Icons.stars,
                          '+${exercise['reward']['exp']}',
                          exercise['color'],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
  }

  Widget _buildRewardBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}