import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

class SpeedSelectionPage extends StatefulWidget {
  const SpeedSelectionPage({super.key});

  @override
  State<SpeedSelectionPage> createState() => _SpeedSelectionPageState();
}

class _SpeedSelectionPageState extends State<SpeedSelectionPage> {
  double _weeklyGoal = 0.5; // in kg/week

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("How fast do you want to reach your goal?")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly weight change target (kg/week)"),
            Slider(
              value: _weeklyGoal,
              onChanged: (value) => setState(() => _weeklyGoal = value),
              min: 0.1,
              max: 2.0,
              divisions: 19,
              label: "${_weeklyGoal.toStringAsFixed(1)} kg/week",
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<HealthMetricsFormCubit>().setWeeklyGoal(_weeklyGoal);
                  Navigator.pushNamed(context, '/review');
                },
                child: const Text("Next"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
