import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/status_helper.dart';

class TimelineWidget extends StatelessWidget {
  final String currentStatus;

  const TimelineWidget({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = currentStatus.toUpperCase();
    final isCancelled = status == 'CANCELLED';

    final steps = [
      {'key': 'CREATED', 'label': 'Created', 'desc': 'Request submitted by customer'},
      {'key': 'ASSIGNED', 'label': 'Assigned', 'desc': 'Technician assigned by admin'},
      {'key': 'ACCEPTED', 'label': 'Accepted', 'desc': 'Technician confirmed dispatch'},
      {'key': 'IN_PROGRESS', 'label': 'In Progress', 'desc': 'Work is actively underway'},
      {'key': 'COMPLETED', 'label': 'Completed', 'desc': 'Job successfully resolved'},
    ];

    final currentIndex = isCancelled
        ? -1
        : steps.indexWhere((s) => s['key'] == status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Request Status Timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CANCELLED',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final isPassed = !isCancelled && index < currentIndex;
              final isCurrent = !isCancelled && index == currentIndex;
              final isFuture = isCancelled || index > currentIndex;
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _buildIndicator(isPassed, isCurrent, isFuture),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          color: isPassed ? AppColors.success : AppColors.cardBorder,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                step['label']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isCurrent ? FontWeight.w700 : (isPassed ? FontWeight.w600 : FontWeight.w500),
                                  color: isCurrent
                                      ? AppColors.primary
                                      : (isPassed ? AppColors.textPrimary : AppColors.textMuted),
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['desc']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrent ? AppColors.textSecondary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isPassed, bool isCurrent, bool isFuture) {
    if (isPassed) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 15, color: Colors.white),
      );
    }

    if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
    );
  }
}
