import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';

void main() {
  group('AppColors', () {
    test('should create an instance with the given colors', () {
      // Arrange
      const Color testYellow = Color(0xFFFFAA00);
      const Color testPink = Color(0xFFFF00AA);
      const Color testGreen = Color(0xFF00FFAA);
      
      // Act
      final appColors = AppColors(
        primaryYellow: testYellow,
        primaryPink: testPink,
        primaryGreen: testGreen,
      );
      
      // Assert
      expect(appColors, isNotNull);
      expect(appColors, isA<AppColors>());
      expect(appColors.primaryYellow, equals(testYellow));
      expect(appColors.primaryPink, equals(testPink));
      expect(appColors.primaryGreen, equals(testGreen));
    });

    test('defaultColors should return correct default color values', () {
      // Act
      final defaultColors = AppColors.defaultColors();
      
      // Assert
      expect(defaultColors, isNotNull);
      expect(defaultColors, isA<AppColors>());
      expect(defaultColors.primaryYellow, equals(const Color(0xFFFFE893)));
      expect(defaultColors.primaryPink, equals(const Color(0xFFFF6B6B)));
      expect(defaultColors.primaryGreen, equals(const Color(0xFF4ECDC4)));
    });
    
    test('color properties should be correctly assigned and accessible', () {
      // Arrange
      final colors = AppColors.defaultColors();
      
      // Act & Assert - Testing that properties are accessible and have correct types
      expect(colors.primaryYellow, isA<Color>());
      expect(colors.primaryPink, isA<Color>());
      expect(colors.primaryGreen, isA<Color>());
      
      // Verify color values match their RGB components
      expect(colors.primaryYellow.red, equals(255));
      expect(colors.primaryYellow.green, equals(232));
      expect(colors.primaryYellow.blue, equals(147));
      
      expect(colors.primaryPink.red, equals(255));
      expect(colors.primaryPink.green, equals(107));
      expect(colors.primaryPink.blue, equals(107));
      
      expect(colors.primaryGreen.red, equals(78));
      expect(colors.primaryGreen.green, equals(205));
      expect(colors.primaryGreen.blue, equals(196));
    });
    
    test('should allow creating AppColors with specific alpha values', () {
      // Arrange & Act
      final colorsWithAlpha = AppColors(
        primaryYellow: const Color(0x80FFE893), // 50% transparent yellow
        primaryPink: const Color(0xA0FF6B6B),   // ~63% transparent pink
        primaryGreen: const Color(0xFF4ECDC4),  // Fully opaque green
      );
      
      // Assert
      expect(colorsWithAlpha.primaryYellow.alpha, equals(128)); // 0x80 = 128
      expect(colorsWithAlpha.primaryPink.alpha, equals(160));   // 0xA0 = 160
      expect(colorsWithAlpha.primaryGreen.alpha, equals(255));  // 0xFF = 255 (fully opaque)
    });
  });
}