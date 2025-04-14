import 'package:instabug_flutter/instabug_flutter.dart';

/// Wrapper for Instabug that allows mocking in tests
class InstabugClient {
  /// Set user data in Instabug
  // coverage:ignore-start
  Future<void> identifyUser(String email, String name, String id) async {
    await Instabug.identifyUser(email, name, id);
  }
  // coverage:ignore-end
  
  /// Clear user data from Instabug
  // coverage:ignore-start
  Future<void> logOut() async {
    await Instabug.logOut();
  }
  // coverage:ignore-end
  
  /// Shows the main Instabug reporting menu with all options
  /// (Report a bug, Suggest an improvement, Ask a question)
  // coverage:ignore-start
  Future<void> showReportingUI() async {
    await Instabug.show();
  }
  // coverage:ignore-end
}
