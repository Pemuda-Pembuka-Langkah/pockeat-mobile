import 'package:flutter/material.dart';

class DistanceSelectionWidget extends StatelessWidget {
  final Color primaryColor;
  final int selectedKm;
  final int selectedMeter;
  final Function(int) onKmChanged;
  final Function(int) onMeterChanged;

  const DistanceSelectionWidget({
    super.key,
    required this.primaryColor,
    required this.selectedKm,
    required this.selectedMeter,
    required this.onKmChanged,
    required this.onMeterChanged,
  });

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
        children: [
          Row(
            children: [
              Icon(Icons.route, color: primaryColor),
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
                    onKmChanged(index);
                  },
                  children: List.generate(43, (index) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedKm == index
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: selectedKm == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectedKm == index
                              ? primaryColor
                              : Colors.black54,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Text(
                'km',
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
                    onMeterChanged(index * 100);
                  },
                  children: List.generate(10, (index) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedMeter == index * 100
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index * 100}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: selectedMeter == index * 100
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selectedMeter == index * 100
                              ? primaryColor
                              : Colors.black54,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Text(
                'm',
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
    );
  }
}
