// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/component/navigation.dart';
import 'package:pockeat/features/homepage/presentation/screens/overview_section.dart';
import 'package:pockeat/features/homepage/presentation/screens/pet_homepage_section.dart';

// ignore: depend_on_referenced_packages

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  String? dbInfo;

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
                    title: const Row(
                      children: [
                        Text(
                          'Pockeat',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              children: const [
                PetHomepageSection(),
                OverviewSection(),
              ],
            )),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
