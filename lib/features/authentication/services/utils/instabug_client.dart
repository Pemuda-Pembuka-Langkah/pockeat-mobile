import 'package:instabug_flutter/instabug_flutter.dart';

/// Wrapper for Instabug that allows mocking in tests
class InstabugClient {
  /// Set user data in Instabug
  Future<void> identifyUser(String email, String name, String id) async {
    await Instabug.identifyUser(email, name, id);
  }
  
  /// Clear user data from Instabug
  Future<void> logOut() async {
    await Instabug.logOut();
  }
  
  /// Shows the main Instabug reporting menu with all options
  /// (Report a bug, Suggest an improvement, Ask a question)
  Future<void> showReportingUI() async {
    await Instabug.show();
  }
}
