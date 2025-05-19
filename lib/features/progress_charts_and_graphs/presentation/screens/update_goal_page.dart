// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// coverage:ignore-start
class UpdateGoalPage extends StatefulWidget {
  final String initialGoalWeight;

  const UpdateGoalPage({
    super.key,
    required this.initialGoalWeight,
  });

  @override
  State<UpdateGoalPage> createState() => _UpdateGoalPageState();
}

class _UpdateGoalPageState extends State<UpdateGoalPage> {
  final Color primaryGreen = const Color(0xFF4ECDC4);

  late double _goalWeight;
  bool _isSaving = false;
  bool _isLoading = true; // Add loading state for initial data fetch

  final double _minWeight = 30.0;
  final double _maxWeight = 150.0;

  // Range yang terlihat di layar (±1.5 kg)
  final double _visibleRange = 3.0;

  // Offset slider
  double _sliderOffset = 0.0;

  // Add fitness goal and current weight variables
  String? _fitnessGoal;
  double? _currentWeight;

  @override
  void initState() {
    super.initState();
    _goalWeight =
        double.tryParse(widget.initialGoalWeight.replaceAll('N/A', '60')) ??
            60.0;

    _goalWeight = _goalWeight.clamp(_minWeight, _maxWeight);

    // Fetch fitness goal and current weight when page loads
    _fetchUserData();
  }

  // Add method to fetch user's fitness goal and current weight
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Query to get the health metrics document
      final snapshot = await FirebaseFirestore.instance
          .collection('health_metrics')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        // Get fitness goal
        _fitnessGoal = data['fitnessGoal'] as String?;

        // Get current weight
        final dynamic weightValue = data['weight'];
        _currentWeight = weightValue is int
            ? weightValue.toDouble()
            : weightValue is double
                ? weightValue
                : null;

        debugPrint(
            'Fetched user data: fitnessGoal=$_fitnessGoal, currentWeight=$_currentWeight');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method to check if the selected goal weight is valid based on fitness goal
  bool _isGoalWeightValid() {
    if (_currentWeight == null || _fitnessGoal == null) {
      return true; // If we don't have all data, allow saving
    }

    // For "Lose Weight" goals, goal weight must be less than current weight
    if (_fitnessGoal!.contains("Lose Weight") &&
        _goalWeight >= _currentWeight!) {
      return false;
    }

    // For "Gain Weight" goals, goal weight must be more than current weight
    if (_fitnessGoal!.contains("Gain Weight") &&
        _goalWeight <= _currentWeight!) {
      return false;
    }

    return true;
  }

  // Get reminder text based on fitness goal
  String? _getReminderText() {
    if (_currentWeight == null || _fitnessGoal == null) {
      return null;
    }

    if (_fitnessGoal!.contains("Lose Weight") &&
        _goalWeight >= _currentWeight!) {
      return "Your goal is to lose weight. Please set a target weight below your current weight of ${_currentWeight!.toStringAsFixed(1)} kg.";
    }

    if (_fitnessGoal!.contains("Gain Weight") &&
        _goalWeight <= _currentWeight!) {
      return "Your goal is to gain weight. Please set a target weight above your current weight of ${_currentWeight!.toStringAsFixed(1)} kg.";
    }

    return null;
  }

