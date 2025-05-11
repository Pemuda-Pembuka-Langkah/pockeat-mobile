//coverage: ignore-file

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:pockeat/features/authentication/services/token_manager.dart';

// cove
class ApiAuthInterceptor {
  final TokenManager _tokenManager;

  ApiAuthInterceptor(this._tokenManager);

  /// Add authorization header to the request
  Future<http.Request> interceptRequest(http.Request request) async {
    final token = await _tokenManager.getIdToken();
    //coverage:ignore-start
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    //coverage:ignore-end
    return request;
  }

  /// Add authorization header to a multipart request
  Future<http.MultipartRequest> interceptMultipartRequest(
      http.MultipartRequest request) async {
    final token = await _tokenManager.getIdToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }
}
