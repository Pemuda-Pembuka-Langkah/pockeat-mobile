// Create a file: test/font_test.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('PlusJakartaSans Font Tests', () {
    test('Font files exist in the correct directory', () {
      // List of expected font files
      final fontFiles = [
        'PlusJakartaSans-Regular.ttf',
        'PlusJakartaSans-Bold.ttf',
        'PlusJakartaSans-Medium.ttf',
        // Add other font files you're using
      ];
      
      // Check if each file exists
      for (final fontFile in fontFiles) {
        final file = File('assets/fonts/$fontFile');
        expect(file.existsSync(), true, 
            reason: 'Font file $fontFile not found in assets/fonts directory');
      }
    });
    
    test('pubspec.yaml has PlusJakartaSans font configured', () {
      // Read and parse pubspec.yaml
      final pubspecFile = File('pubspec.yaml');
      final yamlString = pubspecFile.readAsStringSync();
      final yaml = loadYaml(yamlString);
      
      // Check if font family is declared
      final fonts = yaml['flutter']['fonts'];
      expect(fonts, isNotNull, reason: 'fonts section not found in pubspec.yaml');
      
      bool fontFamilyFound = false;
      for (var font in fonts) {
        if (font['family'] == 'PlusJakartaSans') {
          fontFamilyFound = true;
          break;
        }
      }
      
      expect(fontFamilyFound, true, 
          reason: 'PlusJakartaSans font family not found in pubspec.yaml');
    });
    
    testWidgets('Text widget can be created with PlusJakartaSans font family', 
        (WidgetTester tester) async {
      // Build a simple Text widget with PlusJakartaSans
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              'Testing PlusJakartaSans',
              style: TextStyle(fontFamily: 'PlusJakartaSans'),
            ),
          ),
        ),
      );
      
      // Verify text widget was created
      final textFinder = find.text('Testing PlusJakartaSans');
      expect(textFinder, findsOneWidget);
      
      // Get the Text widget
      final textWidget = tester.widget<Text>(textFinder);
      
      // Verify font family
      expect(textWidget.style?.fontFamily, equals('PlusJakartaSans'));
    });
  });
}