import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/empty_state_widget.dart';
import '../providers/services_provider.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Service Marketplace',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Input Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => ref.read(servicesProvider.notifier).setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search services, maintenance & repairs...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ),

          // Services Catalog Grid
          Expanded(
            child: servicesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => ref.read(servicesProvider.notifier).fetchServices(),
                    child: servicesState.filteredServices.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.search_off_rounded,
                            title: 'No Services Found',
                            message: 'No active service offerings match your search filter.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: servicesState.filteredServices.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final service = servicesState.filteredServices[index];

                              return Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.cardBorder),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.build_rounded, color: AppColors.primary, size: 28),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.name,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              const Row(
                                                children: [
                                                  Icon(Icons.verified_outlined, size: 14, color: AppColors.success),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Certified Technicians On-Call',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.success,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      service.description,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => context.push('/service-details', extra: service),
                                            child: const Text('View Details'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                            onPressed: () {
                                              context.push('/create-request', extra: {
                                                'serviceId': service.id,
                                                'serviceName': service.name,
                                              });
                                            },
                                            child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.push('/home');
          if (index == 2) context.push('/requests');
          if (index == 3) context.push('/profile');
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: AppStrings.navHome),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: AppStrings.navServices),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: AppStrings.navRequests),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: AppStrings.navProfile),
        ],
      ),
    );
  }
}
