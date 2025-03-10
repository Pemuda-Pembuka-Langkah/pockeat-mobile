import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/features/food_scan_ai/presentation/pages/nutrition_page.dart';
import 'package:camera/camera.dart';

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
  final Color alertRed = const Color(0xFFFF4949); // Brighter red for initial stage
  final Color successGreen = const Color(0xFF4CD964); // More vivid green for success

  final double _scanProgress = 0.0;
  late AnimationController _scanLineController;
  final String _statusMessage = 'Make sure your food is clearly visible';
  final Color _progressColor = const Color(0xFFFF4949); // Using primaryPink
  int _currentMode = 0;
  // ignore: unused_field
  final bool _isFoodPositioned = false;

  bool _isCameraReady = false;

  double get scanProgress => _scanProgress;
  String get statusMessage => _statusMessage;
  int get currentMode => _currentMode;
  bool get isCameraReady => _isCameraReady;
  bool get isFoodPositioned => _isFoodPositioned;
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
        });
      }
    } catch (e) {
      // Handle camera initialization error
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(
            child: _isCameraReady 
              ? CameraPreview(widget.cameraController)
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircularButton(
                        CupertinoIcons.xmark,
                        onTap: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          _buildModeButton('Scan', 0),
                          const SizedBox(width: 16),
                          _buildModeButton('Tag Food', 1),
                          const SizedBox(width: 16),
                          _buildModeButton('Help', 2),
                        ],
                      ),
                      _buildCircularButton(Icons.flash_on),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _scanProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_progressColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Message
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _statusMessage,
                      key: ValueKey<String>(_statusMessage),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Camera Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircularButton(CupertinoIcons.photo),
                      _buildCameraButton(),
                      _buildCircularButton(CupertinoIcons.barcode),
                    ],
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
        setState(() => _currentMode = mode);
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      key: Key('circular_button_$icon'),
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

  Widget _buildCameraButton() {
    return InkWell(
      key: const Key('camera_button'),
      onTap: () async {
        try {
          final image = await widget.cameraController.takePicture();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NutritionPage(imagePath: image.path),
              ),
            );
          }
        } catch (e) {
          // Handle picture taking error
        }
      },
      customBorder: const CircleBorder(),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: primaryGreen,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
      ),
    );
  }
}