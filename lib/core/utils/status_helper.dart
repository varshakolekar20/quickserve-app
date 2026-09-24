import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusHelper {
  static const List<String> lifecycleSteps = [
    'CREATED',
    'ASSIGNED',
    'ACCEPTED',
    'IN_PROGRESS',
    'COMPLETED',
  ];

  static bool isCancellationAllowed(String status) {
    return status.toUpperCase() == 'CREATED' ||
        status.toUpperCase() == 'ASSIGNED';
  }

  static bool isValidTransition(String currentStatus, String targetStatus) {
    final curr = currentStatus.toUpperCase();
    final target = targetStatus.toUpperCase();

    if (curr == target) return true;

    switch (curr) {
      case 'CREATED':
        return target == 'ASSIGNED' || target == 'CANCELLED';
      case 'ASSIGNED':
        return target == 'ACCEPTED' || target == 'CANCELLED';
      case 'ACCEPTED':
        return target == 'IN_PROGRESS';
      case 'IN_PROGRESS':
        return target == 'COMPLETED';
      case 'COMPLETED':
      case 'CANCELLED':
      default:
        return false;
    }
  }

  static String getDisplayName(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return 'Created';
      case 'ASSIGNED':
        return 'Assigned';
      case 'ACCEPTED':
        return 'Accepted';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return AppColors.statusCreated;
      case 'ASSIGNED':
        return AppColors.statusAssigned;
      case 'ACCEPTED':
        return AppColors.statusAccepted;
      case 'IN_PROGRESS':
        return AppColors.statusInProgress;
      case 'COMPLETED':
        return AppColors.statusCompleted;
      case 'CANCELLED':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return Icons.note_add_outlined;
      case 'ASSIGNED':
        return Icons.person_add_alt_1_outlined;
      case 'ACCEPTED':
        return Icons.assignment_turned_in_outlined;
      case 'IN_PROGRESS':
        return Icons.handyman_outlined;
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return AppColors.priorityLow;
      case 'MEDIUM':
        return AppColors.priorityMedium;
      case 'HIGH':
        return AppColors.priorityHigh;
      default:
        return AppColors.textSecondary;
    }
  }
}
