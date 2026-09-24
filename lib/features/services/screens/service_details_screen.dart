import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/service_item.dart';
import '../../../widgets/custom_button.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceItem? service;

  const ServiceDetailsScreen({
    super.key,
    this.service,
  });

  @override
  Widget build(BuildContext context) {
    final title = service?.name ?? 'Service Details';
    final description = service?.description ??
        'Professional diagnostic and repair services provided by verified field technicians.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Banner Hero Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.build_rounded,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'AVAILABLE FOR IMMEDIATE DISPATCH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Scope & Highlights',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 16),
                  _buildFeatureRow(Icons.check_circle_outline,
                      'Verified & Background-Checked Specialists'),
                  const SizedBox(height: 10),
                  _buildFeatureRow(Icons.schedule_outlined,
                      'Flexible Preferred Date & Time Slots'),
                  const SizedBox(height: 10),
                  _buildFeatureRow(Icons.receipt_long_outlined,
                      'Automatic Unique Request Reference ID'),
                  const SizedBox(height: 10),
                  _buildFeatureRow(Icons.security_outlined,
                      'Full Real-Time Status Tracking'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Prominent Book Button
            CustomButton(
              text: AppStrings.bookThisService,
              onPressed: () {
                context.push('/create-request', extra: {
                  'serviceId': service?.id,
                  'serviceName': service?.name,
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.success),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
