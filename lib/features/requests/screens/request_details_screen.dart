import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/status_helper.dart';
import '../../../models/service_request.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/timeline_widget.dart';
import '../providers/requests_provider.dart';

class RequestDetailsScreen extends ConsumerStatefulWidget {
  final ServiceRequest request;

  const RequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  ConsumerState<RequestDetailsScreen> createState() =>
      _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends ConsumerState<RequestDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(requestsProvider.notifier).fetchHistory(widget.request.id);
    });
  }

  void _confirmCancelRequest(ServiceRequest currentReq) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Service Request?'),
        content: Text(
          'Are you sure you want to cancel request ${currentReq.requestId}? This action cannot be reversed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Request',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(requestsProvider.notifier)
                  .cancelRequest(currentReq.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Service request has been cancelled.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                setState(() {});
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestsProvider);

    final currentReq = requestsState.requests.firstWhere(
      (r) => r.id == widget.request.id,
      orElse: () => widget.request,
    );

    final canCancel = StatusHelper.isCancellationAllowed(currentReq.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          currentReq.requestId,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
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
            // Status & Urgency Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          StatusBadge(status: currentReq.status),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Urgency',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          StatusBadge(
                              status: currentReq.priority, isPriority: true),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Submitted On:',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        DateFormatter.formatDateTime(currentReq.createdAt),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Visual Status Stepper Timeline
            TimelineWidget(currentStatus: currentReq.status),
            const SizedBox(height: 20),

            // Service Details Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Information',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    Icons.build_outlined,
                    'Service Type',
                    currentReq.service?.name ?? 'General Service',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.description_outlined,
                    'Description',
                    currentReq.description,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Scheduled Date',
                    DateFormatter.formatDate(currentReq.preferredDate),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.access_time_outlined,
                    'Time Window',
                    currentReq.preferredTime,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Service Address',
                    currentReq.address,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Assigned Agent Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assigned Field Technician',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  if (currentReq.agent != null)
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentReq.agent!.fullName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Certified Service Agent',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_search_outlined,
                              color: AppColors.textMuted, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Technician assignment in progress. Admin dispatch will allocate a verified specialist soon.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Agent Work Notes
            if (currentReq.notes != null && currentReq.notes!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 18, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Text(
                          'Technician Work Notes',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentReq.notes!,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF78350F), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Cancellation Action (Allowed only when CREATED or ASSIGNED)
            if (canCancel)
              CustomButton(
                text: 'Cancel Request',
                backgroundColor: AppColors.error,
                isLoading: requestsState.isSubmitting,
                onPressed: () => _confirmCancelRequest(currentReq),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
