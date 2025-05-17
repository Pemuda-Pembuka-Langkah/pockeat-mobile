// ignore_for_file: use_build_context_synchronously

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../widgets/onboarding_progress_indicator.dart';
import 'form_cubit.dart';

// No unused imports

class HeightWeightPage extends StatefulWidget {
  const HeightWeightPage({super.key});

  @override
  State<HeightWeightPage> createState() => _HeightWeightPageState();
}

class _HeightWeightPageState extends State<HeightWeightPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  double? _height;
  // Default weight value for the slider
  int _selectedWeight = 65;

  // Error message for height field
  String? _heightErrorText;

  final Color primaryGreen = const Color(0xFF4ECDC4);
  final Color primaryGreenDisabled = const Color(0xFF4ECDC4).withOpacity(0.4);
  final Color bgColor = const Color(0xFFF9F9F9);
  final Color errorColor = const Color(0xFFFF6B6B);
  final Color textDarkColor = Colors.black87;

  // Controller untuk tracking input height
  final TextEditingController _heightController = TextEditingController();

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Listen for changes in the height field to update button state and validate
    _heightController.addListener(() {
      _validateHeight(_heightController.text);
      setState(() {}); // Rebuild to update button disabled state
    });

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  // Validate height and set error message
  void _validateHeight(String value) {
    final height = double.tryParse(value);
    setState(() {
      if (value.isEmpty) {
        _heightErrorText = null;
      } else if (height == null || height <= 0) {
        _heightErrorText = 'Please enter a valid height';
      } else if (height < 50 || height > 300) {
        _heightErrorText = 'Height must be between 50 and 300 cm';
      } else {
        _heightErrorText = null;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: Colors.black87, size: 20),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      bgColor,
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Onboarding progress indicator
                          const OnboardingProgressIndicator(
                            totalSteps: 16,
                            currentStep:
                                1, // This is the second step (0-indexed)
                            barHeight: 6.0,
                            showPercentage: true,
                          ),

                          const SizedBox(height: 20),

                          // No back button here
                          const SizedBox(height: 8),

                          // Title with modern style
                          const Text(
                            "Measurements",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "Enter your height and weight",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 32),

                          Expanded(
                              child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(_fadeAnimation),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                // Container wrapping height input with consistent styling
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Height label
                                                      const Text(
                                                        'Height (cm)',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14),
                                                      ),
                                                      const SizedBox(
                                                          height: 12),

                                                      // Height input field without border since it's in a container
                                                      TextFormField(
                                                        controller:
                                                            _heightController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      12),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide: BorderSide(
                                                                color: _heightErrorText !=
                                                                        null
                                                                    ? errorColor
                                                                    : Colors
                                                                        .grey
                                                                        .shade300),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide: BorderSide(
                                                                color: _heightErrorText !=
                                                                        null
                                                                    ? errorColor
                                                                    : primaryGreen,
                                                                width: 1.5),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide: BorderSide(
                                                                color:
                                                                    errorColor,
                                                                width: 1.5),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide: BorderSide(
                                                                color:
                                                                    errorColor,
                                                                width: 1.5),
                                                          ),
                                                          errorText:
                                                              _heightErrorText,
                                                          errorStyle: TextStyle(
                                                              color: errorColor,
                                                              fontSize: 12),
                                                        ),
                                                        validator: (value) {
                                                          final height =
                                                              double.tryParse(
                                                                  value ?? '');
                                                          if (height == null ||
                                                              height <= 0) {
                                                            return 'Please enter a valid height';
                                                          }
                                                          if (height < 50 ||
                                                              height > 300) {
                                                            return 'Height must be between 50 and 300 cm';
                                                          }
                                                          return null;
                                                        },
                                                        onSaved: (value) =>
                                                            _height =
                                                                double.tryParse(
                                                                    value ??
                                                                        ''),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                // Weight label with container
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Weight label
                                                      const Text(
                                                        'Weight (kg)',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14),
                                                      ),
                                                      const SizedBox(
                                                          height: 12),

                                                      // Weight display
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            '$_selectedWeight',
                                                            style: TextStyle(
                                                              fontSize: 32,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  primaryGreen,
                                                            ),
                                                          ),
                                                          const Text(
                                                            ' kg',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(
                                                          height: 16),

                                                      // Slider for weight selection
                                                      SliderTheme(
                                                        data: SliderThemeData(
                                                          activeTrackColor:
                                                              primaryGreen,
                                                          inactiveTrackColor:
                                                              Colors.grey
                                                                  .shade300,
                                                          thumbColor:
                                                              Colors.white,
                                                          overlayColor:
                                                              primaryGreen
                                                                  .withOpacity(
                                                                      0.2),
                                                          thumbShape:
                                                              const RoundSliderThumbShape(
                                                                  enabledThumbRadius:
                                                                      12),
                                                          overlayShape:
                                                              const RoundSliderOverlayShape(
                                                                  overlayRadius:
                                                                      24),
                                                          trackHeight: 4,
                                                        ),
                                                        child: Slider(
                                                          value: _selectedWeight
                                                              .toDouble(),
                                                          min: 30,
                                                          max: 150,
                                                          divisions: 120,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedWeight =
                                                                  value.round();
                                                            });
                                                          },
                                                        ),
                                                      ),

                                                      // Min-max labels
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text('30 kg',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600)),
                                                            Text('150 kg',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600)),
                                                          ],
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                          height: 16),

                                                      // + and - buttons for fine adjustment
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          // Minus button
                                                          InkWell(
                                                            onTap: () {
                                                              if (_selectedWeight >
                                                                  30) {
                                                                setState(() {
                                                                  _selectedWeight--;
                                                                });
                                                              }
                                                            },
                                                            child: Container(
                                                              width: 42,
                                                              height: 42,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                              ),
                                                              child: const Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black87,
                                                                  size: 20),
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                              width: 24),

                                                          // Plus button
                                                          InkWell(
                                                            onTap: () {
                                                              if (_selectedWeight <
                                                                  150) {
                                                                setState(() {
                                                                  _selectedWeight++;
                                                                });
                                                              }
                                                            },
                                                            child: Container(
                                                              width: 42,
                                                              height: 42,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: primaryGreen
                                                                    .withOpacity(
                                                                        0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                border: Border.all(
                                                                    color: primaryGreen
                                                                        .withOpacity(
                                                                            0.3)),
                                                              ),
                                                              child: Icon(
                                                                  Icons.add,
                                                                  color:
                                                                      primaryGreen,
                                                                  size: 20),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // BMI display if both height and weight are entered
                                                if (_isFormValid()) ...[
                                                  const SizedBox(height: 24),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color: primaryGreen
                                                          .withOpacity(0.05),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: primaryGreen
                                                              .withOpacity(
                                                                  0.2)),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                              'Your BMI',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: _getBMIStatusColor()
                                                                    .withOpacity(
                                                                        0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Text(
                                                                _getBMICategory(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      _getBMIStatusColor(),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              _calculateBMI()
                                                                  .toStringAsFixed(
                                                                      1),
                                                              style: TextStyle(
                                                                fontSize: 28,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    primaryGreen,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          4),
                                                              child: Text(
                                                                'kg/m²',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child:
                                                              LinearProgressIndicator(
                                                            value:
                                                                _getBMIProgressValue(),
                                                            minHeight: 8,
                                                            backgroundColor:
                                                                Colors.grey
                                                                    .shade200,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    _getBMIStatusColor()),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        Text(
                                                          _getBMIDescription(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryGreen,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              disabledBackgroundColor:
                                                  primaryGreenDisabled,
                                              disabledForegroundColor:
                                                  Colors.white,
                                            ),
                                            onPressed: _isFormValid()
                                                ? _handleNextPressed
                                                : null,
                                            child: const Text(
                                              "Add Measurements",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                          ))
                        ])))));
  }

  // Check if form is valid (height is entered)
  bool _isFormValid() {
    return _heightController.text.isNotEmpty &&
        double.tryParse(_heightController.text) != null &&
        double.parse(_heightController.text) >= 50 &&
        double.parse(_heightController.text) <= 300;
  }

  // Calculate BMI from current height and weight inputs
  double _calculateBMI() {
    final height = double.parse(_heightController.text);
    final weight = _selectedWeight.toDouble();
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category based on BMI value
  String _getBMICategory() {
    final bmi = _calculateBMI();
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Get color based on BMI status
  Color _getBMIStatusColor() {
    final bmi = _calculateBMI();
    if (bmi < 18.5) {
      return Colors.blue.shade700; // Underweight
    } else if (bmi < 25) {
      return primaryGreen; // Normal
    } else if (bmi < 30) {
      return Colors.orange; // Overweight
    } else {
      return Colors.red.shade700; // Obese
    }
  }

  // Get BMI progress value for progress bar (0.0 to 1.0)
  double _getBMIProgressValue() {
    final bmi = _calculateBMI();
    // Scale between 15 and 35 for the visualization
    return ((bmi - 15) / 20).clamp(0.0, 1.0);
  }

  // Get description text based on BMI category
  String _getBMIDescription() {
    final bmi = _calculateBMI();
    if (bmi < 18.5) {
      return 'You may need to gain some weight for optimal health.';
    } else if (bmi < 25) {
      return 'You have a healthy weight. Keep it up!';
    } else if (bmi < 30) {
      return 'You may benefit from losing some weight.';
    } else {
      return 'A weight loss plan would be recommended for your health.';
    }
  }

  void _handleNextPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Use the _selectedWeight value directly instead of _weight
      final weight = _selectedWeight.toDouble();
      calculateBMI(_height!, weight);

      context.read<HealthMetricsFormCubit>().setHeightWeight(
            height: _height!,
            weight: weight,
          );

      Navigator.pushNamed(context, '/birthdate');
    }
  }

  double calculateBMI(double heightCm, double weightKg) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 24.9) {
      return 'Normal';
    } else if (bmi < 29.9) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }
}
