import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/food_text_input/presentation/widgets/food_text_input_analysis_error.dart';

void main() {
  testWidgets('FoodTextInputAnalysisError displays correct UI elements', (WidgetTester tester) async {
    const Color primaryPink = Color(0xFFFF6B6B);
    const Color primaryYellow = Color(0xFFFFE893);
    
    bool retried = false;
    bool wentBack = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodTextInputAnalysisError(
            primaryPink: primaryPink,
            primaryYellow: primaryYellow,
            onRetry: () => retried = true,
            onBack: () => wentBack = true,
          ),
        ),
      ),
    );
    
    expect(find.text("Oops! We Couldn't Detect Your Food"), findsOneWidget);
        
    expect(find.text('Tips for Better Input:'), findsOneWidget);
    expect(find.textContaining('Use common food names'), findsOneWidget);
    expect(find.textContaining('Include ingredients if possible'), findsOneWidget);
    expect(find.textContaining('Avoid brand names or slang words'), findsOneWidget);
    expect(find.textContaining('Check for typos before submitting'), findsOneWidget);
    
    expect(find.text('Edit Input'), findsOneWidget);
    expect(find.text('Retry Analysis'), findsOneWidget);
    
    await tester.tap(find.text('Retry Analysis'));
    await tester.pump();
    expect(retried, isTrue);
    
    await tester.tap(find.text('Edit Input'));
    await tester.pump();
    expect(wentBack, isTrue);
  });
}
