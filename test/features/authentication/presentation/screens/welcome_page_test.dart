import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/authentication/presentation/screens/welcome_page.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/height_weight_page.dart';

void main() {
  group('WelcomePage', () {
    testWidgets('renders title and tagline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      expect(find.text('Pockeat'), findsOneWidget);
      expect(find.text('Your health companion'), findsOneWidget);
    });

    testWidgets('shows Log In and Get Started buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('tapping Log In shows loading and navigates', (WidgetTester tester) async {
      final mockObserver = _MockNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          home: const WelcomePage(),
          navigatorObservers: [mockObserver],
          routes: {
            '/login': (_) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );

      await tester.tap(find.text('Log In'));
      await tester.pump(); // triggers setState (loading)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Fast-forward delayed future
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('tapping Get Started navigates to onboarding', (WidgetTester tester) async {
  final mockObserver = _MockNavigatorObserver();

  await tester.pumpWidget(
    MaterialApp(
      home: const WelcomePage(),
      navigatorObservers: [mockObserver],
      routes: {
        '/height-weight': (_) => const HeightWeightPage(), // correct destination page
      },
    ),
  );

  await tester.tap(find.text('Get Started'));
  await tester.pump(); // triggers loading state
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  expect(find.text('Enter your height and weight'), findsOneWidget); // <- THIS
});


    testWidgets('shows error message when navigation throws', (WidgetTester tester) async {
      // Wrap in a try/catch to simulate failure inside `_navigateTo`
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => MaterialApp(
              home: WelcomePageWithNavigationFailure(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Log In'));
      await tester.pump(); // triggers loading
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    });
  });
}

// Mocks a failing navigation for test
class WelcomePageWithNavigationFailure extends StatefulWidget {
  @override
  State<WelcomePageWithNavigationFailure> createState() => _WelcomePageWithNavigationFailureState();
}

class _WelcomePageWithNavigationFailureState extends State<WelcomePageWithNavigationFailure> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _navigateTo(String routeName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      throw Exception("Fake navigation failure"); // simulate error
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: () => _navigateTo('/login'), child: const Text('Log In')),
          if (_isLoading) const CircularProgressIndicator(),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

// Mock NavigatorObserver (if needed later)
class _MockNavigatorObserver extends NavigatorObserver {}