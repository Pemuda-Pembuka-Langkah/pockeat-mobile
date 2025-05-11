// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/authentication/domain/model/feature_card.dart';

void main() {
  group('FeatureCard', () {
    // Test constants
    const testIcon1 = Icons.fitness_center;
    const testIcon2 = Icons.restaurant;
    const testColor1 = Colors.blue;
    const testColor2 = Colors.green;
    const testTitle1 = 'Test Title 1';
    const testTitle2 = 'Test Title 2';
    const testSubtitle1 = 'Test Subtitle 1';
    const testSubtitle2 = 'Test Subtitle 2';

    test('should create a FeatureCard with all required parameters', () {
      // Arrange & Act
      final featureCard = FeatureCard(
        icon: testIcon1,
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle1,
      );

      // Assert
      expect(featureCard, isA<FeatureCard>());
      expect(featureCard.icon, equals(testIcon1));
      expect(featureCard.iconColor, equals(testColor1));
      expect(featureCard.title, equals(testTitle1));
      expect(featureCard.subtitle, equals(testSubtitle1));
    });

    test('should handle different IconData values', () {
      // Arrange & Act
      final featureCard1 = FeatureCard(
        icon: testIcon1,
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle1,
      );
      
      final featureCard2 = FeatureCard(
        icon: testIcon2,
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle1,
      );

      // Assert
      expect(featureCard1.icon, equals(testIcon1));
      expect(featureCard2.icon, equals(testIcon2));
      expect(featureCard1.icon, isNot(equals(featureCard2.icon)));
    });

    test('should handle different Color values', () {
      // Arrange & Act
      final featureCard1 = FeatureCard(
        icon: testIcon1,
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle1,
      );
      
      final featureCard2 = FeatureCard(
        icon: testIcon1,
        iconColor: testColor2,
        title: testTitle1,
        subtitle: testSubtitle1,
      );

      // Assert
      expect(featureCard1.iconColor, equals(testColor1));
      expect(featureCard2.iconColor, equals(testColor2));
      expect(featureCard1.iconColor, isNot(equals(featureCard2.iconColor)));
    });

    test('should handle different title values', () {
      // Arrange & Act
      final featureCard1 = FeatureCard(
        icon: testIcon1,
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle1,
      );
      
      final featureCard2 = FeatureCard(
        icon: testIcon1,
        iconColor: testColor1,
        title: testTitle2,
        subtitle: testSubtitle1,
      );

      // Assert
      expect(featureCard1.title, equals(testTitle1));
      expect(featureCard2.title, equals(testTitle2));
      expect(featureCard1.title, isNot(equals(featureCard2.title)));
    });

    test('should handle different subtitle values', () {
      // Arrange & Act
      final featureCard1 = FeatureCard(
        icon: testIcon1,
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle1,
      );
      
      final featureCard2 = FeatureCard(
        icon: testIcon1, 
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle2,
      );

      // Assert
      expect(featureCard1.subtitle, equals(testSubtitle1));
      expect(featureCard2.subtitle, equals(testSubtitle2));
      expect(featureCard1.subtitle, isNot(equals(featureCard2.subtitle)));
    });

    test('should create multiple different FeatureCard instances', () {
      // Arrange & Act
      final featureCard1 = FeatureCard(
        icon: testIcon1,
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle1,
      );
      
      final featureCard2 = FeatureCard(
        icon: testIcon2,
        iconColor: testColor2,
        title: testTitle2,
        subtitle: testSubtitle2,
      );

      // Assert - all properties should be different
      expect(featureCard1.icon, isNot(equals(featureCard2.icon)));
      expect(featureCard1.iconColor, isNot(equals(featureCard2.iconColor)));
      expect(featureCard1.title, isNot(equals(featureCard2.title)));
      expect(featureCard1.subtitle, isNot(equals(featureCard2.subtitle)));
    });

    test('should handle complex IconData', () {
      // Arrange
      const complexIcon = Icons.add_circle_outline_rounded;
      
      // Act
      final featureCard = FeatureCard(
        icon: complexIcon,
        iconColor: testColor1,
        title: testTitle1,
        subtitle: testSubtitle1,
      );
      
      // Assert
      expect(featureCard.icon, equals(complexIcon));
    });

    test('should handle complex Color objects', () {
      // Arrange
      const complexColor = Color.fromARGB(255, 128, 64, 192);
      
      // Act
      final featureCard = FeatureCard(
        icon: testIcon1,
        iconColor: complexColor, 
        title: testTitle1,
        subtitle: testSubtitle1,
      );
      
      // Assert
      expect(featureCard.iconColor, equals(complexColor));
    });

    test('should handle multiline text in title and subtitle', () {
      // Arrange
      const multilineTitle = 'Title with\nmultiple lines';
      const multilineSubtitle = 'Subtitle with\nmultiple lines\nand more lines';
      
      // Act
      final featureCard = FeatureCard(
        icon: testIcon1,
        iconColor: testColor1,
        title: multilineTitle,
        subtitle: multilineSubtitle,
      );
      
      // Assert
      expect(featureCard.title, equals(multilineTitle));
      expect(featureCard.subtitle, equals(multilineSubtitle));
    });
  });
}
