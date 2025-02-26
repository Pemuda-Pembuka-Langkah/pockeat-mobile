import 'package:flutter/material.dart';

class WorkoutFormWidget extends StatefulWidget {
  final Function(String) onAnalyzePressed;
  final bool isLoading;

  const WorkoutFormWidget({
    super.key,
    required this.onAnalyzePressed,
    this.isLoading = false,
  });

  @override
  State<WorkoutFormWidget> createState() => _WorkoutFormWidgetState();
}

class _WorkoutFormWidgetState extends State<WorkoutFormWidget> {
  final TextEditingController _workoutController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _workoutController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final input = _workoutController.text.trim();
    
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Deskripsi olahraga tidak boleh kosong';
      });
      return;
    }
    
    setState(() {
      _errorMessage = null;
    });
    
    widget.onAnalyzePressed(input);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
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
          const Text(
            'Ceritakan aktivitas olahragamu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Berikan detail seperti jenis, durasi, dan intensitas olahraga',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _workoutController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Contoh: "Lari pagi selama 30 menit dengan intensitas sedang" atau "HIIT workout for 15 minutes"',
              hintStyle: const TextStyle(color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black26),
              ),
              errorText: _errorMessage,
            ),
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B6BFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Analisis Olahraga',
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
    );
  }
}