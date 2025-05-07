//coverage: ignore-file

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:pockeat/features/food_database_input/services/food/food_database_service.dart';

import 'package:pockeat/features/food_database_input/services/base/supabase.dart'; // Using your existing SupabaseService

class NutritionDatabaseModule {
  static void register() {
    final getIt = GetIt.instance;

    // Register Supabase client
    if (!getIt.isRegistered<SupabaseClient>()) {
      getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
    }

    // Register SupabaseService
    if (!getIt.isRegistered<SupabaseService>()) {
      getIt.registerSingleton<SupabaseService>(
        SupabaseService(getIt<SupabaseClient>()),
      );
    }

    // Register NutritionDatabaseService
    getIt.registerSingleton<NutritionDatabaseServiceInterface>(
      NutritionDatabaseService(
        getIt<SupabaseService>(),
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      ),
    );
  }
}
