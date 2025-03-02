import 'package:flutter/material.dart';

class PetStorePage extends StatefulWidget {
  const PetStorePage({super.key});

  @override
  _PetStorePageState createState() => _PetStorePageState();
}

class _PetStorePageState extends State<PetStorePage> {
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color coinColor = const Color(0xFFFFD700);

  String selectedCategory = 'Accessories';

  final List<String> categories = [
    'Accessories',
    'Outfits',
    'Backgrounds',
    'Colors',
  ];

  final Map<String, List<Map<String, dynamic>>> storeItems = {
    'Accessories': [
      {
        'name': 'Sports Headband',
        'description': 'Perfect for workouts!',
        'price': 500,
        'image': 'assets/images/headband.jpg',
        'isNew': true,
      },
      {
        'name': 'Cool Sunglasses',
        'description': 'Stay cool and motivated',
        'price': 800,
        'image': 'assets/images/sunglasses.jpg',
        'isNew': false,
      },
      {
        'name': 'Winter Scarf',
        'description': 'Cozy and stylish',
        'price': 600,
        'image': 'assets/images/scraf.jpg',
        'isNew': true,
      },
    ],
    'Outfits': [
      {
        'name': 'Gym Outfit',
        'description': 'Ready for action!',
        'price': 1200,
        'image': 'assets/images/gym_outfit.jpg',
        'isNew': true,
      },
    ],
    'Backgrounds': [
      {
        'name': 'Gym Background',
        'description': 'Train in style',
        'price': 1000,
        'image': 'assets/images/gym_bg.jpg',
        'isNew': false,
      },
      {
        'name': 'Nature Park',
        'description': 'Peaceful outdoor vibes',
        'price': 1000,
        'image': 'assets/images/park_bg.jpg',
        'isNew': true,
      },
    ],
    'Colors': [
      {
        'name': 'Ocean Blue',
        'description': 'Cool and refreshing',
        'price': 2000,
        'image': 'assets/images/blue_color.jpg',
        'isNew': false,
      },
      {
        'name': 'Sunset Orange',
        'description': 'Warm and energetic',
        'price': 2000,
        'image': 'assets/images/orange_color.jpg',
        'isNew': true,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pet Shop',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: coinColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: coinColor, size: 16),
                const SizedBox(width: 4),
                const Text(
                  '2,350',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPetPreview(),
          _buildCategorySelector(),
          Expanded(
            child: _buildItemGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildPetPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/kucing.png',
              height: 150,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.camera_alt, color: primaryPink, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? primaryPink : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryPink : Colors.black12,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemGrid() {
    final items = storeItems[selectedCategory] ?? [];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildStoreItem(item);
      },
    );
  }

  Widget _buildStoreItem(Map<String, dynamic> item) {
    return Container(
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
  height: 120,
  width: double.infinity,
  decoration: BoxDecoration(
    color: primaryYellow.withOpacity(0.1),
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(16),
    ),
  ),
  child: ClipRRect(
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(16),
    ),
    child: item['image'] != null ? Image.asset(
      item['image'],
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.image,
            size: 40,
            color: primaryYellow,
          ),
        );
      },
    ) : Center(
      child: Icon(
        Icons.image,
        size: 40,
        color: primaryYellow,
      ),
    ),
  ),
),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: coinColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item['price']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item['isNew'])
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}