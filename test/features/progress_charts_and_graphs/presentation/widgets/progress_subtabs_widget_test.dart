import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/tab_configuration.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/progress_subtabs_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/progress_tab_item_widget.dart';

// Create mock class for ScrollController
@GenerateMocks([ScrollController])
import 'progress_subtabs_widget_test.mocks.dart';

class MockTabController extends Mock implements TabController {
  final int _index;
  final List<VoidCallback> _listeners = [];

  MockTabController(this._index);
  
  @override
  int get index => _index;
  
  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
  
  @override
  void animateTo(int index, {Curve? curve, Duration? duration}) {}
}

void main() {
  late AppColors colors;
  late TabConfiguration tabConfiguration;
  late MockScrollController scrollController;
  
  setUp(() {
    colors = AppColors.defaultColors();
    tabConfiguration = TabConfiguration(
      mainTabCount: 2,
      progressTabCount: 3,
      progressTabLabels: ['Weight', 'Nutrition', 'Exercise'],
      logHistoryTabCount: 1,
      logHistoryTabLabels: ['Log History'],
    );
    scrollController = MockScrollController();
  });

  group('ProgressSubtabsWidget', () {
    testWidgets('should initialize and render correctly when main tab index is 0',
        (WidgetTester tester) async {
      // Arrange - Create controllers with main tab index 0 (Progress tab)
      final mainTabController = MockTabController(0);
      final progressTabController = MockTabController(1); // Nutrition tab selected
      
      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ProgressSubtabsWidget(
                  mainTabController: mainTabController,
                  progressTabController: progressTabController,
                  scrollController: scrollController,
                  colors: colors,
                  tabConfiguration: tabConfiguration,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert - Check that the widget is visible
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(ProgressTabItemWidget), findsExactly(3)); // 3 tabs
      
      // Check the selected tab (Nutrition - index 1)
      final tabItems = tester.widgetList<ProgressTabItemWidget>(find.byType(ProgressTabItemWidget)).toList();
      expect(tabItems[0].isSelected, isFalse);
      expect(tabItems[1].isSelected, isTrue);
      expect(tabItems[2].isSelected, isFalse);
      
      // Check tab labels are rendered correctly
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Nutrition'), findsOneWidget);
      expect(find.text('Exercise'), findsOneWidget);
    });
    
    testWidgets('should not be visible when main tab index is not 0',
        (WidgetTester tester) async {
      // Arrange - Create controllers with main tab index 1 (Insights tab)
      final mainTabController = MockTabController(1);
      final progressTabController = MockTabController(0);
      
      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ProgressSubtabsWidget(
                  mainTabController: mainTabController,
                  progressTabController: progressTabController,
                  scrollController: scrollController,
                  colors: colors,
                  tabConfiguration: tabConfiguration,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert - Check that the widget is not visible
      expect(find.byType(ProgressTabItemWidget), findsNothing);
    });
    
    testWidgets('should handle tab tap and trigger tab animation',
        (WidgetTester tester) async {
      // Arrange
      final mainTabController = MockTabController(0);
      final progressTabController = MockTabController(0);
      
      // Setup mock for scrollController
      when(scrollController.animateTo(
        any,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      )).thenAnswer((_) => Future.value());
      
      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ProgressSubtabsWidget(
                  mainTabController: mainTabController,
                  progressTabController: progressTabController,
                  scrollController: scrollController,
                  colors: colors,
                  tabConfiguration: tabConfiguration,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Find the second tab (Nutrition) and tap it
      final secondTab = find.text('Nutrition');
      await tester.tap(secondTab);
      await tester.pump();
      
      // Verify scroll controller animation was called
      verify(scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      )).called(1);
    });
    
    testWidgets('should update UI when tab controller notifies listeners',
        (WidgetTester tester) async {
      // Arrange - Create controllers
      final mainTabController = MockTabController(0);
      final progressTabController = MockTabController(0); // Initially Weight tab
      
      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ProgressSubtabsWidget(
                  mainTabController: mainTabController,
                  progressTabController: progressTabController,
                  scrollController: scrollController,
                  colors: colors,
                  tabConfiguration: tabConfiguration,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Initial state - Weight tab selected
      var tabItems = tester.widgetList<ProgressTabItemWidget>(find.byType(ProgressTabItemWidget)).toList();
      expect(tabItems[0].isSelected, isTrue);
      expect(tabItems[1].isSelected, isFalse);
      
      // Create a new controller with different selected tab
      final newProgressTabController = MockTabController(1); // Nutrition tab
      
      // Rebuild with new controller
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ProgressSubtabsWidget(
                  mainTabController: mainTabController,
                  progressTabController: newProgressTabController,
                  scrollController: scrollController,
                  colors: colors,
                  tabConfiguration: tabConfiguration,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Check if the UI updated
      tabItems = tester.widgetList<ProgressTabItemWidget>(find.byType(ProgressTabItemWidget)).toList();
      expect(tabItems[0].isSelected, isFalse);
      expect(tabItems[1].isSelected, isTrue);
    });
    
    testWidgets('should have correct SliverAppBar properties', (WidgetTester tester) async {
      // Arrange
      final mainTabController = MockTabController(0);
      final progressTabController = MockTabController(0);
      
      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ProgressSubtabsWidget(
                  mainTabController: mainTabController,
                  progressTabController: progressTabController,
                  scrollController: scrollController,
                  colors: colors,
                  tabConfiguration: tabConfiguration,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert - Check SliverAppBar properties
      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.pinned, isFalse);
      expect(sliverAppBar.floating, isTrue);
      expect(sliverAppBar.snap, isTrue);
      expect(sliverAppBar.backgroundColor, equals(Colors.white));
      expect(sliverAppBar.toolbarHeight, equals(64));
      expect(sliverAppBar.elevation, equals(2));
    });
    
    testWidgets('should have container with correct decoration', (WidgetTester tester) async {
      // Arrange
      final mainTabController = MockTabController(0);
      final progressTabController = MockTabController(0);
      
      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ProgressSubtabsWidget(
                  mainTabController: mainTabController,
                  progressTabController: progressTabController,
                  scrollController: scrollController,
                  colors: colors,
                  tabConfiguration: tabConfiguration,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert - Find the container and check its decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Padding),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.grey[100]));
      expect(decoration.borderRadius, equals(BorderRadius.circular(12)));
    });
    
    testWidgets('should pass correct properties to ProgressTabItemWidget', 
        (WidgetTester tester) async {
      // Arrange
      final mainTabController = MockTabController(0);
      final progressTabController = MockTabController(0); // Weight tab selected
      
      // Act - Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ProgressSubtabsWidget(
                  mainTabController: mainTabController,
                  progressTabController: progressTabController,
                  scrollController: scrollController,
                  colors: colors,
                  tabConfiguration: tabConfiguration,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Assert - Check the properties of the ProgressTabItemWidgets
      final tabItems = tester.widgetList<ProgressTabItemWidget>(find.byType(ProgressTabItemWidget)).toList();
      
      // Check first tab (Weight)
      expect(tabItems[0].label, equals('Weight'));
      expect(tabItems[0].index, equals(0));
      expect(tabItems[0].isSelected, isTrue);
      expect(tabItems[0].colors, equals(colors));
      
      // Check second tab (Nutrition)
      expect(tabItems[1].label, equals('Nutrition'));
      expect(tabItems[1].index, equals(1));
      expect(tabItems[1].isSelected, isFalse);
      expect(tabItems[1].colors, equals(colors));
      
      // Check third tab (Exercise)
      expect(tabItems[2].label, equals('Exercise'));
      expect(tabItems[2].index, equals(2));
      expect(tabItems[2].isSelected, isFalse);
      expect(tabItems[2].colors, equals(colors));
    });
  });
}