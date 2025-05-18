// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pockeat/core/di/service_locator.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/calorie_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/domain/models/weight_data.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/screens/update_goal_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/screens/update_weight_page.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/bmi_section.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/calories_chart.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/circular_indicator_widget.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/goal_progress_chart.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/period_selection_tabs.dart';
import 'package:pockeat/features/progress_charts_and_graphs/presentation/widgets/week_selection_tabs.dart';
import 'package:pockeat/features/progress_charts_and_graphs/services/food_log_data_service.dart';

// Firebase imports:

// coverage:ignore-start
class WeightProgressWidget extends StatefulWidget {
  const WeightProgressWidget({super.key});

  @override
  State<WeightProgressWidget> createState() => _WeightProgressWidgetState();
}

class _WeightProgressWidgetState extends State<WeightProgressWidget> {
  // UI constants
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryBlue = const Color(0xFF3498DB);
  final Color primaryOrange = const Color(0xFFFF9800);

  // State variables
  String selectedPeriod = '1 Week';
  String selectedWeek = 'This week';
  bool _isLoadingCalorieData = true;
  List<CalorieData> _calorieData = [];
  double _totalCalories = 0;
  String _currentWeight = "0";
  bool _isLoadingWeight = true;
  String _currentBMI = "0";
  bool _isLoadingBMI = true;
  String _weightGoal = "0";
  bool _isLoadingWeightGoal = true;

  // Weight chart data
  List<WeightData> _weekData = [];
  List<WeightData> _monthData = [];
  bool _isLoadingWeightData = true;

  // New variables
  double? _initialWeight; // Store initial weight from first history record
  double? _goalWeight; // Store goal weight from desiredWeight field

  // Service instance
  late final FoodLogDataService _foodLogDataService;

  @override
  void initState() {
    super.initState();
    _foodLogDataService = getIt<FoodLogDataService>();
    _loadCalorieData();
    _loadCurrentWeight();
    _loadCurrentBMI();
    _loadWeightGoal();
    _loadWeightProgressData();
  }

