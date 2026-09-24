import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../requests/providers/requests_provider.dart';

class AgentDashboardScreen extends ConsumerStatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  ConsumerState<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends ConsumerState<AgentDashboardScreen> {
  String _activeTab = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(authProvider).profile;
      if (profile != null) {
        ref.read(requestsProvider.notifier).fetchAgentRequests(profile.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final requestsState = ref.watch(requestsProvider);
    final agentName = authState.profile?.fullName ?? 'Technician';

    final allRequests = requestsState.requests;
    final assignedCount = allRequests.where((r) => r.status == 'ASSIGNED').length;
    final inProgressCount = allRequests.where((r) => r.status == 'ACCEPTED' || r.status == 'IN_PROGRESS').length;
    final completedCount = allRequests.where((r) => r.status == 'COMPLETED').length;

    List<dynamic> filteredRequests;
    if (_activeTab == 'PENDING') {
      filteredRequests = allRequests.where((r) => r.status == 'ASSIGNED').toList();
    } else if (_activeTab == 'IN_PROGRESS') {
      filteredRequests = allRequests.where((r) => r.status == 'ACCEPTED' || r.status == 'IN_PROGRESS').toList();
    } else if (_activeTab == 'COMPLETED') {
      filteredRequests = allRequests.where((r) => r.status == 'COMPLETED').toList();
    } else {
      filteredRequests = allRequests;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Technician Portal',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            Text(
              'Welcome, $agentName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authState.profile != null) {
            await ref.read(requestsProvider.notifier).fetchAgentRequests(authState.profile!.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workload & Field Queue',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Pending Acceptance',
                      value: '$assignedCount',
                      icon: Icons.assignment_late_outlined,
                      color: AppColors.statusAssigned,
                      onTap: () => setState(() => _activeTab = 'PENDING'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'Active Work',
                      value: '$inProgressCount',
                      icon: Icons.handyman_outlined,
                      color: AppColors.statusInProgress,
                      onTap: () => setState(() => _activeTab = 'IN_PROGRESS'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'Completed',
                      value: '$completedCount',
                      icon: Icons.task_alt,
                      color: AppColors.statusCompleted,
                      onTap: () => setState(() => _activeTab = 'COMPLETED'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('ALL', 'All Jobs (${allRequests.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('PENDING', 'Pending ($assignedCount)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('IN_PROGRESS', 'Active ($inProgressCount)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('COMPLETED', 'Completed ($completedCount)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (requestsState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (filteredRequests.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.check_circle_outline,
                  title: 'No Work In This Queue',
                  message: 'You have no assigned jobs in the selected category.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = filteredRequests[index];
                    return _buildAgentRequestCard(req);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeTab == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      onSelected: (_) => setState(() => _activeTab = key),
    );
  }

  Widget _buildAgentRequestCard(dynamic req) {
    return InkWell(
      onTap: () {
        context.push('/agent-request-details', extra: req);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  req.requestId,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                ),
                StatusBadge(status: req.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              req.service?.name ?? 'Assigned Job',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              req.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    req.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: req.priority, isPriority: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
