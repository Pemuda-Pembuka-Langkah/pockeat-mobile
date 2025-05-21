// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:pockeat/features/authentication/services/login_service.dart';

/// Service to handle free trial limitation logic
class FreeLimitService {
  final LoginService _loginService;

  /// Constructor with dependency injection
  FreeLimitService({LoginService? loginService})
      : _loginService = loginService ?? GetIt.instance<LoginService>();

  /// Checks if the user's free trial is valid
  /// Returns true if the user can access premium features, false otherwise
  Future<bool> isTrialValid() async {
    try {
      final user = await _loginService.getCurrentUser();

      // If no user is logged in, we consider trial as not valid
      if (user == null) return false;

      // Check if user is in free trial period
      return user.isInFreeTrial;
    } catch (e) {
      debugPrint('Error checking trial status: $e');
      // Default to false on error to be safe
      return false;
    }
  }

  /// Redirects user to trial ended page if trial is not valid
  /// Returns true if redirection happened, false if user can access the feature
  Future<bool> checkAndRedirect(BuildContext context) async {
    final isValid = await isTrialValid();

    if (!isValid) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/trial-ended');
        return true; // Redirection happened
      }
    }

    return false; // No redirection, user can access feature
  }

  /// Wrapper method for routes that require valid trial
  /// If trial valid, executes onValidCallback, otherwise redirects to trial ended page
  Future<void> withValidTrial(
      BuildContext context, VoidCallback onValidCallback) async {
    final redirected = await checkAndRedirect(context);

    if (!redirected && context.mounted) {
      onValidCallback();
    }
  }
}
