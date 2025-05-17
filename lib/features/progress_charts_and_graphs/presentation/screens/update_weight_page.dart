// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// coverage:ignore-start
class UpdateWeightPage extends StatefulWidget {
  final String initialCurrentWeight;

  const UpdateWeightPage({
    super.key,
    required this.initialCurrentWeight,
  });

  @override
  State<UpdateWeightPage> createState() => _UpdateWeightPageState();
}

class _UpdateWeightPageState extends State<UpdateWeightPage> {
  final Color primaryPink = const Color(0xFFFF6B6B);

  late double _currentWeight;
  bool _isSaving = false;

  final double _minWeight = 30.0;
  final double _maxWeight = 200.0;

  // Range yang terlihat di layar (±1.5 kg)
  final double _visibleRange = 3.0;

  // Offset slider
  double _sliderOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _currentWeight =
        double.tryParse(widget.initialCurrentWeight.replaceAll('N/A', '60')) ??
            60.0;

    _currentWeight = _currentWeight.clamp(_minWeight, _maxWeight);
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Query untuk mendapatkan dokumen health metrics user
      final snapshot = await FirebaseFirestore.instance
          .collection('health_metrics')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Get existing data to retrieve height for BMI calculation
        final existingData = snapshot.docs.first.data();
        final double height = existingData['height']?.toDouble() ?? 170.0;

        // Calculate BMI
        final double bmi =
            _calculateBMI(height: height, weight: _currentWeight);

        // Update dokumen yang sudah ada
        await snapshot.docs.first.reference.update({
          'weight': _currentWeight,
          'bmi': bmi, // Add BMI update
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Buat dokumen baru jika belum ada
        // Using default height since we don't have one yet
        const double defaultHeight = 170.0;
        final double bmi =
            _calculateBMI(height: defaultHeight, weight: _currentWeight);

        await FirebaseFirestore.instance.collection('health_metrics').add({
          'userId': user.uid,
          'weight': _currentWeight,
          'bmi': bmi, // Add BMI field
          'height': defaultHeight, // Add default height
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      Navigator.pop(context, _currentWeight.toString());
    } catch (e) {
      // Add mounted check before using BuildContext after await
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update current weight')),
        );
      }
      debugPrint('Error saving current weight: $e');
    } finally {
      // Add mounted check before using setState after await
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // BMI calculation function
  double _calculateBMI({required double height, required double weight}) {
    // height dalam cm → ubah ke meter
    final heightInMeter = height / 100;
    return weight / (heightInMeter * heightInMeter);
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
      double newWeight = _currentWeight + weightChange;

      newWeight = (newWeight * 10).round() / 10;

      // Update nilai jika dalam range valid
      if (newWeight >= _minWeight &&
          newWeight <= _maxWeight &&
          newWeight != _currentWeight) {
        _currentWeight = newWeight;
        _sliderOffset = 0.0; // Reset offset setelah update nilai
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Current Weight',
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
      body: Padding(
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
                  color: primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.scale,
                  color: primaryPink,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Weight goal label
            const Text(
              'Current Weight',
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
                  _currentWeight.toStringAsFixed(1),
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
              final double pixelsPerKg = constraints.maxWidth / _visibleRange;

              final double visibleMin = (_currentWeight - _visibleRange / 2)
                  .clamp(_minWeight, _maxWeight);
              final double visibleMax = (_currentWeight + _visibleRange / 2)
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

            // Save button
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
    final double pixelsPerKg = size.width / totalWeightRange;

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
