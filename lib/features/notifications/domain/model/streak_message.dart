// Package imports:
import 'package:meta/meta.dart';

/// Abstract Product - Interface untuk semua pesan streak
@immutable
abstract class StreakMessage {
  /// Mendapatkan judul notifikasi
  String get title;

  /// Mendapatkan isi pesan notifikasi
  String get body;

  /// Jumlah streak pengguna
  int get streak;
}

/// Concrete Product - Pesan untuk streak reguler (< 7 hari)
class RegularStreakMessage implements StreakMessage {
  final int _streak;

  /// Constructor untuk RegularStreakMessage
  /// [streak] adalah jumlah hari streak pengguna
  RegularStreakMessage(this._streak);

  @override
  String get title => 'Streak $_streak Hari! 👏';

  @override
  String get body => 'Teruskan kebiasaan baikmu hari ini!';

  @override
  int get streak => _streak;
}

/// Concrete Product - Pesan untuk streak mingguan (7-29 hari)
class WeeklyStreakMessage implements StreakMessage {
  final int _streak;

  /// Constructor untuk WeeklyStreakMessage
  /// [streak] adalah jumlah hari streak pengguna
  WeeklyStreakMessage(this._streak);

  @override
  String get title => 'Streak 7+ Hari! 🔥';

  @override
  String get body => 'Kamu sudah mencapai streak $_streak hari! Pertahankan!';

  @override
  int get streak => _streak;
}

/// Concrete Product - Pesan untuk streak bulanan (30-99 hari)
class MonthlyStreakMessage implements StreakMessage {
  final int _streak;

  /// Constructor untuk MonthlyStreakMessage
  /// [streak] adalah jumlah hari streak pengguna
  MonthlyStreakMessage(this._streak);

  @override
  String get title => 'Streak 30+ Hari! 🌟';

  @override
  String get body => 'Streak $_streak hari! Konsistensi yang hebat!';

  @override
  int get streak => _streak;
}

/// Concrete Product - Pesan untuk streak 100+ hari
class CenturyStreakMessage implements StreakMessage {
  final int _streak;

  /// Constructor untuk CenturyStreakMessage
  /// [streak] adalah jumlah hari streak pengguna
  CenturyStreakMessage(this._streak);

  @override
  String get title => 'WOW! 100+ Hari Streak! 🏆';

  @override
  String get body =>
      'Kamu sudah mencapai streak selama $_streak hari! Pencapaian luar biasa!';

  @override
  int get streak => _streak;
}

/// Factory - Class untuk membuat instance StreakMessage yang sesuai
class StreakMessageFactory {
  /// Membuat StreakMessage berdasarkan jumlah streak
  ///
  /// [streak] adalah jumlah hari streak pengguna
  /// Returns StreakMessage yang sesuai dengan jumlah streak
  static StreakMessage createMessage(int streak) {
    if (streak < 0) {
      throw ArgumentError('Streak tidak boleh negatif');
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
