// rollover_calories_page.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class RolloverCaloriesPage extends StatefulWidget {
  const RolloverCaloriesPage({super.key});

  @override
  State<RolloverCaloriesPage> createState() => _RolloverCaloriesPageState();
}

class _RolloverCaloriesPageState extends State<RolloverCaloriesPage> {
  bool? _selectedOption; // true = Yes, false = No

  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
        title: const Text(
          "Rollover Calories",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rollover extra calories to the next day?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Rollover up to 200 cals",
              style: TextStyle(
                fontSize: 16,
                color: primaryPink,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPink.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton(
                        label: 'No',
                        selected: _selectedOption == false,
                        value: false),
                    _buildOptionButton(
                        label: 'Yes',
                        selected: _selectedOption == true,
                        value: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _selectedOption != null ? _handleNextPressed : null,
              child: const Center(child: Text("Continue")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      {required String label, required bool selected, required bool value}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOption = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? primaryPink : Colors.white,
            border: Border.all(
                color: selected ? primaryPink : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNextPressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rolloverCaloriesEnabled', _selectedOption!);
    if (mounted) {
      Navigator.pushNamed(
          context, '/used-other-apps'); // <- Change this to your next page
    }
  }
}
