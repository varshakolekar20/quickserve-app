import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/service_item.dart';
import '../../../services/supabase_customer_service.dart';

class ServicesState {
  final List<ServiceItem> services;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  List<ServiceItem> get filteredServices {
    if (searchQuery.trim().isEmpty) return services;
    final q = searchQuery.toLowerCase();
    return services.where((s) {
      return s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q);
    }).toList();
  }

  ServicesState copyWith({
    List<ServiceItem>? services,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ServicesNotifier extends StateNotifier<ServicesState> {
  final SupabaseCustomerService _service = SupabaseCustomerService.instance;

  ServicesNotifier() : super(const ServicesState()) {
    fetchServices();
  }

  Future<void> fetchServices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _service.fetchServices();
      state = state.copyWith(services: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Could not load service catalog.');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  ServiceItem? getServiceById(String id) {
    try {
      return state.services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  return ServicesNotifier();
});
