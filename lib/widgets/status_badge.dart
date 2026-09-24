import 'package:flutter/material.dart';
import '../core/utils/status_helper.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPriority;

  const StatusBadge({
    super.key,
    required this.status,
    this.isPriority = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPriority
        ? StatusHelper.getPriorityColor(status)
        : StatusHelper.getStatusColor(status);

    final label =
        isPriority ? status.toUpperCase() : StatusHelper.getDisplayName(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
