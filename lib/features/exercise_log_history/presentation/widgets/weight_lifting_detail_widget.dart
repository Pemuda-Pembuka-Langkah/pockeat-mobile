import 'package:flutter/material.dart';
import 'package:pockeat/features/weight_training_log/domain/models/weight_lifting.dart';

class WeightLiftingDetailWidget extends StatelessWidget {
  final WeightLifting weightLifting;

  const WeightLiftingDetailWidget({
    Key? key,
    required this.weightLifting,
  }) : super(key: key);

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weightLifting.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Body Part: ${weightLifting.bodyPart}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Date', '${weightLifting.timestamp.day}/${weightLifting.timestamp.month}/${weightLifting.timestamp.year}'),
                    _buildInfoRow('Time', '${weightLifting.timestamp.hour.toString().padLeft(2, '0')}:${weightLifting.timestamp.minute.toString().padLeft(2, '0')}'),
                    _buildInfoRow('MET Value', weightLifting.metValue.toString()),
                    _buildInfoRow('Number of Sets', weightLifting.sets.length.toString()),
                    const SizedBox(height: 16),
                    const Text(
                      'Sets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...weightLifting.sets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final set = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Set ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow('Weight (kg)', set.weight.toString()),
                              _buildInfoRow('Repetitions', set.reps.toString()),
                              _buildInfoRow('Duration (sec)', set.duration.toString()),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
