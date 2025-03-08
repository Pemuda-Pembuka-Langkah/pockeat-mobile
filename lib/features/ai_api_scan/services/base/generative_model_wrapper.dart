  import 'package:google_generative_ai/google_generative_ai.dart';

  abstract class GenerativeModelWrapper {
    Future<dynamic> generateContent(List<Content> contents);
  }

  class RealGenerativeModelWrapper implements GenerativeModelWrapper {
    final GenerativeModel _model;
    
    RealGenerativeModelWrapper(this._model);
    
    @override
    Future<dynamic> generateContent(List<Content> contents) {
      return _model.generateContent(contents);
    }
  }