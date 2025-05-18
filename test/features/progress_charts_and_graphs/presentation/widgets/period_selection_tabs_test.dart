// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_selection_tabs.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_tab_widget.dart';

void main() {
  group('PeriodSelectionTabs', () {
    // Function to create test widget with required parameters
    Widget createWidget({
      // Perlu menggunakan nilai asli yang digunakan widget di dalam logika, bukan tampilan
      String selectedPeriod = '1 Week',
      Function(String)? onPeriodSelected,
      Color primaryColor = Colors.blue,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PeriodSelectionTabs(
            selectedPeriod: selectedPeriod,
            onPeriodSelected: onPeriodSelected ?? (period) {},
            primaryColor: primaryColor,
          ),
        ),
      );
    }

    testWidgets('renders all period options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Verifikasi hanya dua opsi yang ada sekarang
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      // Tab 'All time' sudah tidak ada lagi
    });

    testWidgets('has correct default selection based on props', (WidgetTester tester) async {
      // PERUBAHAN: Gunakan '1 Week' sebagai nilai internal
      await tester.pumpWidget(createWidget(selectedPeriod: '1 Week'));

      // Verifikasi PeriodTabWidgets memiliki nilai isSelected yang benar
      final weekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Weekly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weekTab.isSelected, true);

      final monthTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Monthly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(monthTab.isSelected, false);
    });

    testWidgets('has correct selection when changed via props', (WidgetTester tester) async {
      // PERUBAHAN: Gunakan '1 Month' sebagai nilai internal
      await tester.pumpWidget(createWidget(selectedPeriod: '1 Month'));

      // Verifikasi PeriodTabWidgets memiliki nilai isSelected yang benar
      final weekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Weekly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weekTab.isSelected, false);

      final monthTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Monthly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(monthTab.isSelected, true);
    });

    testWidgets('calls onPeriodSelected when tapping a tab', (WidgetTester tester) async {
      String selectedPeriod = '1 Week';  // PERUBAHAN: Use internal value '1 Week'

      await tester.pumpWidget(createWidget(
        selectedPeriod: selectedPeriod,
        onPeriodSelected: (period) {
          selectedPeriod = period;
        },
      ));

      // Tap tab 'Monthly'
      await tester.tap(find.text('Monthly'));
      await tester.pump();
      
      // Verifikasi callback dipanggil dan nilai diperbarui
      expect(selectedPeriod, '1 Month');

      // Tap tab 'Weekly' untuk kembali ke keadaan awal
      await tester.tap(find.text('Weekly'));
      await tester.pump();
      
      // Verifikasi callback dipanggil dan nilai diperbarui lagi
      expect(selectedPeriod, '1 Week');
    });

    testWidgets('applies primary color correctly to selected tab', (WidgetTester tester) async {
      const Color testColor = Colors.purple;
      
      await tester.pumpWidget(createWidget(
        selectedPeriod: '1 Week',  // PERUBAHAN: Use internal value '1 Week'
        primaryColor: testColor,
      ));

      // Verifikasi tab yang dipilih memiliki warna yang benar
      final weekTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Weekly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(weekTab.selectedColor, testColor);
      
      // Verifikasi tab lain juga memiliki warna yang sama
      final monthTab = tester.widget<PeriodTabWidget>(
        find.ancestor(
          of: find.text('Monthly'),
          matching: find.byType(PeriodTabWidget),
        ),
      );
      expect(monthTab.selectedColor, testColor);
    });
    
    testWidgets('container has correct decoration properties', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Temukan container luar
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PeriodSelectionTabs),
          matching: find.byType(Container),
        ).first,
      );
      
      // Verifikasi properti dekorasi container
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.grey[200]);
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });
    
    testWidgets('layout uses Row for horizontal arrangement', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Verifikasi Row digunakan untuk layout
      expect(find.byType(Row), findsOneWidget);
      
      // Verifikasi semua PeriodTabWidgets adalah anak langsung dari Row
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 2);
      expect(row.children.every((child) => child is PeriodTabWidget), true);
    });
  });
}
