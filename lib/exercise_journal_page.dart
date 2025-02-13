import 'package:flutter/material.dart';

class SmartJournalPage extends StatefulWidget {
  @override
  _SmartJournalPageState createState() => _SmartJournalPageState();
}

class _SmartJournalPageState extends State<SmartJournalPage> {
  // Warna tema yang konsisten
  final Color primaryYellow = Color(0xFFFFE893);
  final Color primaryPurple = Color(0xFF9B6BFF);
  
  final promptController = TextEditingController();
  Map<String, dynamic>? analysis;
  int selectedMood = 3;
  List<String?> photos = [null, null, null];
  bool isAnalyzing = false;

  void analyzeWorkout() {
    setState(() => isAnalyzing = true);
    
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isAnalyzing = false;
        
        if (promptController.text.toLowerCase().contains("hiit")) {
          analysis = {
            'type': 'HIIT Workout',
            'duration': '25 minutes',
            'intensity': 'High',
            'estimatedCalories': 280,
            'summary': 'High-intensity interval training session with bodyweight exercises',
          };
        } else if (promptController.text.toLowerCase().contains("yoga")) {
          analysis = {
            'type': 'Yoga Session',
            'duration': '45 minutes',
            'intensity': 'Low to Medium',
            'estimatedCalories': 150,
            'summary': 'Mindful yoga practice focusing on flexibility and balance',
          };
        } else {
          analysis = {
            'type': 'Mixed Training',
            'duration': '40 minutes',
            'intensity': 'Medium',
            'estimatedCalories': 220,
            'summary': 'Combined workout including cardio and strength elements',
          };
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Smart Workout Log',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Section
            Text(
              'How do you feel?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) => _buildMoodButton(index + 1)),
            ),

            SizedBox(height: 24),
            
            // Photo Section
            Text(
              'Progress Photos (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                  child: _buildPhotoButton(index),
                ),
              )),
            ),

            SizedBox(height: 24),
            
            // Workout Description Section
            Text(
              'Tell me about your workout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be as detailed as you like - I\'ll analyze it for you',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: promptController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'E.g. "Did a HIIT session with jumping jacks, burpees, and mountain climbers. Felt intense but good!"',
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: analyzeWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Let AI Analyze',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isAnalyzing)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Analyzing your workout...',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),

            if (analysis != null && !isAnalyzing) ...[
              SizedBox(height: 24),
              _buildAnalysisCard(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: analysis != null && !isAnalyzing ? Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Workout logged successfully!'),
                  backgroundColor: primaryPurple,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save Log',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildMoodButton(int mood) {
    final bool isSelected = selectedMood == mood;
    String emoji = ['😫', '😕', '😊', '😃', '🔥'][mood - 1];

    return GestureDetector(
      onTap: () => setState(() => selectedMood = mood),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? primaryPurple.withOpacity(0.1) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? primaryPurple : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  Widget _buildPhotoButton(int index) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.camera_alt, color: primaryPurple),
          onPressed: () {
            // Mock photo selection for demo
            setState(() => photos[index] = 'photo_url');
          },
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(
            analysis!['summary'],
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          Divider(height: 24, color: Colors.black12),
          _buildStatRow('Workout Type', analysis!['type']),
          _buildStatRow('Duration', analysis!['duration']),
          _buildStatRow('Intensity', analysis!['intensity']),
          _buildStatRow('Est. Calories', '${analysis!['estimatedCalories']} kcal'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}