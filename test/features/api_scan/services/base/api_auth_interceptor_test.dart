// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/api_scan/services/base/api_auth_interceptor.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';

// Mocks
class MockTokenManager extends Mock implements TokenManager {}

void main() {
  late ApiAuthInterceptor authInterceptor;
  late MockTokenManager mockTokenManager;

  setUp(() {
    mockTokenManager = MockTokenManager();
    authInterceptor = ApiAuthInterceptor(mockTokenManager);
  });

  group('ApiAuthInterceptor', () {
    group('interceptRequest', () {
      test('should add authorization header when token is available', () async {
        // Arrange
        final request =
            http.Request('GET', Uri.parse('https://example.com/api'));
        const testToken = 'test-id-token-123';

        // Setup mock behavior
        when(() => mockTokenManager.getIdToken())
            .thenAnswer((_) async => testToken);

        // Act
        final interceptedRequest =
            await authInterceptor.interceptRequest(request);

        // Assert
        expect(
            interceptedRequest.headers['Authorization'], 'Bearer $testToken');
        verify(() => mockTokenManager.getIdToken()).called(1);
      });

      test('should not add authorization header when token is null', () async {
        // Arrange
        final request =
            http.Request('GET', Uri.parse('https://example.com/api'));

        // Setup mock behavior
        when(() => mockTokenManager.getIdToken()).thenAnswer((_) async => null);

        // Act
        final interceptedRequest =
            await authInterceptor.interceptRequest(request);

        // Assert
        expect(
            interceptedRequest.headers.containsKey('Authorization'), isFalse);
        verify(() => mockTokenManager.getIdToken()).called(1);
      });

      test('should preserve existing headers when adding authorization',
          () async {
        // Arrange
        final request =
            http.Request('GET', Uri.parse('https://example.com/api'));
        request.headers['Content-Type'] = 'application/json';
        const testToken = 'test-id-token-123';

        // Setup mock behavior
        when(() => mockTokenManager.getIdToken())
            .thenAnswer((_) async => testToken);

        // Act
        final interceptedRequest =
            await authInterceptor.interceptRequest(request);

        // Assert
        expect(
            interceptedRequest.headers['Authorization'], 'Bearer $testToken');
        expect(interceptedRequest.headers['Content-Type'], 'application/json');
        verify(() => mockTokenManager.getIdToken()).called(1);
      });
    });

    group('interceptMultipartRequest', () {
      test(
          'should add authorization header to multipart request when token is available',
          () async {
        // Arrange
        final request = http.MultipartRequest(
            'POST', Uri.parse('https://example.com/api/upload'));
        const testToken = 'test-id-token-123';

        // Setup mock behavior
        when(() => mockTokenManager.getIdToken())
            .thenAnswer((_) async => testToken);

        // Act
        final interceptedRequest =
            await authInterceptor.interceptMultipartRequest(request);

        // Assert
        expect(
            interceptedRequest.headers['Authorization'], 'Bearer $testToken');
        verify(() => mockTokenManager.getIdToken()).called(1);
      });

      test(
          'should not add authorization header to multipart request when token is null',
          () async {
        // Arrange
        final request = http.MultipartRequest(
            'POST', Uri.parse('https://example.com/api/upload'));

        // Setup mock behavior
        when(() => mockTokenManager.getIdToken()).thenAnswer((_) async => null);

        // Act
        final interceptedRequest =
            await authInterceptor.interceptMultipartRequest(request);

        // Assert
        expect(
            interceptedRequest.headers.containsKey('Authorization'), isFalse);
        verify(() => mockTokenManager.getIdToken()).called(1);
      });

      test(
          'should preserve existing headers in multipart request when adding authorization',
          () async {
        // Arrange
        final request = http.MultipartRequest(
            'POST', Uri.parse('https://example.com/api/upload'));
        request.headers['Content-Type'] = 'multipart/form-data';
        const testToken = 'test-id-token-123';

        // Setup mock behavior
        when(() => mockTokenManager.getIdToken())
            .thenAnswer((_) async => testToken);

        // Act
        final interceptedRequest =
            await authInterceptor.interceptMultipartRequest(request);

        // Assert
        expect(
            interceptedRequest.headers['Authorization'], 'Bearer $testToken');
        expect(
            interceptedRequest.headers['Content-Type'], 'multipart/form-data');
        verify(() => mockTokenManager.getIdToken()).called(1);
      });
    });
  });
}
