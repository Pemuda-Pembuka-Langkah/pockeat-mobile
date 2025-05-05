// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:pockeat/core/services/analytics_service.dart';

// Project imports:
import 'package:pockeat/features/authentication/services/google_sign_in_service.dart';
import 'package:pockeat/features/health_metrics/presentation/screens/form_cubit.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isUnderTest;
  final GoogleSignInService? googleAuthService;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool isRegister;

  const GoogleSignInButton({
    super.key,
    this.isUnderTest = false,
    this.isRegister = false,
    this.googleAuthService,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 55, // Match height dengan button login
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            final service = googleAuthService ?? GetIt.I<GoogleSignInService>();
            final analyticsService = GetIt.I<AnalyticsService>();
            analyticsService.logEvent(
              name: isRegister ? 'google_sign_up_attempt' : 'google_sign_in_attempt'
            );
            final result = await service.signInWithGoogle();
            if (result.user != null && isRegister && context.mounted) {
              final uid = result.user!.uid;
              final formCubit = context.read<HealthMetricsFormCubit>();
              formCubit.setUserId(uid);
              await formCubit.submit();
            }
            // Log successful authentication
            if (context.mounted) {
              final analyticsService = GetIt.I<AnalyticsService>();
              analyticsService.logEvent(
                name: isRegister ? 'google_sign_up_success' : 'google_sign_in_success',
                parameters: {'uid': result.user?.uid ?? 'unknown'}
              );
              Navigator.pushReplacementNamed(context, '/');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: isUnderTest
              ? const Text('G', style: TextStyle(fontWeight: FontWeight.bold))
              // coverage:ignore-start
              : Image.asset(
                  'assets/images/google.png',
                  height: 20,
                ),
          // coverage:ignore-end
        ),
        label: Text(
          isRegister ? 'Register with Google' : 'Sign in with Google',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Match dengan button login
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
