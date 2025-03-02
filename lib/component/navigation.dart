import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';


class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isMenuOpen = false;

  int get currentIndex => _currentIndex;
  bool get isMenuOpen => _isMenuOpen;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleMenu() {
    _isMenuOpen = !_isMenuOpen;
    notifyListeners();
  }

  void closeMenu() {
    _isMenuOpen = false;
    notifyListeners();
  }
}

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  OverlayEntry? _overlayEntry;
  
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);

  void _showOverlay(BuildContext context, NavigationProvider navigationProvider) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                navigationProvider.closeMenu();
                _overlayEntry?.remove();
                _overlayEntry = null;
              },
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          
          // Floating Menu Buttons
          Positioned(
            bottom: 80,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: _buildFloatingButton(
                    icon: Icons.fitness_center,
                    color: primaryPink,
                    onTap: () {
                      navigationProvider.closeMenu();
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                      Navigator.pushNamed(context, '/add-exercise');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: _buildFloatingButton(
                    icon: Icons.lunch_dining,
                    color: primaryGreen,
                    onTap: () {
                      navigationProvider.closeMenu();
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                      Navigator.pushNamed(context, '/add-food');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!navigationProvider.isMenuOpen && _overlayEntry != null) {
            _overlayEntry?.remove();
            _overlayEntry = null;
          } else if (navigationProvider.isMenuOpen && _overlayEntry == null) {
            _showOverlay(context, navigationProvider);
          }
        });

        return SizedBox(
          height: 65,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Base Nav Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          isSelected: navigationProvider.currentIndex == 0,
                          onPressed: () {
                            navigationProvider.closeMenu();
                            navigationProvider.setIndex(0);
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.auto_graph_outlined,
                          label: 'Analytics',
                          isSelected: navigationProvider.currentIndex == 1,
                          onPressed: () {
                            navigationProvider.closeMenu();
                            navigationProvider.setIndex(1);
                            Navigator.pushReplacementNamed(context, '/analytic');
                          },
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.stars_outlined,
                          label: 'My Goals',
                          isSelected: navigationProvider.currentIndex == 3,
                          onPressed: () {
                            navigationProvider.closeMenu();
                            navigationProvider.setIndex(3);
                            Navigator.pushReplacementNamed(context, '/progress');
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.person_outline,
                          label: 'Account',
                          isSelected: navigationProvider.currentIndex == 4,
                          onPressed: () {
                            navigationProvider.closeMenu();
                            navigationProvider.setIndex(4);
                            Navigator.pushReplacementNamed(context, '/account');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add Button
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      navigationProvider.toggleMenu();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: navigationProvider.isMenuOpen 
                          ? primaryGreen 
                          : primaryPink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (navigationProvider.isMenuOpen 
                              ? primaryGreen 
                              : primaryPink).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: navigationProvider.isMenuOpen ? 0.125 : 0,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Add Log Text
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Text(
                  'Add Log',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: navigationProvider.isMenuOpen 
                      ? primaryGreen
                      : Colors.black54,
                    fontWeight: navigationProvider.isMenuOpen 
                      ? FontWeight.w500 
                      : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? primaryPink : Colors.black38,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? primaryPink : Colors.black38,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Material(
            color: Colors.transparent,
            child: Text(
              icon == Icons.fitness_center ? 'Exercise' : 'Food',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}