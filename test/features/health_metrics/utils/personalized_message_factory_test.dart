// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/health_metrics/utils/personalized_message_factory.dart';

void main() {
  group('PersonalizedMessageFactory', () {
    test('should create weight loss message when goals contain "lose"', () {
      // Arrange - create list with weight loss goal
      final goals = ['Lose weight', 'Improve fitness'];
      
      // Act - call the factory method
      final result = PersonalizedMessageFactory.createFromGoals(goals);
      
      // Assert - verify the correct message is returned
      expect(result.title, equals('Weight Loss Journey'));
      expect(result.message, equals('You\'re on your way to a healthier, lighter you! Your plan is designed for sustainable results.'));
      expect(result.iconData, equals(Icons.trending_down));
    });
    
    test('should create strength message when goals contain "gain"', () {
      // Arrange - create list with weight gain goal
      final goals = ['Gain muscle', 'Build strength'];
      
      // Act - call the factory method
      final result = PersonalizedMessageFactory.createFromGoals(goals);
      
      // Assert - verify the correct message is returned
      expect(result.title, equals('Building Strength'));
      expect(result.message, equals('Get ready to build strength and energy! Your nutrition plan supports your muscle growth goals.'));
      expect(result.iconData, equals(Icons.fitness_center));
    });
    
    test('should create balance message for maintenance goals', () {
      // Arrange - create list with maintenance goal
      final goals = ['Maintain weight', 'Stay healthy'];
      
      // Act - call the factory method
      final result = PersonalizedMessageFactory.createFromGoals(goals);
      
      // Assert - verify the correct message is returned
      expect(result.title, equals('Maintaining Balance'));
      expect(result.message, equals('Let\'s maintain your awesome progress! Your balanced nutrition plan will help you stay on track.'));
      expect(result.iconData, equals(Icons.balance));
    });
    
    test('should create balance message for empty goals list', () {
      // Arrange - create empty goals list
      final goals = <String>[];
      
      // Act - call the factory method
      final result = PersonalizedMessageFactory.createFromGoals(goals);
      
      // Assert - verify default message is returned
      expect(result.title, equals('Maintaining Balance'));
      expect(result.message, equals('Let\'s maintain your awesome progress! Your balanced nutrition plan will help you stay on track.'));
      expect(result.iconData, equals(Icons.balance));
    });
    
    test('should prioritize weight loss over gain when both keywords are present', () {
      // Arrange - create list with both weight loss and gain goals
      final goals = ['Lose fat', 'Gain muscle'];
      
      // Act - call the factory method
      final result = PersonalizedMessageFactory.createFromGoals(goals);
      
      // Assert - verify weight loss message is prioritized
      expect(result.title, equals('Weight Loss Journey'));
      expect(result.iconData, equals(Icons.trending_down));
    });
    
    test('should handle case insensitivity for goal keywords', () {
      // Arrange - create list with lowercase and uppercase goal keywords
      final goalsLower = ['lose weight'];
      final goalsUpper = ['GAIN MUSCLE'];
      
      // Act - call the factory method for both
      final resultLower = PersonalizedMessageFactory.createFromGoals(goalsLower);
      final resultUpper = PersonalizedMessageFactory.createFromGoals(goalsUpper);
      
      // Assert - verify case insensitivity works
      expect(resultLower.title, equals('Weight Loss Journey'));
      expect(resultUpper.title, equals('Building Strength'));
    });
    
    test('should find keywords within longer goal strings', () {
      // Arrange - create list with keywords embedded in longer strings
      final goals = ['I would like to lose some weight and get healthier'];
      
      // Act - call the factory method
      final result = PersonalizedMessageFactory.createFromGoals(goals);
      
      // Assert - verify keywords are detected within strings
      expect(result.title, equals('Weight Loss Journey'));
    });
    
    test('PersonalizedMessageData constructor should set properties correctly', () {
      // Arrange & Act - create a PersonalizedMessageData object
      final data = PersonalizedMessageData(
        title: 'Test Title',
        message: 'Test Message',
        iconData: Icons.star,
      );
      
      // Assert - verify properties are set correctly
      expect(data.title, equals('Test Title'));
      expect(data.message, equals('Test Message'));
      expect(data.iconData, equals(Icons.star));
    });
  });
}
