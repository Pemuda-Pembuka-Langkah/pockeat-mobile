import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pockeat/nutrition_page.dart';

class ScanFoodPage extends StatefulWidget {
  const ScanFoodPage({super.key});

  @override
  _ScanFoodPageState createState() => _ScanFoodPageState();
}

class _ScanFoodPageState extends State<ScanFoodPage>
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

  double _scanProgress = 0.0;
  late AnimationController _scanLineController;
  String _statusMessage = 'Move camera closer to the food';
  Color _progressColor = const Color(0xFFFF4949); // Using primaryPink
  int _currentMode = 0;
  // ignore: unused_field
  bool _isFoodPositioned = false;
  double _imageScale = 1.2;
  double _imageX = 50.0;
  double _imageY = 50.0;
  double _imageRotation = -0.1;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _startScanningProcess();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  void _startScanningProcess() async {
    // Stage 1 - Initial
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _statusMessage = 'Move camera back slightly';
      _scanProgress = 0.2;
      _progressColor = alertRed;
      _imageScale = 1.5;
      _imageX = 50;
      _imageY = 50;
      _imageRotation = 0;
    });

    // Stage 2 - Adjusting
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _statusMessage = 'Move slightly to the left';
      _scanProgress = 0.4;
      _progressColor = alertRed;
      _imageScale = 1.3;
      _imageX = 40;
      _imageY = 30;
      _imageRotation = 0;
    });

    // Stage 3 - Almost
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _statusMessage = 'Rotate camera to align with plate';
      _scanProgress = 0.6;
      _progressColor = warningYellow;
      _imageScale = 1.2;
      _imageX = 20;
      _imageY = 20;
      _imageRotation = 0.1;
    });

    // Stage 4 - Getting Close
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _statusMessage = 'Almost there, hold steady...';
      _scanProgress = 0.8;
      _progressColor = warningYellow;
      _imageScale = 1.1;
      _imageX = 10;
      _imageY = 10;
      _imageRotation = 0.05;
    });

    // Stage 5 - Perfect
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _scanProgress = 1.0;
      _progressColor = successGreen;
      _statusMessage = 'Perfect! Tap to analyze';
      _isFoodPositioned = true;
      _imageScale = 1.0;
      _imageX = 0;
      _imageY = 0;
      _imageRotation = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image with animation
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Transform.scale(
                scale: _imageScale,
                child: Transform.translate(
                  offset: Offset(_imageX, _imageY),
                  child: Transform.rotate(
                    angle: _imageRotation,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: ClipRect(
                        child: Image.asset(
                          'assets/images/fried_rice.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const NutritionPage(),
          ),
        );
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
