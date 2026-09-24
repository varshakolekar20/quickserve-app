import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/service_request.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/timeline_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../requests/providers/requests_provider.dart';

class AgentRequestDetailsScreen extends ConsumerStatefulWidget {
  final ServiceRequest request;

  const AgentRequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  ConsumerState<AgentRequestDetailsScreen> createState() =>
      _AgentRequestDetailsScreenState();
}

class _AgentRequestDetailsScreenState
    extends ConsumerState<AgentRequestDetailsScreen> {
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.request.notes ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(requestsProvider.notifier).fetchHistory(widget.request.id);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleStatusTransition(
      ServiceRequest currentReq, String nextStatus) async {
    final success = await ref.read(requestsProvider.notifier).updateAgentStatus(
          requestId: currentReq.id,
          targetStatus: nextStatus,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $nextStatus successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {});
    }
  }

  void _saveWorkNotes(ServiceRequest currentReq) async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;

    final success = await ref.read(requestsProvider.notifier).updateAgentStatus(
          requestId: currentReq.id,
          targetStatus: currentReq.status,
          note: note,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Technician work notes saved.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestsProvider);
    final authState = ref.watch(authProvider);

    final currentReq = requestsState.requests.firstWhere(
      (r) => r.id == widget.request.id,
      orElse: () => widget.request,
    );

    final currentAgentId = authState.profile?.id;
    final isAssignedToCurrentAgent = currentReq.agentId == null ||
        currentReq.agentId == currentAgentId ||
        authState.profile?.role == 'agent';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Manage ${currentReq.requestId}',
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
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Job Status',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      StatusBadge(status: currentReq.status),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Urgency',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      StatusBadge(
                          status: currentReq.priority, isPriority: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TimelineWidget(currentStatus: currentReq.status),
            const SizedBox(height: 18),
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
                    'Customer & Site Contact',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.person, 'Customer Name',
                      currentReq.customer?.fullName ?? 'Varsha Kolekar'),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.phone, 'Contact Phone',
                      currentReq.customer?.phone ?? '+1 (555) 012-7711'),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                      Icons.location_on, 'Service Address', currentReq.address),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.event, 'Preferred Appointment',
                      '${DateFormatter.formatDate(currentReq.preferredDate)} • ${currentReq.preferredTime}'),
                ],
              ),
            ),
            const SizedBox(height: 18),
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
                    'Scope of Work',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentReq.service?.name ?? 'General Maintenance',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentReq.description,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
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
                    'Work Notes & Observations',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Record diagnosis details, parts used, or testing findings for customer and admin records.',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Enter field observations, repairs made, parts replaced...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _saveWorkNotes(currentReq),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Save Note'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (isAssignedToCurrentAgent) ...[
              if (currentReq.status == 'ASSIGNED')
                CustomButton(
                  text: 'Accept Request',
                  backgroundColor: AppColors.statusAccepted,
                  icon: Icons.assignment_turned_in,
                  isLoading: requestsState.isSubmitting,
                  onPressed: () =>
                      _handleStatusTransition(currentReq, 'ACCEPTED'),
                )
              else if (currentReq.status == 'ACCEPTED')
                CustomButton(
                  text: 'Start Work',
                  backgroundColor: AppColors.statusInProgress,
                  icon: Icons.play_arrow_rounded,
                  isLoading: requestsState.isSubmitting,
                  onPressed: () =>
                      _handleStatusTransition(currentReq, 'IN_PROGRESS'),
                )
              else if (currentReq.status == 'IN_PROGRESS')
                CustomButton(
                  text: 'Complete Request',
                  backgroundColor: AppColors.statusCompleted,
                  icon: Icons.task_alt,
                  isLoading: requestsState.isSubmitting,
                  onPressed: () =>
                      _handleStatusTransition(currentReq, 'COMPLETED'),
                )
              else if (currentReq.status == 'COMPLETED')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success),
                      SizedBox(width: 8),
                      Text(
                        'This request has been successfully completed.',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.success),
                      ),
                    ],
                  ),
                ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Access restricted: You are not the assigned technician for this request.',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
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
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
