import 'package:pockeat/features/pet_companion/domain/model/pet_information.dart';

abstract class PetService {
  /// Get the pet mood
  ///
  /// [userId] is the user id
  /// Returns the pet mood
  ///
  /// returns 'happy' if the pet has logged food today
  /// returns 'sad' if the pet has not logged food today
  Future<String> getPetMood(String userId);

  /// Get the pet heart
  ///
  /// [userId] is the user id
  /// Returns the pet heart
  ///
  /// returns 0 if the pet has not logged food today
  /// under 25% of the target calories returns 1
  /// between 25% and 50% of the target calories returns 2
  /// between 50% and 75% of the target calories returns 3
  /// between 75% and 100% of the target calories returns 4
  Future<int> getPetHeart(String userId);

  /// Get the pet calorie over target
  ///
  /// [userId] is the user id
  /// Returns the pet calorie over target
  ///
  /// returns true if the pet has consumed more calories than the target
  /// returns false if the pet has consumed less than the target
  Future<bool> getIsPetCalorieOverTarget(String userId);

  /// Get the pet information
  ///
  /// [userId] is the user id
  /// Returns the pet information
  Future<PetInformation> getPetInformation(String userId);
}
