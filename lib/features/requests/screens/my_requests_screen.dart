import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/requests_provider.dart';

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestsProvider);
    final authState = ref.watch(authProvider);

    final activeList = requestsState.activeRequests;
    final historyList = requestsState.historyRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Service Requests',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(text: 'Active Jobs (${activeList.length})'),
            Tab(text: 'History (${historyList.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestList(activeList, isHistory: false, authState: authState),
          _buildRequestList(historyList, isHistory: true, authState: authState),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/create-request'),
        icon: const Icon(Icons.add),
        label: const Text('Book Service', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildRequestList(List<dynamic> list, {required bool isHistory, required AuthState authState}) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: isHistory ? Icons.history_rounded : Icons.assignment_outlined,
        title: isHistory ? 'No Past History' : 'No Active Requests',
        message: isHistory
            ? 'Your completed or cancelled requests will appear here.'
            : 'You currently have no active service requests.',
        buttonText: isHistory ? null : 'Book a Service',
        onButtonPressed: isHistory ? null : () => context.push('/create-request'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (authState.profile != null) {
          await ref.read(requestsProvider.notifier).fetchCustomerRequests(authState.profile!.id);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final req = list[index];
          return InkWell(
            onTap: () => context.push('/request-details', extra: req),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            req.requestId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      StatusBadge(status: req.status),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    req.service?.name ?? 'Service Request',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    req.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 14),

                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatDate(req.preferredDate),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      StatusBadge(status: req.priority, isPriority: true),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
