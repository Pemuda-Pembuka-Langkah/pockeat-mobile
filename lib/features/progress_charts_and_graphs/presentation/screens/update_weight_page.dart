// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:pockeat/features/weight_history/services/weight_service.dart';

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
  final WeightService _weightService = WeightService();

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

      debugPrint('Attempting to save weight: $_currentWeight kg');

      // Gunakan WeightService untuk update berat badan
      await _weightService.updateTodayWeight(user.uid, _currentWeight);

      // Verifikasi data tersimpan dengan mengambil data terbaru
      final latestWeight = await _weightService.getLatestWeight(user.uid);
      debugPrint('Verified latest weight after save: $latestWeight kg');

      // Add mounted check before using BuildContext after await
      if (mounted) {
        Navigator.pop(context, _currentWeight.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Add mounted check before using BuildContext after await
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update weight: $e')),
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
