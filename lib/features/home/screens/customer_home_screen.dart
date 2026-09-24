import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../services/providers/services_provider.dart';
import '../../requests/providers/requests_provider.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(authProvider).profile;
      if (profile != null) {
        ref.read(requestsProvider.notifier).fetchCustomerRequests(profile.id);
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final servicesState = ref.watch(servicesProvider);
    final requestsState = ref.watch(requestsProvider);

    final customerName =
        authState.profile?.fullName.split(' ')[0] ?? 'Customer';
    final activeReq = requestsState.activeRequest;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (authState.profile != null) {
              await ref
                  .read(requestsProvider.notifier)
                  .fetchCustomerRequests(authState.profile!.id);
            }
            await ref.read(servicesProvider.notifier).fetchServices();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, $customerName 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'What service do you need today?',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => context.push('/profile'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            customerName.isNotEmpty
                                ? customerName[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Search Bar
                TextField(
                  onChanged: (val) {
                    ref.read(servicesProvider.notifier).setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.searchService,
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textMuted, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Active Request Section
                const Text(
                  'Active Request',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),

                if (activeReq != null)
                  InkWell(
                    onTap: () =>
                        context.push('/request-details', extra: activeReq),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
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
                                activeReq.requestId,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              StatusBadge(status: activeReq.status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            activeReq.service?.name ?? 'General Maintenance',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeReq.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14, color: Colors.white70),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormatter.formatDate(
                                        activeReq.preferredDate),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    AppStrings.trackRequest,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calendar_today_outlined,
                              color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No active requests',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Book a service whenever you need one.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/services'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Browse',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),

                // 4. Popular & Available Services Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Services',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/services'),
                      child: const Text('View All',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (servicesState.isLoading)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator()))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: servicesState.filteredServices.take(4).length,
                    itemBuilder: (context, index) {
                      final service = servicesState.filteredServices[index];
                      return InkWell(
                        onTap: () =>
                            context.push('/service-details', extra: service),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.build_rounded,
                                    color: AppColors.primary, size: 22),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    service.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          if (index == 1) context.push('/services');
          if (index == 2) context.push('/requests');
          if (index == 3) context.push('/profile');
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: AppStrings.navHome),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: AppStrings.navServices),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: AppStrings.navRequests),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: AppStrings.navProfile),
        ],
      ),
    );
  }
}
