import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pockeat/features/ai_api_scan/services/base/api_service_interface.dart';

class ApiServiceException implements Exception {
  final String message;

  ApiServiceException(this.message);

  @override
  String toString() => 'ApiServiceException: $message';
}

class ApiService implements ApiServiceInterface {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // For testing and DI
  factory ApiService.fromEnv() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.8:8080/api';
    print("🌐 Initializing API Service with base URL: $baseUrl");
    return ApiService(baseUrl: baseUrl);
  }

  // Health check endpoint
  @override
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      print("🔍 Health check request to: $uri");

      final response = await _client.get(uri);
      print(
          "✓ Health check response: [${response.statusCode}] ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      print("❌ Health check failed with status code: ${response.statusCode}");
      return false;
    } catch (e) {
      print("⚠️ Health check exception: $e");
      throw ApiServiceException("Failed to check API health: $e");
    }
  }

  // Generic POST request with JSON body
  @override
  Future<Map<String, dynamic>> postJsonRequest(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print("📤 POST request to: $uri");
      print("📦 Request body: ${jsonEncode(body)}");

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("📥 Response: [${response.statusCode}] ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        print("❌ API error: ${error['error'] ?? 'Unknown error'}");
        if (error.containsKey('error') && error['error'] != null) {
          String errorMessage = error['error'] is String
              ? error['error']
              : error['error'] is Map
                  ? (error['error']['message'] ?? 'Unknown error')
                  : 'Unknown error';
          throw ApiServiceException(errorMessage);
        }
        throw ApiServiceException(error['error'] ?? 'Unknown error from API');
      }
    } catch (e) {
      print("⚠️ Request exception for $endpoint: $e");
      if (e is ApiServiceException) rethrow;
      throw ApiServiceException("Failed API request to $endpoint: $e");
    }
  }

  // POST request with file upload
  @override
  Future<Map<String, dynamic>> postFileRequest(
      String endpoint, File file, String fileField,
      [Map<String, String>? fields]) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print("📤 File upload request to: $uri");
      print("📁 File path: ${file.path}, field: $fileField");
      if (fields != null) {
        print("📋 Additional fields: $fields");
      }

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      // Add the file
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();
      print("📏 File size: $length bytes");

      final multipartFile = http.MultipartFile(
        fileField,
        fileStream,
        length,
        filename: 'file.jpg', // Generic filename
      );

      request.files.add(multipartFile);

      // Add optional form fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Send the request
      print("🚀 Sending multipart request...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📥 Response: [${response.statusCode}] ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        print("❌ File upload error: ${error['error'] ?? 'Unknown error'}");
        if (error.containsKey('error') && error['error'] != null) {
          String errorMessage = error['error'] is String
              ? error['error']
              : error['error'] is Map
                  ? (error['error']['message'] ?? 'Unknown error')
                  : 'Unknown error';
          throw ApiServiceException(errorMessage);
        }
        throw ApiServiceException(error['error'] ?? 'Unknown error from API');
      }
    } catch (e) {
      print("⚠️ File upload exception for $endpoint: $e");
      if (e is ApiServiceException) rethrow;
      throw ApiServiceException("Failed file upload to $endpoint: $e");
    }
  }

  @override
  void dispose() {
    print("🔄 Closing API service client");
    _client.close();
  }
}