  // New method to load weight progress data from Firebase
  Future<void> _loadWeightProgressData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingWeightData = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Get user's health metrics document
      final snapshot = await FirebaseFirestore.instance
          .collection('health_metrics')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No health metrics found for user');
      }

      final healthMetricsDoc = snapshot.docs.first;
      final healthMetricsRef = healthMetricsDoc.reference;

      // Get goal weight (desiredWeight) from health_metrics
      final dynamic goalWeightValue = healthMetricsDoc.data()['desiredWeight'];
      final double? goalWeight = goalWeightValue is int
          ? goalWeightValue.toDouble()
          : goalWeightValue is double
              ? goalWeightValue
              : null;

      debugPrint(
          'Found goal weight from health_metrics: ${goalWeight ?? "null"} kg');

      // Get user creation date
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final createdAt = userDoc.data()?['createdAt'] as Timestamp?;
      final userCreationDate = createdAt?.toDate() ??
          DateTime.now().subtract(const Duration(days: 30));

      // Current weight value from health metrics - ensure it's a double
      final dynamic weightValue = healthMetricsDoc.data()['weight'];
      final currentWeight = weightValue is int
          ? weightValue.toDouble()
          : weightValue is double
              ? weightValue
              : 0.0;

      // Load ALL weight history from the weight_history subcollection
      final weightHistoryQuery = await healthMetricsRef
          .collection('weight_history')
          .orderBy('date')
          .get();

      // Find the initial weight (first entry in weight history)
      double? initialWeight;
      if (weightHistoryQuery.docs.isNotEmpty) {
        // Sort by date to ensure we get the earliest record
        final sortedDocs = weightHistoryQuery.docs.toList()
          ..sort((a, b) => (a.data()['date'] as String)
              .compareTo(b.data()['date'] as String));

        if (sortedDocs.isNotEmpty) {
          final firstEntry = sortedDocs.first;
          final dynamic initialWeightValue = firstEntry.data()['weight'];
          initialWeight = initialWeightValue is int
              ? initialWeightValue.toDouble()
              : initialWeightValue is double
                  ? initialWeightValue
                  : null;

          debugPrint(
              'Found initial weight from earliest record (${firstEntry.data()['date']}): ${initialWeight ?? "null"} kg');
        }
      }

      // Map to store historical weights
      final Map<String, double> historicalWeights = {};

      // Fill map with existing data - ensure proper type casting
      for (var doc in weightHistoryQuery.docs) {
        final date = doc.data()['date'] as String? ?? '';

        // Fix: Handle different number types safely
        final dynamic weight = doc.data()['weight'];
        final double weightDouble = weight is int
            ? weight.toDouble()
            : weight is double
                ? weight
                : 0.0;

        if (date.isNotEmpty) {
          historicalWeights[date] = weightDouble;
          debugPrint('Loaded historical weight for $date: $weightDouble kg');
        }
      }

      // Generate all dates from user creation to today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStr = DateFormat('yyyy-MM-dd').format(today); // Add this line
      final List<DateTime> allDates = [];

      // Start from user creation date, normalized to start of day
      DateTime currentDate = DateTime(
        userCreationDate.year,
        userCreationDate.month,
        userCreationDate.day,
      );

      // Generate all dates up to today
      while (
          currentDate.isBefore(today) || currentDate.isAtSameMomentAs(today)) {
        allDates.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }

      debugPrint(
          'Generated ${allDates.length} dates from ${DateFormat('yyyy-MM-dd').format(allDates.first)} to ${DateFormat('yyyy-MM-dd').format(allDates.last)}');

      // Process dates to fill missing entries
      double lastKnownWeight = currentWeight;
      final List<String> newEntryDates = [];
      final batch = FirebaseFirestore.instance.batch();

      for (int i = 0; i < allDates.length; i++) {
        final date = allDates[i];
        final dateStr = DateFormat('yyyy-MM-dd').format(date);

        // If we have data for this date, update the last known weight
        if (historicalWeights.containsKey(dateStr)) {
          lastKnownWeight = historicalWeights[dateStr]!;
          continue;
        }

        // Otherwise create a new entry with the last known weight
        final docRef =
            healthMetricsRef.collection('weight_history').doc(dateStr);
        batch.set(docRef, {
          'weight': lastKnownWeight, // Store as double
          'date': dateStr,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update our map with this new entry
        historicalWeights[dateStr] = lastKnownWeight;
        newEntryDates.add(dateStr);
      }

      // Execute batch if there are any new entries
      if (newEntryDates.isNotEmpty) {
        await batch.commit();
        debugPrint(
            'Created ${newEntryDates.length} new weight history entries for missing dates');
      }

      // Special check for today's date - ensure it has the current weight
      if (historicalWeights.containsKey(todayStr) &&
          historicalWeights[todayStr] != currentWeight) {
        // Update today's entry with current weight if it differs
        await healthMetricsRef
            .collection('weight_history')
            .doc(todayStr)
            .update({
          'weight': currentWeight, // Store as double
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint(
            'Updated today\'s entry with current weight: $currentWeight kg');
        historicalWeights[todayStr] = currentWeight;
      }

      // Generate week data (last 7 days) - dimulai dari Senin
      final weekData = <WeightData>[];

      // Hitung hari pertama dari minggu ini (Senin)
      final int daysFromMonday = now.weekday - 1;
      final DateTime thisWeekMonday =
          DateTime(now.year, now.month, now.day - daysFromMonday);

      // Gunakan label yang sesuai urutan Senin-Minggu
      final weekDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      // Loop untuk 7 hari dimulai dari Senin minggu ini
      for (int i = 0; i < 7; i++) {
        final date = DateTime(
            thisWeekMonday.year, thisWeekMonday.month, thisWeekMonday.day + i);
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final dayOfWeek = weekDayLabels[i];

        // Check if the date is in the future (after today)
        if (date.isAfter(today)) {
          // For future days, keep the label but set weight to 0
          // This will make the chart show a gap but keep the x-axis label
          weekData.add(WeightData(dayOfWeek, 0));
          debugPrint('Future day $dayOfWeek ($dateStr): Setting weight to 0');
        } else {
          // For past or current days, use the historical weight or current weight
          double weightValue = currentWeight; // Default to current weight

          // Get weight from historical data if available
          if (historicalWeights.containsKey(dateStr)) {
            weightValue = historicalWeights[dateStr]!;
          }

          weekData.add(WeightData(dayOfWeek, weightValue));
          debugPrint(
              'Past/Current day $dayOfWeek ($dateStr): Weight $weightValue kg');
        }
      }

      // Generate month data - Week 1 dimulai dari tanggal user register (createdAt)
      final monthData = <WeightData>[];

      // Hitung Monday pertama dari minggu saat user dibuat (untuk penentuan minggu)
      final int daysFromMondayCreation = userCreationDate.weekday - 1;
      final DateTime firstWeekMonday = DateTime(
          userCreationDate.year,
          userCreationDate.month,
          userCreationDate.day - daysFromMondayCreation);

      // Hitung berapa minggu yang telah berlalu sejak user dibuat
      final int weeksSinceCreation =
          (now.difference(firstWeekMonday).inDays / 7).ceil();

      debugPrint(
          'First Monday after creation: ${DateFormat('yyyy-MM-dd').format(firstWeekMonday)}');
      debugPrint('Weeks since creation: $weeksSinceCreation');

      // Kita selalu tampilkan 4 minggu, dimulai dari Week 1
      // Jika user baru (kurang dari 4 minggu), tampilkan Week 1-4
      // Jika user sudah lebih dari 4 minggu, tampilkan 4 minggu terakhir
      int startWeek = math.max(
          1, weeksSinceCreation - 3); // Mulai dari Week 1 atau current-3
      int endWeek =
          math.max(4, weeksSinceCreation); // Tampilkan minimal 4 minggu

      debugPrint('Displaying weeks $startWeek to $endWeek');

      // Siapkan data untuk setiap minggu
      for (int weekNum = startWeek; weekNum <= endWeek; weekNum++) {
        // Hitung tanggal awal minggu ini (Senin dari minggu ke-weekNum setelah firstWeekMonday)
        final DateTime weekStartDate =
            firstWeekMonday.add(Duration(days: (weekNum - 1) * 7));
        final DateTime weekEndDate =
            weekStartDate.add(const Duration(days: 6)); // Minggu

        double weekAverage;

        // Cek jika minggu ini di masa depan
        if (weekStartDate.isAfter(now)) {
          // Untuk minggu di masa depan, set nilai 0.00
          weekAverage = 0.00;
          debugPrint(
              'Week $weekNum (${DateFormat('yyyy-MM-dd').format(weekStartDate)} to ${DateFormat('yyyy-MM-dd').format(weekEndDate)}): '
              'Future week, using 0.00 kg');
        } else {
          // Untuk minggu saat ini atau di masa lalu, hitung rata-rata
          double totalWeight = 0;
          int daysWithData = 0;

          // Iterate through each day in the week
          for (int day = 0; day < 7; day++) {
            final date = weekStartDate.add(Duration(days: day));

            // Skip future days
            if (date.isAfter(now)) {
              continue;
            }

            // Skip days before the user creation date
            if (date.isBefore(userCreationDate)) {
              continue;
            }

            // Get the weight data for this day
            final dateStr = DateFormat('yyyy-MM-dd').format(date);
            if (historicalWeights.containsKey(dateStr)) {
              totalWeight += historicalWeights[dateStr]!;
              daysWithData++;
            }
          }

          // Calculate average weight for this week with 2 decimal precision
          weekAverage = daysWithData > 0
              ? double.parse((totalWeight / daysWithData).toStringAsFixed(2))
              : 0.00; // For weeks with no data, use 0.00

          debugPrint(
              'Week $weekNum (${DateFormat('yyyy-MM-dd').format(weekStartDate)} to ${DateFormat('yyyy-MM-dd').format(weekEndDate)}): '
              'Avg weight ${weekAverage.toStringAsFixed(2)}kg from $daysWithData days');
        }

        // Add data point - use week number as label
        monthData.add(WeightData('Week $weekNum', weekAverage));
      }

      // Debugging output
      debugPrint('Generated ${monthData.length} entries for month chart');

      if (mounted) {
        setState(() {
          _weekData = weekData;
          _monthData = monthData;
          _initialWeight = initialWeight; // Store the initial weight
          _goalWeight = goalWeight; // Store the goal weight
          _isLoadingWeightData = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading weight progress data: $e');
      if (mounted) {
        setState(() {
          _weekData = List.generate(
              7,
              (index) => WeightData(
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index], 0));
          _monthData =
              List.generate(4, (index) => WeightData('Week ${index + 1}', 0));
          _isLoadingWeightData = false;
        });
      }
    }
  }

  Future<void> _loadCalorieData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingCalorieData = true;
    });

    try {
      List<CalorieData> calorieData;

      // Handle different week selections regardless of period selection
      switch (selectedWeek) {
        case 'This week':
          calorieData = await _foodLogDataService.getWeekCalorieData();
          break;
        case 'Last week':
          calorieData =
              await _foodLogDataService.getWeekCalorieData(weeksAgo: 1);
          break;
        case '2 wks. ago':
          calorieData =
              await _foodLogDataService.getWeekCalorieData(weeksAgo: 2);
          break;
        case '3 wks. ago':
          calorieData =
              await _foodLogDataService.getWeekCalorieData(weeksAgo: 3);
          break;
        default:
          calorieData = await _foodLogDataService.getWeekCalorieData();
      }

      final totalCalories =
          _foodLogDataService.calculateTotalCalories(calorieData);

      if (mounted) {
        setState(() {
          _calorieData = calorieData;
          _totalCalories = totalCalories;
          _isLoadingCalorieData = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading calorie data: $e');
      if (mounted) {
        setState(() {
          _calorieData = _getDefaultCalorieData();
          _totalCalories = 0;
          _isLoadingCalorieData = false;
        });
      }
    }
  }

  Future<void> _loadCurrentWeight() async {
    if (!mounted) return;

    setState(() {
      _isLoadingWeight = true;
    });

    try {
      // Get the current user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Query the user's weight entry directly since each userId has a unique record
      final snapshot = await FirebaseFirestore.instance
          .collection('health_metrics')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final weight = data['weight'];

        if (mounted) {
          setState(() {
            _currentWeight = "$weight";
            _isLoadingWeight = false;
          });
        }
      } else {
        // No weight data found
        if (mounted) {
          setState(() {
            _currentWeight = "N/A";
            _isLoadingWeight = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading weight data: $e');
      if (mounted) {
        setState(() {
          _currentWeight = "Error";
          _isLoadingWeight = false;
        });
      }
    }
  }

  Future<void> _loadCurrentBMI() async {
    if (!mounted) return;

    setState(() {
      _isLoadingBMI = true;
    });

    try {
      // Get the current user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Query the user's BMI entry
      final snapshot = await FirebaseFirestore.instance
          .collection('health_metrics')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final bmi = data['bmi'];

        // Format to 2 decimal places
        final formattedBMI = bmi is double
            ? bmi.toStringAsFixed(2)
            : double.parse(bmi.toString()).toStringAsFixed(2);

        if (mounted) {
          setState(() {
            _currentBMI = formattedBMI;
            _isLoadingBMI = false;
          });
        }
      } else {
        // No BMI data found
        if (mounted) {
          setState(() {
            _currentBMI = "N/A";
            _isLoadingBMI = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading BMI data: $e');
      if (mounted) {
        setState(() {
          _currentBMI = "Error";
          _isLoadingBMI = false;
        });
      }
    }
  }

  Future<void> _loadWeightGoal() async {
    if (!mounted) return;

    setState(() {
      _isLoadingWeightGoal = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('health_metrics')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final desiredWeight = data['desiredWeight'];

        if (mounted) {
          setState(() {
            _weightGoal = "$desiredWeight";
            _isLoadingWeightGoal = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _weightGoal = "N/A";
            _isLoadingWeightGoal = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading weight goal: $e');
      if (mounted) {
        setState(() {
          _weightGoal = "Error";
          _isLoadingWeightGoal = false;
        });
      }
    }
  }

  List<CalorieData> _getDefaultCalorieData() {
    return selectedPeriod == '1 Month'
        ? [
            CalorieData('Week 1', 0, 0, 0),
            CalorieData('Week 2', 0, 0, 0),
            CalorieData('Week 3', 0, 0, 0),
            CalorieData('Week 4', 0, 0, 0),
          ]
        : [
            // Mengubah urutan hari menjadi Senin-Minggu
            CalorieData('Mon', 0, 0, 0),
            CalorieData('Tue', 0, 0, 0),
            CalorieData('Wed', 0, 0, 0),
            CalorieData('Thu', 0, 0, 0),
            CalorieData('Fri', 0, 0, 0),
            CalorieData('Sat', 0, 0, 0),
            CalorieData('Sun', 0, 0, 0),
          ];
  }

  // Add this method to handle refresh all data
  Future<void> _refreshAllData() async {
    // Load all data concurrently for faster refresh
    await Future.wait([
      // Proper syntax with list brackets
      _loadCalorieData(),
      _loadCurrentWeight(),
      _loadCurrentBMI(),
      _loadWeightGoal(),
      _loadWeightProgressData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshAllData,
      color: primaryPink,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentWeightIndicators(),
              const SizedBox(height: 24),
              BMISection(
                primaryBlue: primaryBlue,
                primaryGreen: primaryGreen,
                primaryYellow: primaryYellow,
                primaryPink: primaryPink,
                bmiValue: _currentBMI,
                isLoading: _isLoadingBMI,
              ),
              const SizedBox(height: 24),
              PeriodSelectionTabs(
                selectedPeriod: selectedPeriod,
                onPeriodSelected: (period) {
                  setState(() {
                    selectedPeriod = period;
                  });
                },
                primaryColor: primaryPink,
              ),
              const SizedBox(height: 24),
              _isLoadingWeightData
                  ? const Center(child: CircularProgressIndicator())
                  : GoalProgressChart(
                      displayData:
                          selectedPeriod == '1 Month' ? _monthData : _weekData,
                      primaryGreen: primaryGreen,
                      currentWeight: double.tryParse(_currentWeight) ??
                          0.0, // Tambahkan parameter ini
                      initialWeight: _initialWeight, // Add initialWeight
                      goalWeight: _goalWeight, // Add goalWeight
                    ),
              const SizedBox(height: 24),
              WeekSelectionTabs(
                selectedWeek: selectedWeek,
                onWeekSelected: (week) {
                  setState(() {
                    selectedWeek = week;
                  });
                  _loadCalorieData();
                },
                primaryColor: primaryPink,
              ),
              const SizedBox(height: 16),
              CaloriesChart(
                calorieData: _calorieData,
                totalCalories: _totalCalories,
                isLoading: _isLoadingCalorieData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeightIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Tambahkan tipe explicit untuk children
        Expanded(
          child: CircularIndicatorWidget(
            label: "Weight Goal",
            value: _isLoadingWeightGoal ? "Loading..." : "$_weightGoal kg",
            icon: Icons.flag_outlined,
            color: primaryGreen,
            onTap: _isLoadingWeightGoal
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateGoalPage(initialGoalWeight: _weightGoal),
                      ),
                    );

                    // Jika berhasil update, refresh data
                    if (result != null) {
                      setState(() {
                        _weightGoal = result;
                        _isLoadingWeightGoal = false;
                      });
                    }
                  },
          ),
        ),
        // Gunakan SizedBox dengan kedua properti width dan height
        const SizedBox(width: 16, height: null),
        Expanded(
          child: CircularIndicatorWidget(
            label: "Current Weight",
            value: _isLoadingWeight ? "Loading..." : "$_currentWeight kg",
            icon: Icons.scale,
            color: primaryPink,
            onTap: _isLoadingWeight
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateWeightPage(
                            initialCurrentWeight: _currentWeight),
                      ),
                    );

                    // Refresh data if successfully updated
                    if (result != null) {
                      setState(() {
                        _currentWeight = result;
                        _isLoadingWeight = false;
                      });

                      // Reload all data that depends on weight
                      await _loadCurrentBMI();

                      // PERBAIKAN: Reload chart data juga
                      await _loadWeightProgressData();
                    }
                  },
          ),
        ),
      ],
    );
  }
}
// coverage:ignore-end
