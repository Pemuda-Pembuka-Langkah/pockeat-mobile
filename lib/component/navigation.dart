// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// ignore: depend_on_referenced_packages

// coverage:ignore-start
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

  void _showOverlay(
      BuildContext context, NavigationProvider navigationProvider) {
    // Temukan posisi tombol add saat ini
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    renderBox?.localToGlobal(Offset.zero);

    // Perkirakan posisi tombol berdasarkan layar
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonRightPosition = screenWidth * 0.04 +
        75.0; // Perkiraan jarak tombol dari sisi kanan + ukuran tombol

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

          // Exercise Button (Barat Laut / Pojok Kiri Atas relatif terhadap tombol add)
          Positioned(
            bottom: 80, // Lebih tinggi dari tombol add
            right: buttonRightPosition + 25, // Ke kiri dari tombol add
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

          // Food Button (Utara / Atas relatif terhadap tombol add)
          Positioned(
            bottom: 120, // Lebih tinggi dari tombol add dan exercise
            right: buttonRightPosition - 50, // Sejajar dengan tombol add
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

        const addButtonSize = 80.0; // Even larger button size

        return SizedBox(
          height: 60, // Meningkatkan height agar mencakup seluruh tombol add
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
                            if (navigationProvider.currentIndex != 0) {
                              navigationProvider.setIndex(0);
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.auto_graph_outlined,
                          label: 'Progress',
                          isSelected: navigationProvider.currentIndex == 1,
                          onPressed: () {
                            navigationProvider.closeMenu();
                            if (navigationProvider.currentIndex != 1) {
                              navigationProvider.setIndex(1);
                              Navigator.pushReplacementNamed(
                                  context, '/analytic');
                            }
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
                            if (navigationProvider.currentIndex != 4) {
                              navigationProvider.setIndex(4);
                              Navigator.pushReplacementNamed(
                                  context, '/profile');
                            }
                          },
                        ),
                      ),
                      // Ruang kosong diganti dengan tombol "+" yang tidak terlihat (untuk menjaga layout)
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ),

              // Prominent "+ Add" Button positioned at the right side
              Positioned(
                bottom: 20.0, // Tetap positioned higher agar menonjol
                right: MediaQuery.of(context).size.width *
                    0.05, // Sedikit masuk dari tepi kanan
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      navigationProvider.toggleMenu();
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: addButtonSize,
                      height: addButtonSize,
                      decoration: BoxDecoration(
                        color: navigationProvider.isMenuOpen
                            ? primaryGreen
                            : primaryPink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (navigationProvider.isMenuOpen
                                    ? primaryGreen
                                    : primaryPink)
                                .withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
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
                          size: 36, // Ukuran ikon tetap sama
                        ),
                      ),
                    ),
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
            size: 28, // Ukuran ikon diperbesar dari 24 menjadi 28
            color: isSelected ? primaryPink : Colors.black38,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, // Sedikit memperbesar ukuran font label
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
// coverage:ignore-end
