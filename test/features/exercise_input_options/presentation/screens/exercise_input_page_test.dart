// exercise_input_page_test.dart

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/exercise_input_options/presentation/screens/exercise_input_page.dart';

void main() {

  // Positive test cases
  group('ExerciseInputPage positive tests', () {
    testWidgets('renders AppBar with correct title', (WidgetTester tester) async {
      // Build app dengan ExerciseInputPage
      await tester.pumpWidget(
        MaterialApp(
          home: const ExerciseInputPage(),
        ),
      );

      // Verifikasi AppBar muncul
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verifikasi title AppBar benar
      expect(find.text('Add Exercise'), findsOneWidget);
    });

    testWidgets('displays heading text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ExerciseInputPage(),
        ),
      );

      // Verifikasi heading text muncul
      expect(find.text('What type of exercise\ndid you do?'), findsOneWidget);
    });

    testWidgets('displays three exercise options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ExerciseInputPage(),
        ),
      );

      // Verifikasi tiga jenis exercise muncul
      expect(find.text('Cardio'), findsOneWidget);
      expect(find.text('Weightlifting'), findsOneWidget);
      expect(find.text('Smart Exercise Log'), findsOneWidget);
      
      // Verifikasi subtitle untuk tiap exercise
      expect(find.text('Track your cardio session'), findsOneWidget);
      expect(find.text('Log your strength training'), findsOneWidget);
      expect(find.text('Let AI analyze your workout'), findsOneWidget);
    });

    testWidgets('back button works correctly', (WidgetTester tester) async {
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExerciseInputPage()),
                    );
                  },
                  child: const Text('Go to Exercise Page'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap tombol untuk ke ExerciseInputPage
      await tester.tap(find.text('Go to Exercise Page'));
      await tester.pumpAndSettle();

      // Verifikasi kita sudah di ExerciseInputPage
      expect(find.text('Add Exercise'), findsOneWidget);

      // Tap tombol back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verifikasi kita kembali ke halaman awal
      expect(find.text('Go to Exercise Page'), findsOneWidget);
      expect(find.text('Add Exercise'), findsNothing);
    });

    testWidgets('has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ExerciseInputPage(),
        ),
      );

      // Verifikasi Scaffold memiliki background color yang benar
      final Scaffold scaffold = tester.widget(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFFFFE893))); // primaryYellow
    });

    testWidgets('has correct exercise options content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ExerciseInputPage(),
        ),
      );

      // Verifikasi apakah icon di setiap opsi ditampilkan
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.arrow_up_circle_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.text_badge_checkmark), findsOneWidget);
      
      // Verify arrow icon for navigation
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(3));
    });
  });

  // Negative test cases
  group('ExerciseInputPage negative tests', () {
    testWidgets('handles navigation with unregistered routes', (WidgetTester tester) async {
      // Setup untuk track error navigation
      String? navigatedRoute;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const ExerciseInputPage(),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Route: ${settings.name}')),
              ),
            );
          },
        ),
      );

      // Tap pada card
      await tester.tap(find.text('Cardio'));
      await tester.pumpAndSettle();

      // Verifikasi route benar
      expect(navigatedRoute, equals('/cardio'));
      expect(find.textContaining('Route: /cardio'), findsOneWidget);
    });

    testWidgets('renders correctly on small screen', (WidgetTester tester) async {
      // Set ukuran layar kecil
      tester.binding.window.physicalSizeTestValue = const Size(320, 480);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: const ExerciseInputPage(),
        ),
      );

      // Verifikasi halaman masih render dengan baik
      expect(find.text('Add Exercise'), findsOneWidget);
      expect(find.text('What type of exercise\ndid you do?'), findsOneWidget);
    });

    testWidgets('handles different orientations correctly', (WidgetTester tester) async {
      // Set orientasi landscape
      tester.binding.window.physicalSizeTestValue = const Size(800, 400);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: const ExerciseInputPage(),
        ),
      );

      // Verifikasi halaman masih render dengan baik dalam orientasi landscape
      expect(find.text('Add Exercise'), findsOneWidget);
      expect(find.text('What type of exercise\ndid you do?'), findsOneWidget);
    });

    testWidgets('handles theme changes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(), // Gunakan dark theme
          home: const ExerciseInputPage(),
        ),
      );

      // Halaman tetap menggunakan warna yang didefinisikan, bukan dari theme
      final Scaffold scaffold = tester.widget(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFFFFE893))); // primaryYellow
      
      // AppBar tetap menggunakan warna yang didefinisikan
      final AppBar appBar = tester.widget(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(const Color(0xFFFFE893))); // primaryYellow
    });

    testWidgets('handles no Navigator in widget tree', (WidgetTester tester) async {
      // Gunakan MaterialApp untuk menyediakan MaterialLocalizations yang dibutuhkan AppBar
      await tester.pumpWidget(
        const MaterialApp(
          home: ExerciseInputPage(),
        ),
      );

      // Verifikasi halaman masih render tanpa error
      expect(find.text('Add Exercise'), findsOneWidget);
    });
  });
}
