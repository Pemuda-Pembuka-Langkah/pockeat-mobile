import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/features/food_database_input/services/base/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Mock Supabase client and PostgrestBuilder classes
class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}

class MockPostgrestBuilder extends Mock implements supabase.PostgrestBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements supabase.PostgrestFilterBuilder<Map<String, dynamic>> {}

class MockPostgrestTransformBuilder extends Mock
    implements supabase.PostgrestTransformBuilder<Map<String, dynamic>> {}

void main() {
  late SupabaseService service;
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestBuilder mockFrom;
  late MockPostgrestTransformBuilder mockSelect;
  late MockPostgrestFilterBuilder mockEq;
  late MockPostgrestFilterBuilder mockSingle;
  late MockPostgrestTransformBuilder mockRange;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockFrom = MockPostgrestBuilder();
    mockSelect = MockPostgrestTransformBuilder();
    mockEq = MockPostgrestFilterBuilder();
    mockSingle = MockPostgrestFilterBuilder();
    mockRange = MockPostgrestTransformBuilder();

    when(mockSupabaseClient.from(any)).thenReturn(mockFrom);

    service = SupabaseService(client: mockSupabaseClient);
  });

  group('Supabase Service', () {
    test('getAllFoods should return list of foods', () async {
      // Arrange
      final testData = [
        {
          'id': 1,
          'name': 'Apple',
          'nutrition': {'calories': 52}
        },
        {
          'id': 2,
          'name': 'Banana',
          'nutrition': {'calories': 89}
        },
      ];

      // Setup mock chain
      when(mockFrom.select()).thenReturn(mockSelect);
      when(mockSelect.range(any, any)).thenReturn(mockRange);
      when(mockRange).thenAnswer((_) async => testData);

      // Act
      final result = await service.getAllFoods();

      // Assert
      expect(result.length, 2);
      verify(mockSupabaseClient.from('foods')).called(1);
      verify(mockFrom.select()).called(1);
    });

    test('getFoodById should return a specific food', () async {
      // Arrange
      final testData = {
        'id': 1,
        'name': 'Apple',
        'nutrition': {'calories': 52}
      };

      // Setup mock chain
      when(mockFrom.select()).thenReturn(mockSelect);
      when(mockSelect.eq('id', 1)).thenReturn(mockEq);
      when(mockEq.single()).thenReturn(mockSingle);
      when(mockSingle).thenAnswer((_) async => testData);

      // Act
      final result = await service.getFoodById(1);

      // Assert
      expect(result['name'], 'Apple');
      verify(mockSupabaseClient.from('foods')).called(1);
      verify(mockSelect.eq('id', 1)).called(1);
    });

    test('searchFoods should find foods by name pattern', () async {
      // Arrange
      final testData = [
        {
          'id': 1,
          'name': 'Apple',
          'nutrition': {'calories': 52}
        }
      ];

      // Setup mock chain
      when(mockFrom.select()).thenReturn(mockSelect);
      when(mockSelect.ilike('name', '%apple%')).thenReturn(mockEq);
      when(mockEq.limit(any)).thenReturn(mockRange);
      when(mockRange).thenAnswer((_) async => testData);

      // Act
      final result = await service.searchFoods('apple');

      // Assert
      expect(result.length, 1);
      expect(result[0]['name'], 'Apple');
      verify(mockSupabaseClient.from('foods')).called(1);
      verify(mockSelect.ilike('name', '%apple%')).called(1);
    });
  });
}
