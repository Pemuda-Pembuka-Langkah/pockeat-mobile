import 'package:flutter/material.dart';

class RecentlyFoodsSection extends StatefulWidget {
  const RecentlyFoodsSection({super.key});

  @override
  State<RecentlyFoodsSection> createState() => _RecentlyFoodsSectionState();
}

class _RecentlyFoodsSectionState extends State<RecentlyFoodsSection> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color coinColor = const Color(0xFFFFD700);
  
  Set<String> favorites = {'Chicken Breast'};

  void toggleFavorite(String foodName) {
    setState(() {
      if (favorites.contains(foodName)) {
        favorites.remove(foodName);
      } else {
        favorites.add(foodName);
        // Reward for adding favorites
        _showRewardDialog('Favorite Added!', '+20', 'coins');
      }
    });
  }

  void _showRewardDialog(String title, String amount, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == 'coins' ? Icons.monetization_on : Icons.stars,
                color: type == 'coins' ? coinColor : primaryYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$title $amount',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> historyFoods = [
    {
      'name': 'Chicken Breast',
      'calories': '165 kcal',
      'time': '2h ago',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrpy00P1laaOiH3FH1oCWKtH8BMse2DYIdNA&s',
      'reward': {'coins': 30, 'exp': 50},
      'tags': ['protein', 'healthy'],
    },
    {
      'name': 'Greek Yogurt',
      'calories': '120 kcal',
      'time': '5h ago',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQgaxyc2sEiB4Jw1SZA_gctZJB7rcKpFrsi4A&s',
      'reward': {'coins': 25, 'exp': 40},
      'tags': ['protein', 'dairy'],
    },
    {
      'name': 'Quinoa Bowl',
      'calories': '220 kcal',
      'time': '8h ago',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYYUoL0TPXAcPVfGooZRYBpbA8UPGKreSK5g&s',
      'reward': {'coins': 35, 'exp': 60},
      'tags': ['healthy', 'grain'],
    },
  ];

  final List<Map<String, dynamic>> quickAddFoods = [
    {
      'name': 'White Rice',
      'calories': '204 kcal',
      'portion': '1 portion',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSsoXPqMWeu76TgfRXiFLnV7vEee0Wdr8uCXA&s',
      'reward': {'coins': 20, 'exp': 30},
    },
    {
      'name': 'Black Coffee',
      'calories': '2 kcal',
      'portion': '1 cup',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6YA5A1gM-Ja6KMWoH5D4e0x_ikGg0mHcMpA&s',
      'reward': {'coins': 15, 'exp': 25},
    },
    {
      'name': 'White Bread',
      'calories': '160 kcal',
      'portion': '2 sheet',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRy6LIwYTLHVj9wTIn3whrgfXGQWXAoGJ1eZQ&s',
      'reward': {'coins': 20, 'exp': 30},
    },
  ];

  Widget _buildSectionTitle(String title, {bool showAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (showAll)
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
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> food) {
    bool isFavorite = favorites.contains(food['name']);
    List<String> tags = food['tags'] ?? [];
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              food['image']!,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 160,
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryPink),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 160,
                  color: Colors.grey[100],
                  child: Icon(Icons.restaurant, color: primaryPink, size: 32),
                );
              },
            ),
          ),
          // Favorite Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => toggleFavorite(food['name']!),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isFavorite ? primaryPink : Colors.grey[400],
                ),
              ),
            ),
          ),
          // Reward Badge
          if (food['reward'] != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.monetization_on, color: coinColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+${food['reward']['coins']}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Food Info
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          color: primaryPink, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        food['calories']!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: primaryGreen, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        food['time']!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildQuickAddCard(Map<String, dynamic> food) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  food['image']!,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryPink),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.grey[100],
                      child: Icon(Icons.restaurant, color: primaryPink, size: 32),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: primaryPink, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          food['calories']!,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (food['reward'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.monetization_on,
                              color: coinColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+${food['reward']['coins']}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // Show reward notification when food is added
                if (food['reward'] != null) {
                  _showRewardDialog(
                    'Food Added!',
                    '+${food['reward']['coins']}',
                    'coins',
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: primaryPink,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // History Section with Show All
        _buildSectionTitle('History', showAll: true),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: historyFoods.length,
            itemBuilder: (context, index) => _buildHistoryCard(historyFoods[index]),
          ),
        ),

        // Quick Add Section
        _buildSectionTitle('Quick Add'),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: quickAddFoods.length,
            itemBuilder: (context, index) => _buildQuickAddCard(quickAddFoods[index]),
          ),
        ),

        // Favorites Section with Show All
        if (favorites.isNotEmpty) ...[
          _buildSectionTitle('Favorites', showAll: true),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: historyFoods.where((food) => 
                favorites.contains(food['name'])).length,
              itemBuilder: (context, index) {
                final favFood = historyFoods.where((food) => 
                  favorites.contains(food['name'])).toList()[index];
                return _buildHistoryCard(favFood);
              },
            ),
          ),
        ],
      ],
    );
  }
}