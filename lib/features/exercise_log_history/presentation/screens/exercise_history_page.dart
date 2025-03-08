import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pockeat/features/exercise_log_history/domain/models/exercise_log_history_item.dart';
import 'package:pockeat/features/exercise_log_history/presentation/widgets/exercise_history_card.dart';
import 'package:pockeat/features/exercise_log_history/services/exercise_log_history_service.dart';

/// A page that displays the user's exercise history with filtering options.
/// 
/// This page allows users to view their exercise history and filter it by
/// date, month, or year. It uses the ExerciseHistoryCard widget to display
/// individual exercise items.
class ExerciseHistoryPage extends StatefulWidget {
  final ExerciseLogHistoryService service;

  const ExerciseHistoryPage({
    super.key,
    required this.service,
  });

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  late Future<List<ExerciseLogHistoryItem>> _exercisesFuture;
  
  // Filter state
  FilterType _activeFilterType = FilterType.all;
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  
  // Colors
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() {
      switch (_activeFilterType) {
        case FilterType.date:
          _exercisesFuture = widget.service.getExerciseLogsByDate(_selectedDate);
          break;
        case FilterType.month:
          _exercisesFuture = widget.service.getExerciseLogsByMonth(_selectedMonth, _selectedYear);
          break;
        case FilterType.year:
          _exercisesFuture = widget.service.getExerciseLogsByYear(_selectedYear);
          break;
        case FilterType.all:
          _exercisesFuture = widget.service.getAllExerciseLogs();
          break;
      }
    });
  }

  void _navigateToExerciseDetail(ExerciseLogHistoryItem exercise) {
    Navigator.of(context).pushNamed(
      '/exercise-detail',
      arguments: {
        'exerciseId': exercise.sourceId ?? exercise.id, // Gunakan sourceId jika ada, atau fallback ke id
        'activityType': exercise.activityType,
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryPink,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _activeFilterType = FilterType.date;
        _loadExercises();
      });
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final currentMonth = DateTime(_selectedYear, _selectedMonth);
    
    // Show a month picker dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _selectedYear--;
                          Navigator.pop(context);
                          _selectMonth(context);
                        });
                      },
                    ),
                    Text(
                      _selectedYear.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        final currentYear = DateTime.now().year;
                        if (_selectedYear < currentYear) {
                          setState(() {
                            _selectedYear++;
                            Navigator.pop(context);
                            _selectMonth(context);
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Month grid
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      // Month index is 1-based
                      final monthIndex = index + 1;
                      final monthName = DateFormat('MMM').format(DateTime(_selectedYear, monthIndex));
                      final isCurrentMonth = monthIndex == _selectedMonth && _selectedYear == currentMonth.year;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMonth = monthIndex;
                            _activeFilterType = FilterType.month;
                            _loadExercises();
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isCurrentMonth ? primaryPink : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentMonth ? primaryPink : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              monthName,
                              style: TextStyle(
                                color: isCurrentMonth ? Colors.white : Colors.black87,
                                fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectYear(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 6, // Show 6 years (current year + 5 previous years)
              itemBuilder: (BuildContext context, int index) {
                final year = DateTime.now().year - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () {
                    setState(() {
                      _selectedYear = year;
                      _activeFilterType = FilterType.year;
                      _loadExercises();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label, 
    FilterType filterType, 
    VoidCallback onSelected
  ) {
    final bool isSelected = _activeFilterType == filterType;
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryPink : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'All', 
              FilterType.all, 
              () {
                setState(() {
                  _activeFilterType = FilterType.all;
                  _loadExercises();
                });
              }
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              _activeFilterType == FilterType.date 
                ? DateFormat('dd MMM yyyy').format(_selectedDate)
                : 'By Date', 
              FilterType.date, 
              () => _selectDate(context)
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              _activeFilterType == FilterType.month 
                ? DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth))
                : 'By Month', 
              FilterType.month, 
              () => _selectMonth(context)
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              _activeFilterType == FilterType.year 
                ? _selectedYear.toString()
                : 'By Year', 
              FilterType.year, 
              () => _selectYear(context)
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Exercise History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<ExerciseLogHistoryItem>>(
              future: _exercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 72,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getEmptyStateMessage(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  final exercises = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return ExerciseHistoryCard(
                        exercise: exercises[index],
                        onTap: () => _navigateToExerciseDetail(exercises[index]),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_activeFilterType) {
      case FilterType.date:
        return 'No exercises found for ${DateFormat('dd MMM yyyy').format(_selectedDate)}';
      case FilterType.month:
        return 'No exercises found for ${DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth))}';
      case FilterType.year:
        return 'No exercises found for $_selectedYear';
      case FilterType.all:
        return 'No exercise history found\nStart your fitness journey today!';
    }
  }
}

enum FilterType {
  all,
  date,
  month,
  year,
}
