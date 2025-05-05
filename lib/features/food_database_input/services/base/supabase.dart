//coverage: ignore-file

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // Expose the client for direct use when needed
  SupabaseClient get client => _client;

  // Helper methods for common operations
  Future<List<Map<String, dynamic>>> fetchFromTable(
    String tableName, {
    int? limit,
    int? offset,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = client.from(tableName).select();

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null && limit != null) {
        query = query.range(offset, offset + limit - 1);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      //print('Error fetching from $tableName: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getById(
      String tableName, String idField, dynamic id) async {
    try {
      final response =
          await client.from(tableName).select().eq(idField, id).single();

      return response;
    } catch (e) {
      //print('Error getting record from $tableName by $idField=$id: $e');
      return null;
    }
  }
}
