// Flutter imports:
//coverage: ignore-file

import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pockeat/features/food_log_history/domain/models/food_log_history_item.dart';
import 'package:pockeat/features/food_log_history/presentation/widgets/food_history_card.dart';
import 'package:pockeat/features/food_log_history/services/food_log_history_service.dart';

//coverage: ignore-file

/// A page that displays the user's food history with filtering options.
///
/// This page allows users to view their food history and filter it by
/// date, month, or year. It uses the FoodHistoryCard widget to display
/// individual food items.
class FoodHistoryPage extends StatefulWidget {
  final FoodLogHistoryService service;
  final FirebaseAuth? auth;

  const FoodHistoryPage({
    super.key,
    required this.service,
    this.auth,
  });

  @override
  State<FoodHistoryPage> createState() => _FoodHistoryPageState();
}

class _FoodHistoryPageState extends State<FoodHistoryPage> {
  late Future<List<FoodLogHistoryItem>> _foodsFuture;

  // Filter state
  FilterType _activeFilterType = FilterType.all;
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<FoodLogHistoryItem>? _allFoods;
  List<FoodLogHistoryItem>? _filteredFoods;
  bool _isSearching = false;

  // Colors
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color bgColor = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //
  // Data loading and filtering methods
  //

  void _loadFoods() {
    // Get current user's ID
    final userId =
        (widget.auth ?? FirebaseAuth.instance).currentUser?.uid ?? '';

    setState(() {
      _foodsFuture = _fetchFoods(userId);
      _resetSearch();
    });
  }

  Future<List<FoodLogHistoryItem>> _fetchFoods(String userId) async {
    try {
      List<FoodLogHistoryItem> foods;

      switch (_activeFilterType) {
        case FilterType.date:
          foods = await widget.service.getFoodLogsByDate(userId, _selectedDate);
          break;
        case FilterType.month:
          foods = await widget.service
              .getFoodLogsByMonth(userId, _selectedMonth, _selectedYear);
          break;
        case FilterType.year:
          foods = await widget.service.getFoodLogsByYear(userId, _selectedYear);
          break;
        case FilterType.all:
          foods = await widget.service.getAllFoodLogs(userId);
          break;
      }

      setState(() {
        _allFoods = foods;
      });

      return foods;
    } catch (e) {
      throw Exception('Failed to load foods: $e');
    }
  }

  void _resetSearch() {
    _searchQuery = '';
    _searchController.clear();
    _allFoods = null;
    _filteredFoods = null;
    _isSearching = false;
  }

  void _navigateToFoodDetail(FoodLogHistoryItem food) async {
    final result = await Navigator.of(context).pushNamed(
      '/food-detail',
      arguments: {
        'foodId': food.sourceId ?? food.id,
      },
    );

    // Refresh data jika detail page mengembalikan true (food telah dihapus)
    if (result == true) {
      _loadFoods();
    }
  }

  //
  // Search-related methods
  //

  /// Filters foods based on the given search query
  ///
  /// This method filters the foods by title and subtitle and
  /// updates the filtered list state.
  void _filterFoods(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();

      if (_allFoods == null || _searchQuery.isEmpty) {
        _filteredFoods = _allFoods;
        return;
      }

      _filteredFoods = _allFoods!.where((food) {
        return food.title.toLowerCase().contains(_searchQuery) ||
            food.subtitle.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  /// Clears the current search
  void _clearSearch() {
    _searchController.clear();
    _filterFoods('');
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = false;
    });
  }

  /// Handles focus change when user taps on search field
  void _handleSearchFocus(bool isFocused) {
    setState(() {
      _isSearching = isFocused;
    });
  }

  /// Builds empty state for search with no results
  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No foods found for "$_searchQuery"',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  //
  // UI filter-related methods
  //

  Widget _buildFilterChip(
      String label, FilterType filterType, VoidCallback onSelected) {
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
            _buildFilterChip('All', FilterType.all, () {
              setState(() {
                _activeFilterType = FilterType.all;
                _loadFoods();
              });
            }),
            const SizedBox(width: 8),
            _buildFilterChip(
                _activeFilterType == FilterType.date
                    ? DateFormat('dd MMM yyyy').format(_selectedDate)
                    : 'By Date',
                FilterType.date,
                () => _selectDate(context)),
            const SizedBox(width: 8),
            _buildFilterChip(
                _activeFilterType == FilterType.month
                    ? DateFormat('MMMM yyyy')
                        .format(DateTime(_selectedYear, _selectedMonth))
                    : 'By Month',
                FilterType.month,
                () => _selectMonth(context)),
            const SizedBox(width: 8),
            _buildFilterChip(
                _activeFilterType == FilterType.year
                    ? _selectedYear.toString()
                    : 'By Year',
                FilterType.year,
                () => _selectYear(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryPink,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _activeFilterType = FilterType.date;
        _loadFoods();
      });
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryPink,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedMonth = pickedDate.month;
        _selectedYear = pickedDate.year;
        _activeFilterType = FilterType.month;
        _loadFoods();
      });
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              selectedDate: DateTime(_selectedYear),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime);
              },
            ),
          ),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedYear = pickedDate.year;
        _activeFilterType = FilterType.year;
        _loadFoods();
      });
    }
  }

  /// Builds the search bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterFoods,
        onTap: () => _handleSearchFocus(true),
        decoration: InputDecoration(
          hintText: 'Search foods...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  /// Builds the empty state for no food logs
  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_activeFilterType) {
      case FilterType.date:
        message =
            'No food logs for ${DateFormat('MMM d, y').format(_selectedDate)}';
        icon = Icons.calendar_today;
        break;
      case FilterType.month:
        message =
            'No food logs for ${DateFormat('MMMM y').format(DateTime(_selectedYear, _selectedMonth))}';
        icon = Icons.calendar_month;
        break;
      case FilterType.year:
        message = 'No food logs for $_selectedYear';
        icon = Icons.calendar_today;
        break;
      case FilterType.all:
        message = 'No food logs found';
        icon = Icons.fastfood;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  //
  // UI filter-related methods
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Filter chips
          _buildFilterChips(),

          // Food list
          Expanded(
            child: _isSearching && _filteredFoods != null
                ? _filteredFoods!.isEmpty
                    ? _buildEmptySearchState()
                    : _buildFoodList(_filteredFoods!)
                : FutureBuilder<List<FoodLogHistoryItem>>(
                    future: _foodsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: primaryPink,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading foods',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadFoods,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildFoodList(snapshot.data!);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodLogHistoryItem> foods) {
    return ListView.builder(
      itemCount: foods.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final food = foods[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FoodHistoryCard(
            food: food,
            onTap: () => _navigateToFoodDetail(food),
          ),
        );
      },
    );
  }
}

enum FilterType {
  all,
  date,
  month,
  year,
}
