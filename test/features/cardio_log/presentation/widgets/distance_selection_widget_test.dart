import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/features/cardio_log/presentation/widgets/distance_selection_widget.dart';

void main() {
  group('DistanceSelectionWidget Tests', () {
    late int changedKm;
    late int changedMeter;
    
    setUp(() {
      changedKm = -1;
      changedMeter = -1;
    });

    Widget createTestableWidget({
      required int selectedKm,
      required int selectedMeter,
      required Function(int) onKmChanged,
      required Function(int) onMeterChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DistanceSelectionWidget(
            primaryColor: Colors.blue,
            selectedKm: selectedKm,
            selectedMeter: selectedMeter,
            onKmChanged: onKmChanged,
            onMeterChanged: onMeterChanged,
          ),
        ),
      );
    }

    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          selectedKm: 5,
          selectedMeter: 300,
          onKmChanged: (km) => changedKm = km,
          onMeterChanged: (meter) => changedMeter = meter,
        ),
      );

      // Verify basic structure
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
      expect(find.text('m'), findsOneWidget);
      expect(find.byType(ListWheelScrollView), findsNWidgets(2));
      
      // Verify total display
      expect(find.text('Total: 5.3 km'), findsOneWidget);
    });

    testWidgets('onKmChanged callback should be triggered when km is changed', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          selectedKm: 5,
          selectedMeter: 0,
          onKmChanged: (km) => changedKm = km,
          onMeterChanged: (meter) => changedMeter = meter,
        ),
      );

      // Find the first ListWheelScrollView (km scroll)
      final kmScroll = find.byType(ListWheelScrollView).first;
      
      // Get the ListWheelScrollView widget
      final ListWheelScrollView kmScrollWidget = tester.widget(kmScroll);
      
      // Directly call the onSelectedItemChanged callback
      kmScrollWidget.onSelectedItemChanged!(10);
      
      // Verify callback was triggered with correct value
      expect(changedKm, 10);
    });

    testWidgets('onMeterChanged callback should be triggered when meter is changed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          selectedKm: 5,
          selectedMeter: 0,
          onKmChanged: (km) => changedKm = km,
          onMeterChanged: (meter) => changedMeter = meter,
        ),
      );

      // Find the second ListWheelScrollView (meter scroll)
      final meterScroll = find.byType(ListWheelScrollView).at(1);
      
      // Get the ListWheelScrollView widget
      final ListWheelScrollView meterScrollWidget = tester.widget(meterScroll);
      
      // Directly call the onSelectedItemChanged callback
      meterScrollWidget.onSelectedItemChanged!(3);
      
      // Verify callback was triggered with correct value (index * 100)
      expect(changedMeter, 300);
    });

    testWidgets('should update total display when values change', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          selectedKm: 5,
          selectedMeter: 0,
          onKmChanged: (km) => changedKm = km,
          onMeterChanged: (meter) => changedMeter = meter,
        ),
      );
      
      // Verify initial total
      expect(find.text('Total: 5.0 km'), findsOneWidget);
      
      // Create a new widget with updated values
      await tester.pumpWidget(
        createTestableWidget(
          selectedKm: 10,
          selectedMeter: 500,
          onKmChanged: (km) => changedKm = km,
          onMeterChanged: (meter) => changedMeter = meter,
        ),
      );
      
      // Verify updated total
      expect(find.text('Total: 10.5 km'), findsOneWidget);
    });

    testWidgets('km scroll should display correct number of items', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          selectedKm: 5,
          selectedMeter: 0,
          onKmChanged: (km) => changedKm = km,
          onMeterChanged: (meter) => changedMeter = meter,
        ),
      );

      // Find the ListWheelScrollView for km
      final kmScroll = find.byType(ListWheelScrollView).first;
      final ListWheelScrollView kmScrollWidget = tester.widget(kmScroll);
      
      // Check number of children (should be 43 for 0-42 km)
      expect(kmScrollWidget.childDelegate.estimatedChildCount, 43);
    });

    testWidgets('meter scroll should display correct number of items', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          selectedKm: 5,
          selectedMeter: 0,
          onKmChanged: (km) => changedKm = km,
          onMeterChanged: (meter) => changedMeter = meter,
        ),
      );

      // Find the ListWheelScrollView for meters
      final meterScroll = find.byType(ListWheelScrollView).at(1);
      final ListWheelScrollView meterScrollWidget = tester.widget(meterScroll);
      
      // Check number of children (should be 10 for 0-900 m in increments of 100)
      expect(meterScrollWidget.childDelegate.estimatedChildCount, 10);
    });
  });
}