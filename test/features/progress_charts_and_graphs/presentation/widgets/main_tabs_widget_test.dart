// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/main_tabs_widget.dart';

void main() {
  late AppColors colors;
  
  setUp(() {
    // Create the AppColors
    colors = AppColors.defaultColors();
  });
  
  group('MainTabsWidget', () {
    testWidgets('should render correct tab titles', (WidgetTester tester) async {
      // We need a TickerProvider for TabController
      final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;
      final TabController controller = TabController(
        length: 2,
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                MainTabsWidget(
                  tabController: controller,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Updated to match the actual tab titles in the implementation
      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Log History'), findsOneWidget);
      
      // Clean up
      controller.dispose();
    });
    
    testWidgets('should have correct properties for SliverPersistentHeader', (WidgetTester tester) async {
      // We need a TickerProvider for TabController
      final TabController controller = TabController(
        length: 2,
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                MainTabsWidget(
                  tabController: controller,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Find the SliverPersistentHeader
      final sliverPersistentHeader = tester.widget<SliverPersistentHeader>(
        find.byType(SliverPersistentHeader)
      );
      
      // Verify SliverPersistentHeader properties
      expect(sliverPersistentHeader.pinned, isTrue);
      
      // Verify the delegate is not null (we can't check the exact type since it's private)
      expect(sliverPersistentHeader.delegate, isNotNull);
      
      // Clean up
      controller.dispose();
    });
    
    testWidgets('should configure TabBar with correct properties', (WidgetTester tester) async {
      // We need a TickerProvider for TabController
      final TabController controller = TabController(
        length: 2,
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                MainTabsWidget(
                  tabController: controller,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Find the TabBar
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      
      // Verify TabBar properties
      expect(tabBar.controller, equals(controller));
      expect(tabBar.labelColor, equals(colors.primaryPink));
      expect(tabBar.unselectedLabelColor, equals(Colors.black54));
      expect(tabBar.indicatorColor, equals(colors.primaryPink));
      expect(tabBar.indicatorWeight, equals(2));
      expect(tabBar.indicatorSize, equals(TabBarIndicatorSize.label));
      
      // Check text styles
      expect(tabBar.labelStyle?.fontSize, equals(15));
      expect(tabBar.labelStyle?.fontWeight, equals(FontWeight.w600));
      expect(tabBar.unselectedLabelStyle?.fontSize, equals(15));
      expect(tabBar.unselectedLabelStyle?.fontWeight, equals(FontWeight.w400));
      
      // Clean up
      controller.dispose();
    });
    
    testWidgets('should pass the tab controller to the TabBar', (WidgetTester tester) async {
      // We need a TickerProvider for TabController
      final TabController controller = TabController(
        length: 2,
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                MainTabsWidget(
                  tabController: controller,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Verify tab controller is properly passed to TabBar
      final TabBar tabBar = tester.widget(find.byType(TabBar));
      expect(tabBar.controller, equals(controller));
      
      // Verify tab change works
      expect(controller.index, equals(0));
      controller.animateTo(1);
      await tester.pumpAndSettle();
      expect(controller.index, equals(1));
      
      // Clean up
      controller.dispose();
    });
    
    testWidgets('should use Container with correct background color', (WidgetTester tester) async {
      // We need a TickerProvider for TabController
      final TabController controller = TabController(
        length: 2,
        vsync: const TestVSync(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                MainTabsWidget(
                  tabController: controller,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      );
      
      // Find the first Container that's a child of SliverPersistentHeader
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SliverPersistentHeader),
          matching: find.byType(Container),
        )
      );
      
      // Verify Container properties
      expect(container.color, equals(Colors.white));
      
      // Clean up
      controller.dispose();
    });
  });
}

// A TestVSync implementation to use with TabController
class TestVSync extends TickerProvider {
  const TestVSync();
  
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick, debugLabel: 'created by TestVSync');
}
