// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/food_database_input/domain/repositories/nutrition_database_repository.dart';
import 'package:pockeat/features/food_database_input/services/base/supabase.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  FirebaseFirestore,
  NutritionDatabaseRepository,
  SupabaseService,
])
void main() {}
