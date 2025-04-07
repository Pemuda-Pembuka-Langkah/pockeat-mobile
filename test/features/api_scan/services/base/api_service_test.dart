// test/features/ai_api_scan/services/base/api_service_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/api_scan/services/base/api_service.dart';
import 'package:pockeat/features/api_scan/services/base/api_service_interface.dart';
import 'package:pockeat/features/authentication/services/token_manager.dart';
import 'api_service_test.mocks.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Generate mocks
@GenerateMocks([http.Client, ApiServiceInterface])
@GenerateNiceMocks([MockSpec<TokenManager>()])
void main() {
  late MockClient mockClient;
  late MockTokenManager mockTokenManager;
  late ApiService apiService;
  late http.StreamedResponse successResponse;

  setUp(() {
    mockClient = MockClient();
    mockTokenManager = MockTokenManager();
    apiService = ApiService(
        baseUrl: 'http://test.api',
        client: mockClient,
        tokenManager: mockTokenManager);

    // Set up common success response
    successResponse = http.StreamedResponse(
      Stream.value(utf8.encode('{"data": "test"}')),
      200,
      headers: {'content-type': 'application/json'},
    );

    // Set up default mock behavior
    when(mockClient.send(any)).thenAnswer((_) async => successResponse);

    // Mock environment variables
    dotenv.testLoad(fileInput: '''
      API_BASE_URL=http://test.api
      API_KEY=test_key
    ''');
  });

  group('ApiService', () {
    test('should be created with default values', () {
      expect(apiService, isNotNull);
    });

    test(
        'postJsonRequest should make a POST request with JSON body successfully',
        () async {
      // Act
      final response =
          await apiService.postJsonRequest('/test', {'key': 'value'});

      // Assert
      expect(response, isA<Map<String, dynamic>>());
      verify(mockClient.send(any)).called(1);
    });

    test('postFileRequest should make a POST request with file successfully',
        () async {
      // Arrange
      final mockFile = MockTestFile();
      final bytes = Uint8List.fromList([1, 2, 3]);

      // Act
      final response =
          await apiService.postFileRequest('/test', mockFile, 'image');

      // Assert
      expect(response, isA<Map<String, dynamic>>());
      verify(mockClient.send(any)).called(1);
    });

    test('authentication should add auth token to requests when available',
        () async {
      // Arrange
      when(mockTokenManager.getIdToken()).thenAnswer((_) async => 'test_token');

      // Act
      await apiService.postJsonRequest('/test', {'key': 'value'});

      // Assert
      verify(mockClient.send(argThat(predicate((http.BaseRequest request) =>
          request.headers['Authorization'] == 'Bearer test_token')))).called(1);
    });

    test('authentication should not add auth token when not available',
        () async {
      // Arrange
      when(mockTokenManager.getIdToken()).thenAnswer((_) async => null);

      // Act
      await apiService.postJsonRequest('/test', {'key': 'value'});

      // Assert
      verify(mockClient.send(argThat(predicate((http.BaseRequest request) =>
          !request.headers.containsKey('Authorization'))))).called(1);
    });
  });
}

class MockTestFile extends Mock implements File {
  @override
  String get path => 'test.jpg';

  @override
  bool existsSync() => true;

  @override
  int lengthSync() => 3;

  @override
  Future<int> length() => Future.value(3);

  @override
  Stream<List<int>> openRead([int? start, int? end]) =>
      Stream.value(Uint8List.fromList([1, 2, 3]));
}
