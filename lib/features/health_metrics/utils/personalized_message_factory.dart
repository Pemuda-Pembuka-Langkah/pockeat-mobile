import 'package:flutter/material.dart';

/// A class that provides personalized messages based on user goals
class PersonalizedMessageFactory {
  /// Creates a personalized message data based on user goals
  /// 
  /// Returns a [PersonalizedMessageData] containing title, message and icon
  static PersonalizedMessageData createFromGoals(List<String> goals) {
    String message;
    IconData iconData;
    String title;
    
    if (goals.any((goal) => goal.toLowerCase().contains('lose'))) {
      title = "Weight Loss Journey";
      message = "You're on your way to a healthier, lighter you! Your plan is designed for sustainable results.";
      iconData = Icons.trending_down;
    } else if (goals.any((goal) => goal.toLowerCase().contains('gain'))) {
      title = "Building Strength";
      message = "Get ready to build strength and energy! Your nutrition plan supports your muscle growth goals.";
      iconData = Icons.fitness_center;
    } else {
      title = "Maintaining Balance";
      message = "Let's maintain your awesome progress! Your balanced nutrition plan will help you stay on track.";
      iconData = Icons.balance;
    }
    
    return PersonalizedMessageData(
      title: title, 
      message: message, 
      iconData: iconData
    );
  }
}

/// Data class to hold personalized message information
class PersonalizedMessageData {
  final String title;
  final String message;
  final IconData iconData;
  
  const PersonalizedMessageData({
    required this.title,
    required this.message,
    required this.iconData,
  });
}
