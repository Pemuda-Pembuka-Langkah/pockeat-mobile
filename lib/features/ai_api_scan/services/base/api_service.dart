import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pockeat/features/ai_api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/ai_api_scan/services/base/api_auth_interceptor.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';

class ApiServiceException implements Exception {
  final String message;

  ApiServiceException(this.message);

  @override
  String toString() => 'ApiServiceException: $message';
}

class ApiService implements ApiServiceInterface {
  final String baseUrl;
  final http.Client _client;
  final ApiAuthInterceptor? _authInterceptor;

  ApiService({
    required this.baseUrl,
    http.Client? client,
    LoginService? loginService,
  })  : _client = client ?? http.Client(),
        _authInterceptor =
            loginService != null ? ApiAuthInterceptor(loginService) : null;

  // Updated factory constructor that accepts LoginService
  factory ApiService.fromEnv({LoginService? loginService}) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.8:8080/api';
    print("🌐 Initializing API Service with base URL: $baseUrl");
    return ApiService(baseUrl: baseUrl, loginService: loginService);
  }

  // Generic method to send requests with JWT auth
  Future<dynamic> _sendRequest(dynamic request) async {
    if (_authInterceptor != null) {
      if (request is http.Request) {
        request = await _authInterceptor.interceptRequest(request);
        return await _client.send(request);
      } else if (request is http.MultipartRequest) {
        request = await _authInterceptor.interceptMultipartRequest(request);
        return await _client.send(request);
      }
    }
    return await _client.send(request);
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

  // Override the postJsonRequest method to use our custom client
  @override
  Future<Map<String, dynamic>> postJsonRequest(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print("📤 POST request to: $uri");
      print("📦 Request body: ${jsonEncode(body)}");

      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);

      // Use our custom method to send the request with auth
      final streamedResponse = await _sendRequest(request);

      final response = await http.Response.fromStream(streamedResponse);

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

  // Similarly update postFileRequest method to use JWT auth
  @override
  Future<Map<String, dynamic>> postFileRequest(
      String endpoint, File file, String fileField,
      [Map<String, String>? fields]) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print("📤 File upload request to: $uri");

      var request = http.MultipartRequest('POST', uri);

      // Add the file
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        fileField,
        fileStream,
        length,
        filename: 'file.jpg',
      );
      request.files.add(multipartFile);

      // Add optional form fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Send the request using our generic method
      print("🚀 Sending multipart request...");
      final streamedResponse = await _sendRequest(request);
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
