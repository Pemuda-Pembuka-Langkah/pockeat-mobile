import 'package:flutter/material.dart';

// Pindahkan enum ke level teratas file
enum CardioType { running, cycling, swimming }

class CardioInputPage extends StatefulWidget {
  const CardioInputPage({super.key});

  @override
  _CardioInputPageState createState() => _CardioInputPageState();
}

class _CardioInputPageState extends State<CardioInputPage> {
  // Theme colors
  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);
  
  int selectedKm = 5;
  int selectedMeter = 0;
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(minutes: 30));
  int durationInMinutes = 30;

  // Tambahkan enum untuk tipe aktivitas
  CardioType selectedType = CardioType.running;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(          
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Running',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cardio Type Selection
              const Text(
                'Cardio Exercise Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildCardioTypeButton(CardioType.running, 'Running', Icons.directions_run),
                  const SizedBox(width: 8),
                  _buildCardioTypeButton(CardioType.cycling, 'Cycling', Icons.directions_bike),
                  const SizedBox(width: 8),
                  _buildCardioTypeButton(CardioType.swimming, 'Swimming', Icons.pool),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Form fields sesuai tipe yang dipilih
              _buildFormFields(),
              
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
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
                  content: const Text('Run saved successfully!'),
                  backgroundColor: primaryPink,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Run',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardioTypeButton(CardioType type, String label, IconData icon) {
    bool isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryPink.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryPink : Colors.black12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primaryPink : Colors.black54),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.black54,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return switch (selectedType) {
      CardioType.running => _buildRunningFields(),
      CardioType.cycling => _buildcyclingfields(),
      CardioType.swimming => _buildSwimmingFields(),
    };
  }

  Widget _buildRunningFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        
        // Time Selection Container
        Container(
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
            children: [
              // Start Time
              Row(
                children: [
                  Icon(Icons.play_circle, color: primaryPink),
                  const SizedBox(width: 8),
                  const Text(
                    'Start Time',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedStartTime),
                  );
                  if (time != null) {
                    setState(() {
                      selectedStartTime = DateTime(
                        selectedStartTime.year,
                        selectedStartTime.month,
                        selectedStartTime.day,
                        time.hour,
                        time.minute,
                      );
                      // Automatically adjust end time if it's before start time
                      if (selectedEndTime.isBefore(selectedStartTime)) {
                        selectedEndTime = selectedStartTime.add(const Duration(minutes: 30));
                      }
                    });
                  }
                },
                child: Text(
                  TimeOfDay.fromDateTime(selectedStartTime).format(context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // End Time
              Row(
                children: [
                  Icon(Icons.stop_circle, color: primaryPink),
                  const SizedBox(width: 8),
                  const Text(
                    'End Time',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedEndTime),
                  );
                  if (time != null) {
                    setState(() {
                      // Handle midnight crossing
                      DateTime newEndTime = DateTime(
                        selectedStartTime.year,
                        selectedStartTime.month,
                        selectedStartTime.day,
                        time.hour,
                        time.minute,
                      );
                      
                      // If end time is before start time, assume it's the next day
                      if (time.hour < TimeOfDay.fromDateTime(selectedStartTime).hour ||
                          (time.hour == TimeOfDay.fromDateTime(selectedStartTime).hour &&
                           time.minute < TimeOfDay.fromDateTime(selectedStartTime).minute)) {
                        newEndTime = newEndTime.add(const Duration(days: 1));
                      }
                      
                      selectedEndTime = newEndTime;
                    });
                  }
                },
                child: Text(
                  TimeOfDay.fromDateTime(selectedEndTime).format(context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Duration Display
              Text(
                'Duration: ${_formatDuration(selectedEndTime.difference(selectedStartTime))}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Distance Container (existing code)
        Container(
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
            children: [
              Row(
                children: [
                  Icon(Icons.route, color: primaryPink),
                  const SizedBox(width: 8),
                  const Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kilometer Scroll
                  SizedBox(
                    width: 80,
                    height: 120,
                    child: ListWheelScrollView(
                      itemExtent: 40,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedKm = index;
                        });
                      },
                      children: List.generate(43, (index) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedKm == index ? primaryPink.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$index',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: selectedKm == index ? FontWeight.bold : FontWeight.normal,
                              color: selectedKm == index ? primaryPink : Colors.black54,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Text(
                    ' km  ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  // Meter Scroll
                  SizedBox(
                    width: 80,
                    height: 120,
                    child: ListWheelScrollView(
                      itemExtent: 40,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedMeter = index * 100;
                        });
                      },
                      children: List.generate(10, (index) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedMeter == index * 100 ? primaryPink.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index * 100}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: selectedMeter == index * 100 ? FontWeight.bold : FontWeight.normal,
                              color: selectedMeter == index * 100 ? primaryPink : Colors.black54,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Text(
                    ' m',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Total: ${selectedKm + (selectedMeter / 1000)} km',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} min';
    } else {
      return '$minutes min';
    }
  }

  Widget _buildcyclingfields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cycling Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            children: [
              Row(
                children: [
                  Icon(Icons.speed, color: primaryPink),
                  const SizedBox(width: 8),
                  const Text(
                    'Average Speed',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '20 km/h',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwimmingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Swimming Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
              Row(
                children: [
                  Icon(Icons.pool, color: primaryPink),
                  const SizedBox(width: 8),
                  const Text(
                    'Pool Length',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPoolLengthOption('25m'),
                  _buildPoolLengthOption('50m'),
                  _buildPoolLengthOption('Other'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.repeat, color: primaryPink),
                  const SizedBox(width: 8),
                  const Text(
                    'Laps',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '20 laps',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPoolLengthOption(String length) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        length,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}