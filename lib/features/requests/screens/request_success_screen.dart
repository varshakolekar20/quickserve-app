import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';

class RequestSuccessScreen extends StatelessWidget {
  final String requestId;

  const RequestSuccessScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 54),
              ),
              const SizedBox(height: 24),
              const Text(
                'Request Created!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your unique reference ID:',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  requestId,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your service request has been submitted successfully and sent to the Admin Web Application for technician assignment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Track Request',
                onPressed: () => context.go('/requests'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
