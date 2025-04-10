import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final Color primaryYellow = const Color(0xFFFFE893);
  final Color primaryPink = const Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryYellow,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final inProgress = prefs.getBool('onboardingInProgress') ?? true;

            if (inProgress && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); 
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst); 
            }
          },
        ),
        title: const Text(
          "Target Weight",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's your target weight?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPink.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target weight (kg)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final weight = double.tryParse(value ?? '');
                          if (weight == null || weight <= 0) {
                            return 'Please enter a valid weight';
                          }
                          if (weight < 10 || weight > 500) {
                            return 'Weight must be between 10 and 500 kg';
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            _desiredWeight = double.tryParse(value ?? ''),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            context
                                .read<HealthMetricsFormCubit>()
                                .setDesiredWeight(_desiredWeight!);
                            Navigator.pushNamed(context, '/speed');
                          }
                        },
                        child: const Text("Next"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}