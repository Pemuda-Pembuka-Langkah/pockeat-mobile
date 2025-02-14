import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/navigation.dart';
import 'package:pockeat/overview_section.dart';
import 'package:pockeat/recently_exercise_section.dart';
import 'package:pockeat/recently_foods_section.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  String? dbInfo;

  Future<void> _checkDatabase() async {
    try {
      // Pakai document yang sama di semua environment
      final docRef = FirebaseFirestore.instance.collection('app_info').doc('db_type');
      // Read balik untuk konfirmasi
      final doc = await docRef.get();
      setState(() {
        dbInfo = doc.data()?['name'];
      });
    } catch (e) {
      setState(() {
        dbInfo = 'Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NavigationProvider>(context, listen: false).setIndex(0);
    });
    _checkDatabase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: primaryYellow,
              elevation: 0,
              toolbarHeight: 60,
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Image.asset(
                      'assets/images/icon.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pockeat',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                _buildStatBadge(
                  icon: Icons.favorite,
                  value: "95",
                  color: primaryPink,
                ),
                const SizedBox(width: 8),
                _buildStatBadge(
                  icon: Icons.star,
                  value: "8",
                  color: const Color(0xFFFFB946),
                ),
                const SizedBox(width: 8),
                _buildStatBadge(
                  icon: Icons.monetization_on,
                  value: "2,350",
                  color: const Color(0xFFFFD700),
                ),
                const SizedBox(width: 12),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                color: primaryYellow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 90,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          bool isToday = index == 0;
                          return Container(
                            width: 55,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isToday ? primaryPink : Colors.white,
                              border: Border.all(
                                color: isToday ? primaryPink : Colors.black12,
                              ),
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
                                  [
                                    'Today',
                                    'Thu',
                                    'Wed',
                                    'Tue',
                                    'Mon',
                                    'Sun',
                                    'Sat'
                                  ][index],
                                  style: TextStyle(
                                    color:
                                        isToday ? Colors.white : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    '24',
                                    '23',
                                    '22',
                                    '21',
                                    '20',
                                    '19',
                                    '18'
                                  ][index],
                                  style: TextStyle(
                                    color:
                                        isToday ? Colors.white : Colors.black87,
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
                     Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Alex Connected to: ${dbInfo ?? 'Loading...'}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'You\'re doing great today! Keep up with your healthy eating habits.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Colors.white,
              toolbarHeight: 0,
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black38,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                indicatorColor: primaryPink,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                tabs: const [
                  Text('Overview'),
                  Text('Recently Foods'),
                  Text('Exercises'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: const [
              OverviewSection(),
              RecentlyFoodsSection(),
              RecentExerciseSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
