// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:pockeat/features/authentication/services/bug_report_service.dart';
import 'package:pockeat/features/authentication/services/login_service.dart';
import 'package:pockeat/features/authentication/services/logout_service.dart';
import 'package:pockeat/features/user_preferences/services/user_preferences_service.dart';

/// This test specifically focuses on the calorie compensation toggle feature
/// in the profile page without loading the full ProfilePage widget which has too many dependencies
///
/// We're creating a simpler test widget that only tests the toggle functionality

// Mock classes
class MockUserPreferencesService extends Mock
    implements UserPreferencesService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockLoginService extends Mock implements LoginService {}

class MockLogoutService extends Mock implements LogoutService {}

class MockBugReportService extends Mock implements BugReportService {}

class MockUserInfo extends Mock implements UserInfo {}

/// A simplified version of the exercise calorie compensation widget to test
class CalorieCompensationToggle extends StatefulWidget {
  final UserPreferencesService preferencesService;

  const CalorieCompensationToggle({
    Key? key,
    required this.preferencesService,
  }) : super(key: key);

  @override
  State<CalorieCompensationToggle> createState() =>
      _CalorieCompensationToggleState();
}

class _CalorieCompensationToggleState extends State<CalorieCompensationToggle> {
  bool _isCalorieCompensationEnabled = false;
  bool _loadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    setState(() {
      _loadingPreferences = true;
    });

    try {
      final isEnabled = await widget.preferencesService
          .isExerciseCalorieCompensationEnabled();

      setState(() {
        _isCalorieCompensationEnabled = isEnabled;
        _loadingPreferences = false;
      });
    } catch (e) {
      setState(() {
        _loadingPreferences = false;
      });
    }
  }

  Future<void> _toggleExerciseCalorieCompensation(bool value) async {
    setState(() {
      _isCalorieCompensationEnabled = value;
    });

    try {
      await widget.preferencesService
          .setExerciseCalorieCompensationEnabled(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'Kalori dari olahraga akan dikompensasi dalam sisa kalori'
                : 'Kalori dari olahraga tidak diperhitungkan dalam sisa kalori'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Revert state if there was an error
      setState(() {
        _isCalorieCompensationEnabled = !value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah pengaturan: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan Kalori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hitung Kalori Terbakar',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kalori terbakar akan ditambahkan ke sisa kalori harian Anda',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _loadingPreferences
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: _isCalorieCompensationEnabled,
                        onChanged: _toggleExerciseCalorieCompensation,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  late MockUserPreferencesService mockPreferencesService;

  setUp(() {
    mockPreferencesService = MockUserPreferencesService();

    // Reset any previous registrations
    GetIt.instance.reset();
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget(
      {required bool initialPreference, bool delayLoading = false}) {
    // Setup the mock behavior
    when(() => mockPreferencesService.isExerciseCalorieCompensationEnabled())
        .thenAnswer((_) => delayLoading
            ? Future.delayed(
                const Duration(milliseconds: 100), () => initialPreference)
            : Future.value(initialPreference));

    return MaterialApp(
      home:
          CalorieCompensationToggle(preferencesService: mockPreferencesService),
    );
  }

  group('CalorieCompensationToggle', () {
    testWidgets('should show loading indicator while preference is loading',
        (WidgetTester tester) async {
      // Arrange - use delayed loading to ensure we can see the loading state
      await tester.pumpWidget(
          createTestWidget(initialPreference: false, delayLoading: true));

      // Assert - should have a loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future and remove loading indicator
      await tester.pumpAndSettle();
    });

    testWidgets(
        'should display toggle with correct initial state when preferences loaded',
        (WidgetTester tester) async {
      // Arrange - set initial preference to ON
      await tester.pumpWidget(createTestWidget(initialPreference: true));

      // Wait for futures to complete
      await tester.pumpAndSettle();

      // Assert - toggle should be on
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('should update preference when toggle is switched',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPreferencesService.setExerciseCalorieCompensationEnabled(
          any())).thenAnswer((_) => Future.value());

      await tester.pumpWidget(createTestWidget(initialPreference: false));
      await tester.pumpAndSettle();

      // Act - tap the switch to toggle it on
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert - should call the service to update preference
      verify(() => mockPreferencesService
          .setExerciseCalorieCompensationEnabled(true)).called(1);

      // The switch should now be on
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets(
        'should show snackbar with success message when toggle is changed successfully',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPreferencesService.setExerciseCalorieCompensationEnabled(
          any())).thenAnswer((_) => Future.value());

      await tester.pumpWidget(createTestWidget(initialPreference: false));
      await tester.pumpAndSettle();

      // Act - tap the switch to toggle it on
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert - should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text('Kalori dari olahraga akan dikompensasi dalam sisa kalori'),
          findsOneWidget);
    });

    testWidgets('should show error snackbar when toggle update fails',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPreferencesService.setExerciseCalorieCompensationEnabled(
          any())).thenAnswer((_) => Future.error('Service error'));

      await tester.pumpWidget(createTestWidget(initialPreference: false));
      await tester.pumpAndSettle();

      // Act - tap the switch to toggle it on
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert - should show error snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Gagal mengubah pengaturan:'), findsOneWidget);

      // Switch should revert to original state
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });
  });
}