  Future<void> _saveChanges() async {
    if (!_isGoalWeightValid()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      debugPrint('Attempting to save weight goal: $_goalWeight kg');

      // Query untuk mendapatkan dokumen health metrics user
      final snapshot = await FirebaseFirestore.instance
          .collection('health_metrics')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Update dokumen yang sudah ada
        await snapshot.docs.first.reference.update({
          'desiredWeight': _goalWeight,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Buat dokumen baru jika belum ada
        await FirebaseFirestore.instance.collection('health_metrics').add({
          'userId': user.uid,
          'desiredWeight': _goalWeight,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Add mounted check before using BuildContext after await
      if (mounted) {
        Navigator.pop(context, _goalWeight.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goals updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Add mounted check before using BuildContext after await
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update weight goal: $e')),
        );
      }
      debugPrint('Error saving weight goal: $e');
    } finally {
      // Add mounted check before using setState after await
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _sliderOffset = 0.0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double pixelsPerKg) {
    setState(() {
      _sliderOffset += details.delta.dx;

      double weightChange = -_sliderOffset / pixelsPerKg;

      // Hitung berat baru
      double newWeight = _goalWeight + weightChange;

      newWeight = (newWeight * 10).round() / 10;

      // Update nilai jika dalam range valid
      if (newWeight >= _minWeight &&
          newWeight <= _maxWeight &&
          newWeight != _goalWeight) {
        _goalWeight = newWeight;
        _sliderOffset = 0.0; // Reset offset setelah update nilai
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if goal weight is valid based on fitness goal
    final bool isGoalValid = _isGoalWeightValid();
    final String? reminderText = _getReminderText();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Weight Goal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.flag_outlined,
                        color: primaryGreen,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Weight goal label
                  const Text(
                    'Weight Goal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Weight display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _goalWeight.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  LayoutBuilder(builder: (context, constraints) {
                    final double pixelsPerKg =
                        constraints.maxWidth / _visibleRange;

                    final double visibleMin = (_goalWeight - _visibleRange / 2)
                        .clamp(_minWeight, _maxWeight);
                    final double visibleMax = (_goalWeight + _visibleRange / 2)
                        .clamp(_minWeight, _maxWeight);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Area slider dengan gestur detection
                        SizedBox(
                          height: 100,
                          width: constraints.maxWidth,
                          child: GestureDetector(
                            onHorizontalDragStart: _handleDragStart,
                            onHorizontalDragUpdate: (details) =>
                                _handleDragUpdate(details, pixelsPerKg),
                            child: CustomPaint(
                              painter: WeightSliderPainter(
                                minWeight: visibleMin,
                                maxWeight: visibleMax,
                                offset: _sliderOffset,
                              ),
                              size: Size(constraints.maxWidth, 60),
                            ),
                          ),
                        ),

                        // Garis indikator berat
                        Container(
                          height: 60,
                          width: 2,
                          color: Colors.black,
                        ),
                      ],
                    );
                  }),

                  const Spacer(),

                  // Show reminder text if needed
                  if (reminderText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reminderText,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Save button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            (_isSaving || !isGoalValid) ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isGoalValid ? primaryGreen : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save changes',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Custom painter untuk garis-garis indikator berat
class WeightSliderPainter extends CustomPainter {
  final double minWeight;
  final double maxWeight;
  final double offset; // Untuk animasi pergerakan

  WeightSliderPainter({
    required this.minWeight,
    required this.maxWeight,
    this.offset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintShort = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final paintMedium = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5;

    final paintLong = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2.0;

    // Tentukan interval berat
    final double totalWeightRange = maxWeight - minWeight;

    // Jumlah garis indikator (10 garis per kg)
    final int totalMarks = (totalWeightRange * 10).toInt();
    final double markSpacing = size.width / totalMarks;

    // Apply offset untuk animasi drag
    canvas.save();
    canvas.translate(offset, 0);

    // Gambar garis-garis indikator
    for (int i = -5; i <= totalMarks + 5; i++) {
      final double x = i * markSpacing;
      final double currentWeight = minWeight + (i / 10);

      // Skip jika di luar rentang yang terlihat
      if (x < -10 || x > size.width + 10) continue;

      Paint linePaint;
      double lineHeight;

      // Kelipatan 1kg - garis paling tinggi
      if (currentWeight.round() == currentWeight) {
        linePaint = paintLong;
        lineHeight = 40;
      }
      // Kelipatan 0.5kg - garis tinggi
      else if ((currentWeight * 2).round() == currentWeight * 2) {
        linePaint = paintMedium;
        lineHeight = 25;
      }
      // Kelipatan 0.1kg - garis pendek
      else {
        linePaint = paintShort;
        lineHeight = 15;
      }

      canvas.drawLine(
        Offset(x, size.height - lineHeight),
        Offset(x, size.height),
        linePaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WeightSliderPainter oldDelegate) {
    return oldDelegate.minWeight != minWeight ||
        oldDelegate.maxWeight != maxWeight ||
        oldDelegate.offset != offset;
  }
}
// coverage:ignore-end
