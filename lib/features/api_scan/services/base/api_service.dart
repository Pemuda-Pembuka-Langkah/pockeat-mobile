// Dart imports:
//coverage: ignore-file

import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:pockeat/features/api_scan/services/base/api_auth_interceptor.dart';
import 'package:pockeat/features/api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';

// coverage:ignore-start
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
    TokenManager? tokenManager,
  })  : _client = client ?? http.Client(),
        _authInterceptor =
            tokenManager != null ? ApiAuthInterceptor(tokenManager) : null;

  // Updated factory constructor that accepts LoginService
  factory ApiService.fromEnv({TokenManager? tokenManager}) {
    final baseUrl = dotenv.env['API_BASE_URL'] ??
        'http://10.5.91.250:8080/api'; //LOCALHOST API
    print('API_BASE_URL: $baseUrl');
    return ApiService(baseUrl: baseUrl, tokenManager: tokenManager);
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
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      throw ApiServiceException("Failed to check API health: $e");
    }
  }

  // Override the postJsonRequest method to use our custom client
  @override
  Future<Map<String, dynamic>> postJsonRequest(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);

      final streamedResponse = await _sendRequest(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
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
      final streamedResponse = await _sendRequest(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
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
      if (e is ApiServiceException) rethrow;
      throw ApiServiceException("Failed file upload to $endpoint: $e");
    }
  }

  void dispose() {
    _client.close();
  }
}
// coverage:ignore-end
