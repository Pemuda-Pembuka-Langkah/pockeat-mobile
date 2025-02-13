import 'package:flutter/material.dart';


import 'package:flutter/material.dart';


import 'package:flutter/material.dart';

class FoodCameraScreen extends StatefulWidget {
  @override
  _FoodCameraScreenState createState() => _FoodCameraScreenState();
}

class _FoodCameraScreenState extends State<FoodCameraScreen> {
  // State variables
  final ValueNotifier<double> _detectionProgress = ValueNotifier(0.0);
  final ValueNotifier<String> _guidanceText = ValueNotifier('Center your food in frame');
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _startDetection();
  }

  void _startDetection() {
    // Simulasi progress deteksi yang smooth
    Future.delayed(Duration(milliseconds: 500), () {
      _detectionProgress.value = 0.3;
      _guidanceText.value = "Sedikit ke kanan...";
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      _detectionProgress.value = 0.7;
      _guidanceText.value = "Hampir...";
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      _detectionProgress.value = 1.0;
      _guidanceText.value = "Perfect! Tap to analyze";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                'https://picsum.photos/400/800',
                fit: BoxFit.cover,
              ),
            ),

            // Guidance and Frame
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Progress and Guidance Text
                  ValueListenableBuilder<String>(
                    valueListenable: _guidanceText,
                    builder: (context, text, _) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Progress Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: ValueListenableBuilder<double>(
                      valueListenable: _detectionProgress,
                      builder: (context, progress, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromRGBO(58, 183, 149, 1)
                            ),
                            minHeight: 4,
                          ),
                        );
                      },
                    ),
                  ),

                  // Frame
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 40,
                  top: 20,
                  left: 30,
                  right: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOption(
                      icon: Icons.photo_outlined,
                      label: 'Gallery',
                      onTap: () {},
                    ),
                    _buildCaptureButton(),
                    _buildOption(
                      icon: Icons.qr_code_scanner_outlined,
                      label: 'Barcode',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAnalyzing = true;
        });
        // Add navigation or analysis logic here
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _detectionProgress.dispose();
    _guidanceText.dispose();
    super.dispose();
  }
}
// Analysis Screen setelah foto diambil
class FoodAnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Food Analysis',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Preview
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[200],
              child: Image.network(
                'https://picsum.photos/400/300',
                fit: BoxFit.cover,
              ),
            ),

            // Analysis Results
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nasi Goreng Special',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Nutrition Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildNutritionCard('Calories', '456'),
                      _buildNutritionCard('Protein', '15g'),
                      _buildNutritionCard('Carbs', '65g'),
                      _buildNutritionCard('Fat', '12g'),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Confirm & Save'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text('Retake Photo'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}