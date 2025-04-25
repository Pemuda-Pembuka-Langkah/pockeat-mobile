// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:camera/camera.dart';

// Project imports:
import 'package:pockeat/features/food_scan_ai/presentation/screens/nutrition_page.dart';
import 'package:pockeat/features/food_scan_ai/presentation/widgets/food_photo_help_widget.dart';

class ScanFoodPage extends StatefulWidget {
  final CameraController cameraController;

  const ScanFoodPage({
    super.key,
    required this.cameraController,
  });

  @override
  ScanFoodPageState createState() => ScanFoodPageState();
}

@visibleForTesting
class ScanFoodPageState extends State<ScanFoodPage>
    with SingleTickerProviderStateMixin {
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  final Color primaryGreen = const Color(0xFF4ECDC4);
  // Base colors  // Main green

// Progress colors - lebih vivid untuk progress
  final Color warningYellow =
      const Color(0xFFFFB946); // More orange-ish yellow for progress
  final Color alertRed =
      const Color(0xFFFF4949); // Brighter red for initial stage
  final Color successGreen =
      const Color(0xFF4CD964); // More vivid green for success

  final double _scanProgress = 0.0;
  late AnimationController _scanLineController;
  String _statusMessage = 'Make sure your food is clearly visible';
  final Color _progressColor = const Color(0xFFFF4949); // Using primaryPink
  int _currentMode = 0; // 0 for food scan, 1 for label scan

  bool _isCameraReady = false;

  double get scanProgress => _scanProgress;
  String get statusMessage => _statusMessage;
  int get currentMode => _currentMode;
  bool get isCameraReady => _isCameraReady;
  Color get progressColor => _progressColor;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await widget.cameraController.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          widget.cameraController.setFlashMode(FlashMode.off);
        });
      }
    } catch (e) {
      // Handle camera initialization error
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FoodPhotoHelpWidget(primaryColor: primaryGreen);
      },
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    widget.cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: _isCameraReady
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: widget.cameraController.value.previewSize!.height,
                      height: widget.cameraController.value.previewSize!.width,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio:
                              1 / widget.cameraController.value.aspectRatio,
                          child: CameraPreview(widget.cameraController),
                        ),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // Scanning Animation
          Center(
            child: AnimatedBuilder(
              animation: _scanLineController,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0, sin(_scanLineController.value * 2 * pi) * 120),
                  child: Container(
                    width: 280,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          primaryGreen.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Scanner Frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  // Top Left Corner
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: primaryGreen, width: 3),
                          top: BorderSide(color: primaryGreen, width: 3),
                        ),
                      ),
                    ),
                  ),

                  // Top Right Corner
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: primaryGreen, width: 3),
                          top: BorderSide(color: primaryGreen, width: 3),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Left Corner
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: primaryGreen, width: 3),
                          bottom: BorderSide(color: primaryGreen, width: 3),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Right Corner
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: primaryGreen, width: 3),
                          bottom: BorderSide(color: primaryGreen, width: 3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Bar with Modes
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircularButton(
                        CupertinoIcons.xmark,
                        onTap: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          _buildModeButton('Food', 0),
                          const SizedBox(width: 8),
                          _buildModeButton('Label', 1),
                        ],
                      ),
                      Row(
                        children: [
                          // Help Button
                          _buildCircularButton(
                            Icons.help_outline,
                            key: 'help_button',
                            onTap: _showHelpDialog,
                          ),
                          const SizedBox(width: 8),
                          // Flash Button
                          _buildCircularButton(
                            widget.cameraController.value.flashMode ==
                                    FlashMode.off
                                ? Icons.flash_off
                                : Icons.flash_on,
                            onTap: () {
                              setState(() {
                                if (widget.cameraController.value.flashMode ==
                                    FlashMode.off) {
                                  widget.cameraController
                                      .setFlashMode(FlashMode.torch);
                                } else {
                                  widget.cameraController
                                      .setFlashMode(FlashMode.off);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Message
                  Text(
                    _currentMode == 0
                        ? 'Make sure your food is clearly visible'
                        : 'Position the nutrition label in the frame',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Camera Button
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: InkWell(
                      key: const Key('camera_button'),
                      onTap: () async {
                        try {
                          final image =
                              await widget.cameraController.takePicture();
                          if (mounted) {
                            if (_currentMode == 1) {
                              // Jika mode label scan, tampilkan popup untuk serving size
                              // ignore: use_build_context_synchronously
                              _showServingSizeDialog(context, image.path);
                            } else {
                              // Jika mode food scan, langsung navigasi ke NutritionPage
                              // ignore: use_build_context_synchronously
                              _navigateToNutritionPage(context, image.path);
                            }
                          }
                        } catch (e) {
                          // Handle picture taking error
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(
                          _currentMode == 0
                              ? Icons.camera_alt
                              : Icons.document_scanner,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String text, int mode) {
    bool isSelected = _currentMode == mode;
    return GestureDetector(
      key: Key('mode_button_$mode'),
      onTap: () {
        setState(() {
          _currentMode = mode;
          // Update status message based on mode
          _statusMessage = mode == 0
              ? 'Make sure your food is clearly visible'
              : 'Position the nutrition label in the frame';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon,
      {VoidCallback? onTap, String? key}) {
    return GestureDetector(
      key: key != null ? Key(key) : Key('circular_button_$icon'),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog serving size yang sederhana
  void _showServingSizeDialog(BuildContext context, String imagePath) {
    double servingSize = 1.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Serving Size',
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Berapa serving size yang Anda makan?',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Form input number sederhana
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryGreen),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '1.0',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          try {
                            final parsedValue = double.parse(value);
                            if (parsedValue > 0) {
                              servingSize = parsedValue;
                            } else {
                              // Tampilkan pesan jika angka tidak positif
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mohon masukkan angka positif'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              servingSize = 1.0;
                            }
                          } catch (e) {
                            // Tampilkan pesan jika input bukan angka
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Mohon masukkan angka yang valid'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            servingSize = 1.0;
                          }
                        }
                      },
                      controller:
                          TextEditingController(text: servingSize.toString()),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Pastikan Anda memasukkan angka yang benar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(color: primaryPink),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Konfirmasi'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToNutritionPage(
                  context,
                  imagePath,
                  servingSize: servingSize,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk navigasi ke NutritionPage
  void _navigateToNutritionPage(BuildContext context, String imagePath,
      {double servingSize = 1.0}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NutritionPage(
          imagePath: imagePath,
          isLabelScan: _currentMode == 1,
          servingSize: servingSize,
        ),
      ),
    );
  }
}
