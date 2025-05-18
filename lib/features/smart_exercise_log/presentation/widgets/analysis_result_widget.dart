// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pockeat/features/smart_exercise_log/domain/models/exercise_analysis_result.dart';

class AnalysisResultWidget extends StatelessWidget {
  final ExerciseAnalysisResult analysisResult;
  final VoidCallback onRetry;
  final VoidCallback onSave;
  final Function(String) onCorrect;

  const AnalysisResultWidget({
    super.key,
    required this.analysisResult,
    required this.onRetry,
    required this.onSave,
    required this.onCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final hasMissingInfo = analysisResult.missingInfo != null &&
        analysisResult.missingInfo!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercise Analysis Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Display missing information warning if needed
          if (hasMissingInfo) _buildMissingInfoSection(),

          // Display summary if available
          if (analysisResult.summary != null) ...[
            Text(
              analysisResult.summary!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],

          // Always add the divider regardless of summary existence
          const Divider(height: 24, color: Colors.black12),

          // Display analysis data
          _buildStatRow('Exercise Type', analysisResult.exerciseType),
          _buildStatRow('Duration', analysisResult.duration),
          _buildStatRow('Intensity', analysisResult.intensity),
          _buildStatRow(
              'Estimated Calories', '${analysisResult.estimatedCalories} kcal'),

          // Display MET value if greater than 0
          if (analysisResult.metValue > 0)
            _buildStatRow('MET', analysisResult.metValue.toStringAsFixed(1)),

          const SizedBox(height: 20),

          // Action buttons
          if (analysisResult.isComplete) ...[
            // Show correction button first
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCorrectionDialog(context),
                icon: const Icon(Icons.edit_note, color: Colors.orange),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: const Text(
                  'Correct Analysis',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Show both try again and save buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF9B6BFF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Color(0xFF9B6BFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B6BFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Log',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ] else ...[
            // Only show 'Try Again' button if data is incomplete
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF9B6BFF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Color(0xFF9B6BFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingInfoSection() {
    final missingInfo = analysisResult.missingInfo!;
    final missingLabels = {
      'type': 'Exercise type',
      'duration': 'Exercise duration',
      'intensity': 'Exercise intensity',
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incomplete Information',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please provide more details about:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          ...missingInfo.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${missingLabels[item] ?? item}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showCorrectionDialog(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    const primaryPurple = Color(0xFF9B6BFF);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: primaryPurple),
            SizedBox(width: 12),
            Text(
              'Correct Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide details on what needs to be corrected:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                autofocus: true,
                cursorColor: primaryPurple,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  fillColor: Colors.grey[50],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: primaryPurple, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  hintText:
                      'e.g., "I actually ran for 45 minutes" or "The intensity was high"',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your feedback helps us improve the exercise analysis.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final comment = commentController.text.trim();
              if (comment.isNotEmpty) {
                Navigator.pop(context);
                onCorrect(comment);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.check),
            label: const Text(
              'Submit Correction',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
