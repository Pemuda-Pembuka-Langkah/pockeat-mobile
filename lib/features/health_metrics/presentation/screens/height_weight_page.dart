import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

class HeightWeightPage extends StatefulWidget {
  const HeightWeightPage({super.key});

  @override
  State<HeightWeightPage> createState() => _HeightWeightPageState();
}

class _HeightWeightPageState extends State<HeightWeightPage> {
  final _formKey = GlobalKey<FormState>();
  double? _height;
  double? _weight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Height & Weight")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                ),
                validator: (value) {
                  final height = double.tryParse(value ?? '');
                  if (height == null || height <= 0) {
                    return 'Please enter a valid height';
                  }
                  return null;
                },
                onSaved: (value) => _height = double.tryParse(value ?? ''),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                ),
                validator: (value) {
                  final weight = double.tryParse(value ?? '');
                  if (weight == null || weight <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
                onSaved: (value) => _weight = double.tryParse(value ?? ''),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    context.read<HealthMetricsFormCubit>().setHeightWeight(
                          height: _height!,
                          weight: _weight!,
                        );
                    Navigator.pushNamed(context, '/birthdate');
                  }
                },
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}