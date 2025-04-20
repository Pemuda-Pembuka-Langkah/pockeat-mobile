import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/app_colors.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/main_tabs_widget.dart';

void main() {
  late TabController tabController;
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
      
      // Verify the tab titles
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Log History'), findsOneWidget);
      
      // Clean up
      controller.dispose();
    });
    
    testWidgets('should have correct properties for SliverAppBar', (WidgetTester tester) async {
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
      
      // Find the SliverAppBar
      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      
      // Verify SliverAppBar properties
      expect(sliverAppBar.pinned, isTrue);
      expect(sliverAppBar.floating, isFalse);
      expect(sliverAppBar.backgroundColor, equals(Colors.white));
      expect(sliverAppBar.toolbarHeight, equals(0));
      
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
      expect(tabBar.labelPadding, equals(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)));
      
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
  });
}

// A TestVSync implementation to use with TabController
class TestVSync extends TickerProvider {
  const TestVSync();
  
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick, debugLabel: 'created by TestVSync');
}