import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

class DesiredWeightPage extends StatefulWidget {
  const DesiredWeightPage({super.key});

  @override
  State<DesiredWeightPage> createState() => _DesiredWeightPageState();
}

class _DesiredWeightPageState extends State<DesiredWeightPage> {
  final _formKey = GlobalKey<FormState>();
  double? _desiredWeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("What's your target weight?")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target weight (kg)',
                ),
                validator: (value) {
                  final weight = double.tryParse(value ?? '');
                  if (weight == null || weight <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
                onSaved: (value) => _desiredWeight = double.tryParse(value ?? ''),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    context.read<HealthMetricsFormCubit>().setDesiredWeight(_desiredWeight!);
                    Navigator.pushNamed(context, '/speed');
                  }
                },
                child: const Text("Next"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
