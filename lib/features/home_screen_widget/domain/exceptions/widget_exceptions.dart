/// Base exception untuk feature home screen widget
class HomeScreenWidgetException implements Exception {
  final String message;

  HomeScreenWidgetException(this.message);

  @override
  String toString() => 'HomeScreenWidgetException: $message';
}

/// Exception dilempar saat gagal registrasi callback widget
class WidgetCallbackRegistrationException extends HomeScreenWidgetException {
  WidgetCallbackRegistrationException(super.message);
}

/// Exception dilempar saat gagal setup timer untuk update widget
class WidgetTimerSetupException extends HomeScreenWidgetException {
  WidgetTimerSetupException(super.message);
}

/// Exception ketika gagal memperbarui data widget
class WidgetUpdateException extends HomeScreenWidgetException {
  WidgetUpdateException(super.message);
}

/// Exception ketika gagal mengambil health metrics
class HealthMetricsNotFoundException extends HomeScreenWidgetException {
  final String userId;

  HealthMetricsNotFoundException(this.userId)
      : super('Health metrics not found for user: $userId');
}

/// Exception ketika gagal mendapatkan caloric requirement
class CaloricRequirementCalculationException extends HomeScreenWidgetException {
  CaloricRequirementCalculationException(super.message);
}

/// Exception ketika gagal membersihkan data widget
class WidgetCleanupException extends HomeScreenWidgetException {
  WidgetCleanupException(super.message);
}

/// Exception ketika gagal menginisialisasi widget
class WidgetInitializationException extends HomeScreenWidgetException {
  WidgetInitializationException(super.message);
}
