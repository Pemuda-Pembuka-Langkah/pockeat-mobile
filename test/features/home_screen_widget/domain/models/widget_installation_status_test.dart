// test/features/home_screen_widget/domain/models/widget_installation_status_test.dart

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/home_screen_widget/domain/models/widget_installation_status.dart';

void main() {
  /// Group of tests for WidgetType enum
  group('WidgetType', () {
    test('should have exactly two enum values', () {
      // We expect exactly simple and detailed types
      expect(WidgetType.values.length, equals(2));
    });
    
    test('enum values should have correct names', () {
      expect(WidgetType.simple.name, equals('simple'));
      expect(WidgetType.detailed.name, equals('detailed'));
    });
    
    test('fromString should convert strings to enum values correctly', () {
      // Extension method test (if implemented)
      // If not implemented, you may skip this
      final simple = 'simple';
      final detailed = 'detailed';
      final invalid = 'invalid';
      
      // Act & Assert
      expect(WidgetType.values.firstWhere((e) => e.name == simple), equals(WidgetType.simple));
      expect(WidgetType.values.firstWhere((e) => e.name == detailed), equals(WidgetType.detailed));
      expect(() => WidgetType.values.firstWhere((e) => e.name == invalid), throwsStateError);
    });
  });
  
  /// Group of tests for WidgetInstallationStatus class
  group('WidgetInstallationStatus', () {
    /// Constructors tests
    group('Constructors', () {
      test('default constructor should initialize with all fields false', () {
        // Arrange & Act
        final status = WidgetInstallationStatus();
        
        // Assert
        expect(status.isSimpleWidgetInstalled, isFalse, reason: 'Simple widget should be false by default');
        expect(status.isDetailedWidgetInstalled, isFalse, reason: 'Detailed widget should be false by default');
      });

      test('should create instance with custom simple widget flag', () {
        // Arrange & Act
        final status = WidgetInstallationStatus(isSimpleWidgetInstalled: true);
        
        // Assert
        expect(status.isSimpleWidgetInstalled, isTrue);
        expect(status.isDetailedWidgetInstalled, isFalse, reason: 'Detailed widget should default to false');
      });
      
      test('should create instance with custom detailed widget flag', () {
        // Arrange & Act
        final status = WidgetInstallationStatus(isDetailedWidgetInstalled: true);
        
        // Assert
        expect(status.isSimpleWidgetInstalled, isFalse, reason: 'Simple widget should default to false');
        expect(status.isDetailedWidgetInstalled, isTrue);
      });

      test('should create instance with both flags customized', () {
        // Arrange & Act
        final status = WidgetInstallationStatus(
          isSimpleWidgetInstalled: true,
          isDetailedWidgetInstalled: true,
        );
        
        // Assert
        expect(status.isSimpleWidgetInstalled, isTrue);
        expect(status.isDetailedWidgetInstalled, isTrue);
      });
    });

    /// isAnyWidgetInstalled tests
    group('isAnyWidgetInstalled', () {
      test('should return false when no widgets are installed', () {
        // Arrange
        final status = WidgetInstallationStatus();
        
        // Act & Assert
        expect(status.isAnyWidgetInstalled, isFalse, reason: 'Should return false when both flags are false');
      });

      test('should return true when only simple widget is installed', () {
        // Arrange
        final status = WidgetInstallationStatus(isSimpleWidgetInstalled: true);
        
        // Act & Assert
        expect(status.isAnyWidgetInstalled, isTrue, reason: 'Should return true if simple widget is installed');
      });
      
      test('should return true when only detailed widget is installed', () {
        // Arrange
        final status = WidgetInstallationStatus(isDetailedWidgetInstalled: true);
        
        // Act & Assert
        expect(status.isAnyWidgetInstalled, isTrue, reason: 'Should return true if detailed widget is installed');
      });
      
      test('should return true when both widgets are installed', () {
        // Arrange
        final status = WidgetInstallationStatus(
          isSimpleWidgetInstalled: true,
          isDetailedWidgetInstalled: true,
        );
        
        // Act & Assert
        expect(status.isAnyWidgetInstalled, isTrue, reason: 'Should return true if both widgets are installed');
      });
      
      test('getter behavior should match logical OR of both flags', () {
        // Test all possible combinations to ensure complete behavior
        for (var simple in [false, true]) {
          for (var detailed in [false, true]) {
            // Arrange
            final status = WidgetInstallationStatus(
              isSimpleWidgetInstalled: simple,
              isDetailedWidgetInstalled: detailed,
            );
            
            // Act & Assert
            expect(
              status.isAnyWidgetInstalled, 
              equals(simple || detailed),
              reason: 'Should match logical OR operation for ($simple, $detailed)'
            );
          }
        }
      });
    });

    /// copyWith tests
    group('copyWith', () {
      test('should not modify original instance', () {
        // Arrange
        final original = WidgetInstallationStatus();
        
        // Act
        original.copyWith(
          isSimpleWidgetInstalled: true,
          isDetailedWidgetInstalled: true,
        );
        
        // Assert - original should be unchanged
        expect(original.isSimpleWidgetInstalled, isFalse);
        expect(original.isDetailedWidgetInstalled, isFalse);
      });
      
      test('should create a new instance with updated values', () {
        // Arrange
        final original = WidgetInstallationStatus();
        
        // Act
        final copy = original.copyWith(
          isSimpleWidgetInstalled: true,
          isDetailedWidgetInstalled: true,
        );
        
        // Assert
        expect(copy.isSimpleWidgetInstalled, isTrue);
        expect(copy.isDetailedWidgetInstalled, isTrue);
        expect(identical(original, copy), isFalse, reason: 'Should be different instances');
      });

      test('should use existing values when new values are not provided', () {
        // Arrange
        final original = WidgetInstallationStatus(
          isSimpleWidgetInstalled: true,
          isDetailedWidgetInstalled: true,
        );
        
        // Act - only modify simple flag
        final copySimpleOnly = original.copyWith(isSimpleWidgetInstalled: false);
        // Act - only modify detailed flag
        final copyDetailedOnly = original.copyWith(isDetailedWidgetInstalled: false);
        // Act - provide null values (should use existing)
        final copyWithNulls = original.copyWith();
        
        // Assert
        expect(copySimpleOnly.isSimpleWidgetInstalled, isFalse);
        expect(copySimpleOnly.isDetailedWidgetInstalled, isTrue, reason: 'Should retain original detailed value');
        expect(copyDetailedOnly.isSimpleWidgetInstalled, isTrue, reason: 'Should retain original simple value');
        expect(copyDetailedOnly.isDetailedWidgetInstalled, isFalse);
        expect(copyWithNulls.isSimpleWidgetInstalled, isTrue, reason: 'Should retain all original values when no parameters');
        expect(copyWithNulls.isDetailedWidgetInstalled, isTrue, reason: 'Should retain all original values when no parameters');
      });

      test('should handle boolean transitions in all directions', () {
        // Test all possible boolean transitions
        for (var origSimple in [false, true]) {
          for (var origDetailed in [false, true]) {
            for (var newSimple in [null, false, true]) {
              for (var newDetailed in [null, false, true]) {
                // Skip if both null (already tested)
                if (newSimple == null && newDetailed == null) continue;
                
                // Arrange
                final original = WidgetInstallationStatus(
                  isSimpleWidgetInstalled: origSimple,
                  isDetailedWidgetInstalled: origDetailed,
                );
                
                // Act
                final copy = original.copyWith(
                  isSimpleWidgetInstalled: newSimple,
                  isDetailedWidgetInstalled: newDetailed,
                );
                
                // Assert - check expected values
                final expectedSimple = newSimple ?? origSimple;
                final expectedDetailed = newDetailed ?? origDetailed;
                
                expect(
                  copy.isSimpleWidgetInstalled, 
                  equals(expectedSimple),
                  reason: 'Simple widget should be $expectedSimple for orig=$origSimple, new=$newSimple'
                );
                expect(
                  copy.isDetailedWidgetInstalled, 
                  equals(expectedDetailed),
                  reason: 'Detailed widget should be $expectedDetailed for orig=$origDetailed, new=$newDetailed'
                );
              }
            }
          }
        }
      });
    });

    /// equality tests
    group('equality and hashCode', () {
      test('instances with same values should be equal', () {
        // Test all combinations of boolean values
        for (var simple in [false, true]) {
          for (var detailed in [false, true]) {
            // Arrange - create two separate instances with same values
            final status1 = WidgetInstallationStatus(
              isSimpleWidgetInstalled: simple,
              isDetailedWidgetInstalled: detailed,
            );
            final status2 = WidgetInstallationStatus(
              isSimpleWidgetInstalled: simple,
              isDetailedWidgetInstalled: detailed,
            );
            
            // Assert
            expect(status1, equals(status2), reason: 'Instances with same values should be equal');
            expect(status1.hashCode, equals(status2.hashCode), reason: 'Equal objects should have equal hash codes');
          }
        }
      });

      test('instances with different values should not be equal', () {
        // Create all possible combinations that should not be equal
        final cases = [
          {
            'a': WidgetInstallationStatus(isSimpleWidgetInstalled: false, isDetailedWidgetInstalled: false),
            'b': WidgetInstallationStatus(isSimpleWidgetInstalled: true, isDetailedWidgetInstalled: false),
          },
          {
            'a': WidgetInstallationStatus(isSimpleWidgetInstalled: false, isDetailedWidgetInstalled: false),
            'b': WidgetInstallationStatus(isSimpleWidgetInstalled: false, isDetailedWidgetInstalled: true),
          },
          {
            'a': WidgetInstallationStatus(isSimpleWidgetInstalled: false, isDetailedWidgetInstalled: false),
            'b': WidgetInstallationStatus(isSimpleWidgetInstalled: true, isDetailedWidgetInstalled: true),
          },
          {
            'a': WidgetInstallationStatus(isSimpleWidgetInstalled: true, isDetailedWidgetInstalled: false),
            'b': WidgetInstallationStatus(isSimpleWidgetInstalled: false, isDetailedWidgetInstalled: true),
          },
          {
            'a': WidgetInstallationStatus(isSimpleWidgetInstalled: true, isDetailedWidgetInstalled: false),
            'b': WidgetInstallationStatus(isSimpleWidgetInstalled: true, isDetailedWidgetInstalled: true),
          },
          {
            'a': WidgetInstallationStatus(isSimpleWidgetInstalled: false, isDetailedWidgetInstalled: true),
            'b': WidgetInstallationStatus(isSimpleWidgetInstalled: true, isDetailedWidgetInstalled: true),
          },
        ];
        
        // Test each case
        for (var i = 0; i < cases.length; i++) {
          final a = cases[i]['a']!;
          final b = cases[i]['b']!;
          
          // Assert
          expect(a, isNot(equals(b)), reason: 'Case $i: Instances with different values should not be equal');
          // Note: It's technically possible (though unlikely) for different objects to have the same hashCode
          // So we don't test hashCode inequality here
        }
      });
      
      test('should not be equal to instances of different types', () {
        // Arrange
        final status = WidgetInstallationStatus();
        
        // Assert - compare with null
        expect(status == null, isFalse, reason: 'Should not be equal to null');
        
        // Assert - compare with different type
        expect(status == 'not a status object', isFalse, reason: 'Should not be equal to string');
        expect(status == 123, isFalse, reason: 'Should not be equal to int');
        expect(status == <String, bool>{}, isFalse, reason: 'Should not be equal to map');
      });
      
      test('identical instances should be equal', () {
        // Arrange
        final status = WidgetInstallationStatus();
        
        // Assert
        expect(status == status, isTrue, reason: 'Instance should be equal to itself');
        expect(status.hashCode == status.hashCode, isTrue, reason: 'Instance should have same hashCode as itself');
      });
    });

    /// toString tests
    group('toString', () {
      test('should return correct string representation with both false', () {
        // Arrange
        final status = WidgetInstallationStatus();
        
        // Act
        final result = status.toString();
        
        // Assert
        expect(
          result, 
          'WidgetInstallationStatus(isSimpleWidgetInstalled: false, isDetailedWidgetInstalled: false)'
        );
      });
      
      test('should return correct string representation with mixed values', () {
        // Arrange
        final status1 = WidgetInstallationStatus(isSimpleWidgetInstalled: true);
        final status2 = WidgetInstallationStatus(isDetailedWidgetInstalled: true);
        
        // Act & Assert
        expect(
          status1.toString(), 
          'WidgetInstallationStatus(isSimpleWidgetInstalled: true, isDetailedWidgetInstalled: false)'
        );
        expect(
          status2.toString(), 
          'WidgetInstallationStatus(isSimpleWidgetInstalled: false, isDetailedWidgetInstalled: true)'
        );
      });
      
      test('should return correct string representation with both true', () {
        // Arrange
        final status = WidgetInstallationStatus(
          isSimpleWidgetInstalled: true,
          isDetailedWidgetInstalled: true,
        );
        
        // Act
        final result = status.toString();
        
        // Assert
        expect(
          result, 
          'WidgetInstallationStatus(isSimpleWidgetInstalled: true, isDetailedWidgetInstalled: true)'
        );
      });
    });
    
    /// Integration tests
    group('integration', () {
      test('should work correctly in practical usage scenarios', () {
        // Scenario: Updating widget installation status based on platform response
        
        // Initial state - no widgets installed
        var status = WidgetInstallationStatus();
        expect(status.isAnyWidgetInstalled, isFalse);
        
        // User installs simple widget
        status = status.copyWith(isSimpleWidgetInstalled: true);
        expect(status.isSimpleWidgetInstalled, isTrue);
        expect(status.isDetailedWidgetInstalled, isFalse);
        expect(status.isAnyWidgetInstalled, isTrue);
        
        // User installs detailed widget
        status = status.copyWith(isDetailedWidgetInstalled: true);
        expect(status.isSimpleWidgetInstalled, isTrue);
        expect(status.isDetailedWidgetInstalled, isTrue);
        expect(status.isAnyWidgetInstalled, isTrue);
        
        // User removes simple widget
        status = status.copyWith(isSimpleWidgetInstalled: false);
        expect(status.isSimpleWidgetInstalled, isFalse);
        expect(status.isDetailedWidgetInstalled, isTrue);
        expect(status.isAnyWidgetInstalled, isTrue);
        
        // User removes detailed widget
        status = status.copyWith(isDetailedWidgetInstalled: false);
        expect(status.isSimpleWidgetInstalled, isFalse);
        expect(status.isDetailedWidgetInstalled, isFalse);
        expect(status.isAnyWidgetInstalled, isFalse);
      });
    });
  });
}
