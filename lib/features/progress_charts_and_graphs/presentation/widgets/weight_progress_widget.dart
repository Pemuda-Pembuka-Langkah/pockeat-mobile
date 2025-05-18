// Dart imports:
import 'dart:math';

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

      // Get user creation date to know start date for weight tracking
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

      // Format user creation date as YYYY-MM-DD for the document ID
      final userCreationDateStr =
          DateFormat('yyyy-MM-dd').format(userCreationDate);
      debugPrint('User creation date: $userCreationDateStr');

      // Current weight value from health metrics (HANYA untuk hari ini)
      final currentWeight = healthMetricsDoc.data()['weight'] as double? ?? 0.0;

      // Tanggal hari ini dalam format yyyy-MM-dd
      final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Load ALL weight history from the weight_history subcollection
      // PENTING: Urutkan berdasarkan date (bukan updatedAt) untuk mendapatkan urutan kronologis yang tepat
      final weightHistoryQuery = await FirebaseFirestore.instance
          .collection('health_metrics')
          .doc(healthMetricsDoc.id)
          .collection('weight_history')
          .orderBy('date')
          .get();

      // BARU: Cek apakah ada riwayat berat badan
      if (weightHistoryQuery.docs.isEmpty) {
        debugPrint(
            'No weight history found, creating initial entry for user creation date');

        // 1. Tambahkan entri pada tanggal pembuatan akun
        await healthMetricsRef
            .collection('weight_history')
            .doc(userCreationDateStr)
            .set({
          'weight': currentWeight,
          'date': userCreationDateStr,
          'createdAt': createdAt ?? FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint(
            'Created initial weight history entry for date: $userCreationDateStr with weight: $currentWeight');

        // 2. Jika tanggal pembuatan akun bukan hari ini, tambahkan entri untuk hari ini juga
        if (userCreationDateStr != todayStr) {
          await healthMetricsRef
              .collection('weight_history')
              .doc(todayStr)
              .set({
            'weight': currentWeight,
            'date': todayStr,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          debugPrint(
              'Created today\'s weight history entry for date: $todayStr with weight: $currentWeight');
        }

        // Verifikasi pembuatan entri-entri di atas
        final updatedWeightHistoryQuery = await healthMetricsRef
            .collection('weight_history')
            .orderBy('date')
            .get();

        if (updatedWeightHistoryQuery.docs.isEmpty) {
          debugPrint(
              'WARNING: Still no weight history found after creating initial entries!');
        } else {
          debugPrint(
              'Successfully created initial weight history, found ${updatedWeightHistoryQuery.docs.length} entries.');
        }
      }

      // ======= PERUBAHAN UTAMA: PEMISAHAN PEMROSESAN DATA HISTORIS =======

      // Langkah 1: Map untuk menyimpan data historis HANYA dari weight_history
      // Kunci: String tanggal yyyy-MM-dd, Nilai: berat pada tanggal tersebut
      final Map<String, double> historicalWeights = {};

      // Isi map dengan semua data dari weight_history
      for (var doc in weightHistoryQuery.docs) {
        final date = doc.data()['date'] as String? ?? '';
        final weight = doc.data()['weight']?.toDouble() ?? 0.0;

        if (date.isNotEmpty) {
          historicalWeights[date] = weight;
          debugPrint('Loaded historical weight for $date: $weight kg');
        }
      }

      // Langkah 2: Periksa apakah ada data untuk hari ini di weight_history
      bool hasTodayEntry = historicalWeights.containsKey(todayStr);

      // Langkah 3: Jika tidak ada entri untuk hari ini, buat entri baru di weight_history
      if (!hasTodayEntry) {
        // Tambahkan entri untuk hari ini dengan nilai dari dokumen utama
        await healthMetricsRef.collection('weight_history').doc(todayStr).set({
          'weight': currentWeight,
          'date': todayStr,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint(
            'Created missing today\'s entry in weight_history with weight: $currentWeight');

        // Update map data historis juga
        historicalWeights[todayStr] = currentWeight;
      } else {
        // Jika ada entri hari ini, periksa apakah perlu diupdate dengan nilai terbaru
        final todayHistoricalWeight = historicalWeights[todayStr]!;
        if (todayHistoricalWeight != currentWeight) {
          // Update entri hari ini dengan nilai terbaru dari dokumen utama
          await healthMetricsRef
              .collection('weight_history')
              .doc(todayStr)
              .update({
            'weight': currentWeight,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          debugPrint(
              'Updated today\'s entry in weight_history from $todayHistoricalWeight to $currentWeight');

          // Update map data historis juga
          historicalWeights[todayStr] = currentWeight;
        }
      }

      // Langkah 4: Buat struktur data untuk chart dengan menghormati prioritas data
      // Generate week data (last 7 days) - dimulai dari Senin
      final weekData = <WeightData>[];
      final now = DateTime.now();

      // Hitung hari pertama dari minggu ini (Senin)
      // Rumus: Kurangi hari saat ini dengan (weekday - 1)
      // Senin = 1, Selasa = 2, ..., Minggu = 7 dalam sistem DateTime.weekday
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
        final dayOfWeek = weekDayLabels[i]; // Indeks 0 = Senin, 1 = Selasa, dst

        double? weightValue;

        // Prioritas 1: Cari data untuk tanggal tersebut di historicalWeights
        if (historicalWeights.containsKey(dateStr)) {
          weightValue = historicalWeights[dateStr];
          debugPrint(
              'Using weight history data for $dateStr ($dayOfWeek): $weightValue kg');
        }
        // Prioritas 2: Jika tidak ada, cari data terdekat sebelumnya
        else {
          // Cari tanggal terbaru sebelum dateStr yang memiliki data
          final sortedDates = historicalWeights.keys.toList()..sort();
          String? latestPriorDate;

          for (var histDate in sortedDates) {
            if (histDate.compareTo(dateStr) < 0 &&
                (latestPriorDate == null ||
                    histDate.compareTo(latestPriorDate) > 0)) {
              latestPriorDate = histDate;
            }
          }

          if (latestPriorDate != null) {
            weightValue = historicalWeights[latestPriorDate];
            debugPrint(
                'Using prior weight from $latestPriorDate: $weightValue kg for $dateStr ($dayOfWeek)');
          } else {
            // Prioritas 3: Jika tidak ada data sebelumnya, gunakan data terdekat setelahnya
            for (var histDate in sortedDates) {
              if (histDate.compareTo(dateStr) > 0) {
                weightValue = historicalWeights[histDate];
                debugPrint(
                    'Using future weight from $histDate: $weightValue kg for $dateStr ($dayOfWeek) (no prior data)');
                break;
              }
            }
          }
        }

        // Jika masih tidak ada data, gunakan nilai default (berat saat ini)
        weightValue ??= currentWeight;

        weekData.add(WeightData(dayOfWeek, weightValue));
      }

      // Generate month data (4 weeks of current month) dengan pendekatan yang sama
      final monthData = <WeightData>[];
      final currentMonth = now.month;
      final currentYear = now.year;

      // Calculate week boundaries for the current month
      final lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);

      final totalDaysInMonth = lastDayOfMonth.day;
      final weeksInMonth = (totalDaysInMonth / 7).ceil();

      for (int weekNum = 0; weekNum < min(weeksInMonth, 4); weekNum++) {
        final weekLabel = 'Week ${weekNum + 1}';

        // Calculate middle day of this week for getting weight
        final startDay = weekNum * 7 + 1;
        final endDay = min((weekNum + 1) * 7, totalDaysInMonth);
        final middleDay = ((startDay + endDay) / 2).floor();

        // Target date for this week's weight
        final targetDate = DateTime(currentYear, currentMonth, middleDay);
        final targetDateStr = DateFormat('yyyy-MM-dd').format(targetDate);

        double? weightValue;

        // Prioritas 1: Cari data untuk tanggal tersebut di historicalWeights
        if (historicalWeights.containsKey(targetDateStr)) {
          weightValue = historicalWeights[targetDateStr];
        }
        // Prioritas 2: Jika tidak ada, cari data terdekat sebelumnya
        else {
          // Cari tanggal terbaru sebelum targetDateStr yang memiliki data
          final sortedDates = historicalWeights.keys.toList()..sort();
          String? latestPriorDate;

          for (var histDate in sortedDates) {
            if (histDate.compareTo(targetDateStr) < 0 &&
                (latestPriorDate == null ||
                    histDate.compareTo(latestPriorDate) > 0)) {
              latestPriorDate = histDate;
            }
          }

          if (latestPriorDate != null) {
            weightValue = historicalWeights[latestPriorDate];
          } else {
            // Jika tidak ada data sebelumnya, cari data terdekat setelahnya
            for (var histDate in sortedDates) {
              if (histDate.compareTo(targetDateStr) > 0) {
                weightValue = historicalWeights[histDate];
                break;
              }
            }
          }
        }

        // Jika masih tidak ada data, gunakan nilai default
        weightValue ??= currentWeight;

        monthData.add(WeightData(weekLabel, weightValue));
      }

      // Debugging info
      debugPrint('Generated ${weekData.length} entries for week data chart');
      debugPrint('Generated ${monthData.length} entries for month data chart');

      if (mounted) {
        setState(() {
          _weekData = weekData;
          _monthData = monthData;
          _isLoadingWeightData = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading weight progress data: $e');
      if (mounted) {
        setState(() {
          // Mengubah array default agar konsisten dengan urutan hari Senin-Minggu
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
      children: [
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
        const SizedBox(width: 16),
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
