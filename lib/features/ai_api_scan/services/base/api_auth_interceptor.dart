import 'package:http/http.dart' as http;
import 'package:pockeat/features/authentication/services/login_service.dart';

class ApiAuthInterceptor {
  final LoginService _loginService;

  ApiAuthInterceptor(this._loginService);

  /// Add authorization header to the request
  Future<http.Request> interceptRequest(http.Request request) async {
    final token = await _loginService.getIdToken();

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    return request;
  }

  /// Add authorization header to a multipart request
  Future<http.MultipartRequest> interceptMultipartRequest(
      http.MultipartRequest request) async {
    final token = await _loginService.getIdToken();

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    return request;
  }
}
