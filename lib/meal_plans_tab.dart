import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MealPlansTab extends StatefulWidget {
  const MealPlansTab({super.key});

  @override
  _MealPlansTabState createState() => _MealPlansTabState();
}

class _MealPlansTabState extends State<MealPlansTab> {
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
                      'Weekly Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today, size: 16, color: primaryPink),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.bookmark_outline, color: primaryPink),
                    const SizedBox(width: 16),
                    Icon(Icons.share_outlined, color: primaryPink),
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
                colors: [primaryPink, primaryPink.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(CupertinoIcons.sparkles, 'AI Generate'),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildQuickAction(CupertinoIcons.square_list, 'Templates'),
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
                    color: isToday ? primaryPink : Colors.white,
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

          // Today's Meal Summary
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
                _buildMealDot('Breakfast', '350', primaryPink),
                const SizedBox(height: 12),
                _buildMealDot('Lunch', '650', primaryGreen),
                const SizedBox(height: 12),
                _buildMealDot('Dinner', '550', primaryPink),
                const SizedBox(height: 12),
                _buildMealDot('Snacks', '200', primaryGreen),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Today's Plan Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Today's Plan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Breakfast
          _buildMealTimeCard(
            title: 'Breakfast',
            time: '06:00 - 09:00',
            calories: '350',
            color: primaryPink,
            meals: [
              _buildMealItem(
                name: 'Oatmeal with Fruits',
                portion: '1 bowl (240g)',
                calories: '220',
                imagePath: '/api/placeholder/48/48',
                recipe: true,
              ),
              _buildMealItem(
                name: 'Greek Yogurt',
                portion: '1 cup (170g)',
                calories: '130',
                imagePath: '/api/placeholder/48/48',
                recipe: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lunch
          _buildMealTimeCard(
            title: 'Lunch',
            time: '12:00 - 14:00',
            calories: '650',
            color: primaryGreen,
            meals: [
              _buildMealItem(
                name: 'Grilled Chicken Salad',
                portion: '1 serving (350g)',
                calories: '420',
                imagePath: '/api/placeholder/48/48',
                recipe: true,
              ),
              _buildMealItem(
                name: 'Whole Grain Bread',
                portion: '2 slices',
                calories: '230',
                imagePath: '/api/placeholder/48/48',
                recipe: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dinner
          _buildMealTimeCard(
            title: 'Dinner',
            time: '18:00 - 20:00',
            calories: '550',
            color: primaryPink,
            meals: [
              _buildMealItem(
                name: 'Salmon with Quinoa',
                portion: '1 serving (300g)',
                calories: '550',
                imagePath: '/api/placeholder/48/48',
                recipe: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Snacks
          _buildMealTimeCard(
            title: 'Snacks',
            time: 'Any Time',
            calories: '200',
            color: primaryGreen,
            meals: [
              _buildMealItem(
                name: 'Mixed Nuts',
                portion: '30g',
                calories: '120',
                imagePath: '/api/placeholder/48/48',
                recipe: false,
              ),
              _buildMealItem(
                name: 'Apple',
                portion: '1 medium',
                calories: '80',
                imagePath: '/api/placeholder/48/48',
                recipe: false,
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

  Widget _buildMealDot(String label, String calories, Color color) {
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
          '$calories kcal',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTimeCard({
    required String title,
    required String time,
    required String calories,
    required Color color,
    required List<Widget> meals,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$calories kcal',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...meals,
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem({
    required String name,
    required String portion,
    required String calories,
    required String imagePath,
    required bool recipe,
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
              Icons.restaurant_outlined,
              color: primaryPink,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    if (recipe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.receipt_long,
                        size: 16,
                        color: primaryGreen,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  portion,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '$calories kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black38),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}