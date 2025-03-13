import 'package:pockeat/firebase/firebase_repository.dart';
import 'package:pockeat/features/ai_api_scan/models/food_analysis.dart';

class FoodTextInputRepository extends BaseFirestoreRepository<FoodAnalysisResult> {
  FoodTextInputRepository({super.firestore}) : super(
    collectionName: 'food_analysis',
    toMap: (item) => item.toJson(),
    fromMap: (map, id) => FoodAnalysisResult.fromJson(map),
  );
}