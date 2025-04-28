// Package imports:
import 'package:meta/meta.dart';

/// Abstract Product - Interface for all streak messages
@immutable
abstract class StreakMessage {
  /// Get notification title
  String get title;

  /// Get notification body
  String get body;

  /// User's streak count
  int get streak;
}

/// Concrete Product - Message for regular streak (< 7 days)
class RegularStreakMessage implements StreakMessage {
  final int _streak;

  /// Constructor for RegularStreakMessage
  /// [streak] is the user's streak count
  RegularStreakMessage(this._streak);

  @override
  String get title => '$_streak Day Streak! 👏';

  @override
  String get body => 'Keep up the good habit today!';

  @override
  int get streak => _streak;
}

/// Concrete Product - Message for weekly streak (7-29 days)
class WeeklyStreakMessage implements StreakMessage {
  final int _streak;

  /// Constructor for WeeklyStreakMessage
  /// [streak] is the user's streak count
  WeeklyStreakMessage(this._streak);

  @override
  String get title => '7+ Day Streak! 🔥';

  @override
  String get body => 'You have maintained a $_streak day streak! Keep going!';

  @override
  int get streak => _streak;
}

/// Concrete Product - Message for monthly streak (30-99 days)
class MonthlyStreakMessage implements StreakMessage {
  final int _streak;

  /// Constructor for MonthlyStreakMessage
  /// [streak] is the user's streak count
  MonthlyStreakMessage(this._streak);

  @override
  String get title => '30+ Day Streak! 🌟';

  @override
  String get body => 'Amazing! You have been consistent for $_streak days!';

  @override
  int get streak => _streak;
}

/// Concrete Product - Message for 100+ day streak
class CenturyStreakMessage implements StreakMessage {
  final int _streak;

  /// Constructor for CenturyStreakMessage
  /// [streak] is the user's streak count
  CenturyStreakMessage(this._streak);

  @override
  String get title => 'WOW! 100+ Day Streak! 🏆';

  @override
  String get body => 'Spectacular achievement! $_streak consecutive days!';

  @override
  int get streak => _streak;
}

/// Factory - Class to create appropriate StreakMessage instance
class StreakMessageFactory {
  /// Create StreakMessage based on streak count
  ///
  /// [streak] is the user's streak count
  /// Returns StreakMessage appropriate for the streak count
  static StreakMessage createMessage(int streak) {
    if (streak < 0) {
      throw ArgumentError('Streak must not be negative');
    }

    if (streak >= 100) {
      return CenturyStreakMessage(streak);
    } else if (streak >= 30) {
      return MonthlyStreakMessage(streak);
    } else if (streak >= 7) {
      return WeeklyStreakMessage(streak);
    } else {
      return RegularStreakMessage(streak);
    }
  }
}
