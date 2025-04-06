import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  final List<String> _options = [
    'No specific diet',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
    'Low-carb',
    'Other',
  ];

  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Do you follow a specific diet?")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._options.map((diet) => RadioListTile<String>(
                  title: Text(diet),
                  value: diet,
                  groupValue: _selected,
                  onChanged: (value) => setState(() => _selected = value),
                )),
            const Spacer(),
            ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () {
                      context.read<HealthMetricsFormCubit>().setDietType(_selected!);
                      Navigator.pushNamed(context, '/desired-weight');
                    },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
