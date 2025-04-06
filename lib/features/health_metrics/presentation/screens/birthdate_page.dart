import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_cubit.dart';

class BirthdatePage extends StatefulWidget {
  const BirthdatePage({super.key});

  @override
  State<BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<BirthdatePage> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("When were you born?"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(_selectedDate != null
                  ? "Selected: ${_selectedDate!.toLocal().toString().split(' ')[0]}"
                  : "Choose your birthdate"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedDate == null
                  ? null
                  : () {
                      context
                          .read<HealthMetricsFormCubit>()
                          .setBirthDate(_selectedDate!);
                      Navigator.pushNamed(context, '/diet');
                    },
              child: const Text("Next"),
            )
          ],
        ),
      ),
    );
  }
}