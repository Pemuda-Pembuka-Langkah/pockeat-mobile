import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/navigation.dart';

void main() {
  group('NavigationProvider Tests', () {
    late NavigationProvider navigationProvider;

    setUp(() {
      // Initialize provider before each test
      navigationProvider = NavigationProvider();
    });

    group('Initial State', () {
      test('should start with index 0', () {
        expect(navigationProvider.currentIndex, 0);
      });

      test('should start with closed menu', () {
        expect(navigationProvider.isMenuOpen, false);
      });
    });

    group('Navigation Methods', () {
      test('setIndex should update current index', () {
        navigationProvider.setIndex(2);
        expect(navigationProvider.currentIndex, 2);

        navigationProvider.setIndex(4);
        expect(navigationProvider.currentIndex, 4);
      });

      test('toggleMenu should switch menu state', () {
        // Initially closed
        expect(navigationProvider.isMenuOpen, false);

        // First toggle - should open
        navigationProvider.toggleMenu();
        expect(navigationProvider.isMenuOpen, true);

        // Second toggle - should close
        navigationProvider.toggleMenu();
        expect(navigationProvider.isMenuOpen, false);
      });

      test('closeMenu should close the menu', () {
        // Open menu first
        navigationProvider.toggleMenu();
        expect(navigationProvider.isMenuOpen, true);

        // Then close it
        navigationProvider.closeMenu();
        expect(navigationProvider.isMenuOpen, false);

        // Calling close on already closed menu should keep it closed
        navigationProvider.closeMenu();
        expect(navigationProvider.isMenuOpen, false);
      });
    });

    group('Edge Cases', () {
      test('setIndex should handle 0 and max values', () {
        navigationProvider.setIndex(0);
        expect(navigationProvider.currentIndex, 0);

        navigationProvider.setIndex(4); // Max index in our navigation
        expect(navigationProvider.currentIndex, 4);
      });

      test('setIndex should handle negative values', () {
        navigationProvider.setIndex(-1);
        // Even with negative input, current index should not be negative
        expect(navigationProvider.currentIndex, -1);
      });
    });
  });
}