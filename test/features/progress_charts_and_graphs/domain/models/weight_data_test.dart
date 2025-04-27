import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/weight_data.dart';

void main() {
  group('WeightData', () {
    test('should create a WeightData instance with required parameters', () {
      // Arrange & Act
      final weightData = WeightData('Week 1', 75.5);
      
      // Assert
      expect(weightData.week, 'Week 1');
      expect(weightData.weight, 75.5);
    });
    
    test('should handle string week and numeric weight properly', () {
      // Arrange & Act
      final weightData = WeightData('Week 2', 76.2);
      
      // Assert
      expect(weightData.week, isA<String>());
      expect(weightData.weight, isA<double>());
    });
    
    test('should properly store decimal weight values', () {
      // Arrange & Act
      const testWeight = 80.75;
      final weightData = WeightData('Week 3', testWeight);
      
      // Assert
      expect(weightData.weight, testWeight);
    });
    
    test('should properly handle different week formats', () {
      // Arrange & Act
      final formats = [
        WeightData('2023-W01', 70.0),
        WeightData('Jan W1', 71.0),
        WeightData('Week 4', 72.0),
      ];
      
      // Assert
      expect(formats[0].week, '2023-W01');
      expect(formats[1].week, 'Jan W1');
      expect(formats[2].week, 'Week 4');
    });
  });
}