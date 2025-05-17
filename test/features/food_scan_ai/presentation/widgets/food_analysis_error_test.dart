// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_analysis_error.dart';

void main() {
  const primaryPink = Color(0xFFFF6B6B);
  const primaryYellow = Color(0xFFFFE893);

  testWidgets('FoodAnalysisError displays all UI elements correctly',
      (WidgetTester tester) async {
    bool retryPressed = false;
    bool backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodAnalysisError(
            errorMessage: 'Test error message',
            primaryPink: primaryPink,
            primaryYellow: primaryYellow,
            onRetry: () => retryPressed = true,
            onBack: () => backPressed = true,
          ),
        ),
      ),
    );

    // Verify error icon is displayed
    expect(find.byIcon(CupertinoIcons.exclamationmark_circle), findsOneWidget);

    // Verify title is displayed
    expect(find.text('Makanan Tidak Terdeteksi'), findsOneWidget);

    // Verify error description is displayed
    expect(
      find.text(
          'AI kami tidak dapat mengidentifikasi makanan dalam foto. Pastikan makanan terlihat jelas dan coba lagi.'),
      findsOneWidget,
    );

    // Verify tips section is displayed
    expect(find.text('Tips untuk Foto yang Lebih Baik:'), findsOneWidget);

    // Verify all tips are displayed
    expect(find.text('Pastikan pencahayaan cukup terang'), findsOneWidget);
    expect(find.text('Ambil foto dari sudut atas'), findsOneWidget);
    expect(find.text('Hindari bayangan yang menutupi makanan'), findsOneWidget);
    expect(find.text('Pastikan seluruh makanan terlihat dalam frame'),
        findsOneWidget);

    // Verify buttons are displayed
    expect(find.text('Kembali'), findsOneWidget);
    expect(find.text('Foto Ulang'), findsOneWidget);
  });

  testWidgets('FoodAnalysisError buttons trigger callbacks when pressed',
      (WidgetTester tester) async {
    bool retryPressed = false;
    bool backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodAnalysisError(
            errorMessage: 'Test error message',
            primaryPink: primaryPink,
            primaryYellow: primaryYellow,
            onRetry: () => retryPressed = true,
            onBack: () => backPressed = true,
          ),
        ),
      ),
    );

    // Tap the back button
    await tester.tap(find.text('Kembali'));
    await tester.pump();

    // Verify back callback was triggered
    expect(backPressed, isTrue);
    expect(retryPressed, isFalse);

    // Reset flags
    backPressed = false;
    retryPressed = false;

    // Tap the retry button
    await tester.tap(find.text('Foto Ulang'));
    await tester.pump();

    // Verify retry callback was triggered
    expect(retryPressed, isTrue);
    expect(backPressed, isFalse);
  });

  testWidgets('FoodAnalysisError uses provided colors correctly',
      (WidgetTester tester) async {
    const customPink = Color(0xFF00FF00); // Custom green color for testing
    const customYellow = Color(0xFF0000FF); // Custom blue color for testing

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodAnalysisError(
            errorMessage: 'Test error message',
            primaryPink: customPink,
            primaryYellow: customYellow,
            onRetry: () {},
            onBack: () {},
          ),
        ),
      ),
    );

    // Find the error icon container
    final iconContainer = tester.widget<Container>(
      find
          .ancestor(
            of: find.byIcon(CupertinoIcons.exclamationmark_circle),
            matching: find.byType(Container),
          )
          .first,
    );

    // Verify the container uses the custom pink color
    final iconDecoration = iconContainer.decoration as BoxDecoration;
    expect(iconDecoration.color, equals(customPink.withOpacity(0.1)));

    // Find the tips container
    final tipsContainer = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Tips untuk Foto yang Lebih Baik:'),
            matching: find.byType(Container),
          )
          .first,
    );

    // Verify the tips container uses the grey color with opacity
    final tipsDecoration = tipsContainer.decoration as BoxDecoration;
    expect(tipsDecoration.color, equals(Colors.grey.withOpacity(0.15)));

    // Find the buttons and verify their colors
    final backButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Kembali'),
        matching: find.byType(OutlinedButton),
      ),
    );

    final retryButton = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Foto Ulang'),
        matching: find.byType(ElevatedButton),
      ),
    );

    // Verify button styles use the custom colors
    final backButtonStyle = backButton.style as ButtonStyle;
    expect(
      backButtonStyle.side?.resolve({}),
      equals(BorderSide(color: customPink)),
    );

    final retryButtonStyle = retryButton.style as ButtonStyle;
    expect(
      retryButtonStyle.backgroundColor?.resolve({}),
      equals(customPink),
    );
  });
}
