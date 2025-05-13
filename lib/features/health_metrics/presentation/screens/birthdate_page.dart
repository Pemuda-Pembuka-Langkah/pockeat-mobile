// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';
import 'form_cubit.dart';

class BirthdatePage extends StatefulWidget {
  const BirthdatePage({super.key});

  @override
  State<BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<BirthdatePage>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  late DateTime _today;
  late DateTime _minDate;
  late DateTime _maxDate;
  late int _currentYear;
  late int _currentMonth;

  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize date variables
    _today = DateTime.now();
    _minDate = DateTime(_today.year - 100);
    _maxDate = DateTime(_today.year - 12, _today.month, _today.day);
    // Ensure _focusedDay is not after _maxDate to avoid the calendar assertion error
    _focusedDay =
        DateTime(_today.year - 18, _today.month, 1); // Default to 18 years ago
    _currentYear = _focusedDay.year;
    _currentMonth = _focusedDay.month;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to update selected date
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Ensure the selected day is valid (between min and max dates)
    if (!selectedDay.isBefore(_minDate) && !selectedDay.isAfter(_maxDate)) {
      setState(() {
        _selectedDate = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  // coverage:ignore-start
  // Function to show year/month picker dialog
  void _showYearMonthPicker() {
    final years = List.generate(
      _maxDate.year - _minDate.year + 1,
      (index) => _minDate.year + index,
    ).reversed.toList();

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    int selectedYear = _currentYear;
    int selectedMonth = _currentMonth;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year and Month',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Year', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    final isSelected = year == selectedYear;
                    return ListTile(
                      dense: true,
                      title: Text(
                        year.toString(),
                        style: TextStyle(
                          color: isSelected ? primaryGreen : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        selectedYear = year;
                        (context as Element).markNeedsBuild();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('Month',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final monthNumber = index + 1;
                    final isSelected = monthNumber == selectedMonth;
                    return ListTile(
                      dense: true,
                      title: Text(
                        month,
                        style: TextStyle(
                          color: isSelected ? primaryGreen : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        selectedMonth = monthNumber;
                        (context as Element).markNeedsBuild();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Determine the new focused day
              DateTime newFocusedDay = DateTime(selectedYear, selectedMonth, 1);

              // Update state
              setState(() {
                _currentYear = selectedYear;
                _currentMonth = selectedMonth;
                _focusedDay = newFocusedDay;

                // If selected date exists and is in a different month/year, clear it
                if (_selectedDate != null &&
                    (_selectedDate!.year != selectedYear ||
                        _selectedDate!.month != selectedMonth)) {
                  _selectedDate = null;
                }
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
  // coverage:ignore-end

  // Function to check if a day is enabled
  bool _isDayEnabled(DateTime day) {
    return !day.isBefore(_minDate) && !day.isAfter(_maxDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                bgColor,
              ],
              stops: const [0.0, 0.6],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Onboarding progress indicator
                const OnboardingProgressIndicator(
                  totalSteps: 16,
                  currentStep: 2, // This is the third step (0-indexed)
                  barHeight: 6.0,
                  showPercentage: true,
                ),

                const SizedBox(height: 20),

                // Title with modern style
                const Text(
                  "Your Birthday",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "When were you born?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 32),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_fadeAnimation),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Date selection info
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (_selectedDate != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: primaryGreen.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: primaryGreen
                                                  .withOpacity(0.2)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _formatDate(_selectedDate!),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Age: ${_calculateAge(_selectedDate!)} years",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: primaryGreen
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.check,
                                                color: primaryGreen,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 16),

                                    // Embedded calendar
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // Custom header with tap functionality
                                          GestureDetector(
                                            onTap: _showYearMonthPicker,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: primaryGreen
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${_getMonthName(_focusedDay.month)} ${_focusedDay.year}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    color: primaryGreen,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TableCalendar<DateTime>(
                                            firstDay: _minDate,
                                            lastDay: _maxDate,
                                            focusedDay: _focusedDay,
                                            calendarFormat: _calendarFormat,
                                            selectedDayPredicate: (day) =>
                                                isSameDay(_selectedDate, day),
                                            onDaySelected: _onDaySelected,
                                            onFormatChanged: (format) {
                                              setState(() {
                                                _calendarFormat = format;
                                              });
                                            },
                                            headerVisible:
                                                false, // Hide the default header
                                            onPageChanged: (focusedDay) {
                                              // Ensure the new focusedDay doesn't violate calendar constraints
                                              setState(() {
                                                if (focusedDay
                                                    .isAfter(_maxDate)) {
                                                  _focusedDay = _maxDate;
                                                } else if (focusedDay
                                                    .isBefore(_minDate)) {
                                                  _focusedDay = _minDate;
                                                } else {
                                                  _focusedDay = focusedDay;
                                                }
                                                _currentMonth =
                                                    _focusedDay.month;
                                                _currentYear = _focusedDay.year;
                                              });
                                            },
                                            calendarStyle: CalendarStyle(
                                              defaultTextStyle: const TextStyle(
                                                  color: Colors.black87),
                                              weekendTextStyle: const TextStyle(
                                                  color: Colors.black54),
                                              outsideTextStyle: TextStyle(
                                                  color: Colors.grey.shade400),
                                              disabledTextStyle: TextStyle(
                                                  color: Colors.grey.shade300),
                                              selectedDecoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: primaryGreen,
                                              ),
                                              todayDecoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: primaryGreen
                                                    .withOpacity(0.2),
                                              ),
                                              markersAlignment:
                                                  Alignment.bottomCenter,
                                            ),
                                            headerStyle: const HeaderStyle(
                                              formatButtonVisible: false,
                                              titleCentered: true,
                                              headerPadding: EdgeInsets.all(
                                                  0), // Hide the default header completely
                                            ),
                                            enabledDayPredicate: _isDayEnabled,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Personalization benefits
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color:
                                                  primaryGreen.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.info_outline,
                                                color: primaryGreen, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              "Your age helps us calculate the calories you need for optimal health.",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                  height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Continue button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedDate != null
                                      ? primaryGreen
                                      : primaryGreenDisabled,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: _selectedDate != null ? 2 : 0,
                                ),
                                onPressed: _selectedDate == null
                                    ? null
                                    : () {
                                        context
                                            .read<HealthMetricsFormCubit>()
                                            .setBirthDate(_selectedDate!);
                                        Navigator.pushNamed(context, '/gender');
                                      },
                                child: const Text(
                                  "Add Birthdate",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to format date nicely
  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  // Calculate age from birthdate
  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
