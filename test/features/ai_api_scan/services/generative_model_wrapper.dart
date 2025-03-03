import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Import the file containing your GenerativeModelWrapper class
import 'package:pockeat/features/ai_api_scan/services/generative_model_wrapper.dart';

// Simple mock class
class MockGenerativeModel extends Mock implements GenerativeModel {}

void main() {
  test('RealGenerativeModelWrapper delegates to GenerativeModel', () {
    // Setup
    final mockModel = MockGenerativeModel();
    final wrapper = RealGenerativeModelWrapper(mockModel);
    final contents = [Content.text('Test')];

    wrapper.generateContent(contents);

    verify(mockModel.generateContent(contents)).called(1);
  });
}
