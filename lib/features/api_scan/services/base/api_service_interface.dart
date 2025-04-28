// lib/features/ai_api_scan/services/base/api_service_interface.dart
//coverage: ignore-file

// Dart imports:
import 'dart:io';

abstract class ApiServiceInterface {
  /// Performs a POST request with a JSON body
  ///
  /// [endpoint] - The API endpoint to send the request to
  /// [body] - The request body as a Map
  ///
  /// Returns a Map with the response data or throws an exception
  Future<Map<String, dynamic>> postJsonRequest(
      String endpoint, Map<String, dynamic> body);

  /// Performs a POST request with a file
  ///
  /// [endpoint] - The API endpoint to send the request to
  /// [file] - The file to upload
  /// [fileField] - The name of the file field in the request
  /// [fields] - Optional additional form fields
  ///
  /// Returns a Map with the response data or throws an exception
  Future<Map<String, dynamic>> postFileRequest(
      String endpoint, File file, String fileField,
      [Map<String, String>? fields]);

  /// Health check endpoint
  ///
  /// Returns true if the API is healthy, false otherwise
  Future<bool> checkHealth();
}
