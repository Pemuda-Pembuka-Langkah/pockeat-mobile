import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/homepage/presentation/screens/overview_section.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_recent_section.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/recently_exercise_section.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';
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
  bool _shouldRefreshExerciseSection = false;

  Future<void> _checkDatabase() async {
    try {
      // Pakai document yang sama di semua environment
      final docRef =
          FirebaseFirestore.instance.collection('app_info').doc('db_type');
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
        
        // If switching to the exercises tab (index 2), trigger a rebuild
        if (_tabController.index == 2) {
          setState(() {
            _shouldRefreshExerciseSection = true;
          });
        } else {
          setState(() {
            _shouldRefreshExerciseSection = false;
          });
        }
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
    final exerciseLogHistoryRepository =
        Provider.of<ExerciseLogHistoryService>(context);
    final foodLogHistoryService =
        Provider.of<FoodLogHistoryService>(context);

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
                // Notifications icon
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notification-settings');
                  },
                ),
                // Wrap badges in a Flexible widget with Row to prevent overflow
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                    ],
                  ),
                ),
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
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              const OverviewSection(),
              FoodRecentSection(
                service: foodLogHistoryService,
              ),
              _shouldRefreshExerciseSection
                  ? RecentlyExerciseSection(
                      repository: exerciseLogHistoryRepository,
                      key: UniqueKey(),
                    )
                  : RecentlyExerciseSection(
                      repository: exerciseLogHistoryRepository,
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

// SliverPersistentHeaderDelegate for TabBar with dynamic height
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}