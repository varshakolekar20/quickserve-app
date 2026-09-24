import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/service_request.dart';
import '../../../models/service_item.dart';
import '../../../models/status_history.dart';
import '../../../models/user_profile.dart';
import '../../../services/supabase_customer_service.dart';
import '../../../core/utils/status_helper.dart';

class RequestsState {
  final List<ServiceRequest> requests;
  final List<StatusHistory> currentHistory;
  final ServiceRequest? activeRequest;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String filter; // 'ALL', 'ACTIVE', 'HISTORY', 'CREATED', 'ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'

  const RequestsState({
    this.requests = const [],
    this.currentHistory = const [],
    this.activeRequest,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.filter = 'ALL',
  });

  List<ServiceRequest> get activeRequests =>
      requests.where((r) => r.status != 'COMPLETED' && r.status != 'CANCELLED').toList();

  List<ServiceRequest> get historyRequests =>
      requests.where((r) => r.status == 'COMPLETED' || r.status == 'CANCELLED').toList();

  List<ServiceRequest> get filteredRequests {
    if (filter == 'ALL') return requests;
    if (filter == 'ACTIVE') return activeRequests;
    if (filter == 'HISTORY') return historyRequests;
    return requests.where((r) => r.status.toUpperCase() == filter).toList();
  }

  RequestsState copyWith({
    List<ServiceRequest>? requests,
    List<StatusHistory>? currentHistory,
    ServiceRequest? activeRequest,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? filter,
  }) {
    return RequestsState(
      requests: requests ?? this.requests,
      currentHistory: currentHistory ?? this.currentHistory,
      activeRequest: activeRequest ?? this.activeRequest,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  final SupabaseCustomerService _service = SupabaseCustomerService.instance;
  RealtimeChannel? _subscription;

  RequestsNotifier() : super(const RequestsState()) {
    _initMockIfAvailable();
  }

  void _initMockIfAvailable() {
    if (_service.isMockMode && state.requests.isEmpty) {
      final now = DateTime.now();
      final acService = ServiceItem(
        id: '11111111-1111-1111-1111-111111111101',
        name: 'AC Servicing',
        description: 'Deep filter cleaning & refrigerant diagnostic',
        icon: 'ac_unit',
      );
      final plumbing = ServiceItem(
        id: '11111111-1111-1111-1111-111111111102',
        name: 'Plumbing',
        description: 'Leak repair and pipe unclogging',
        icon: 'plumbing',
      );
      final electrical = ServiceItem(
        id: '11111111-1111-1111-1111-111111111103',
        name: 'Electrical',
        description: 'Short circuit and switch repair',
        icon: 'bolt',
      );

      final agentMarcus = UserProfile(
        id: '00000000-0000-0000-0000-000000000002',
        fullName: 'Marcus Vance',
        email: 'agent1@example.com',
        phone: '+1 (555) 014-9922',
        role: 'agent',
      );

      final mockList = [
        ServiceRequest(
          id: 'mock-1',
          requestId: 'REQ-2026-000001',
          customerId: '00000000-0000-0000-0000-000000000004',
          serviceId: electrical.id,
          service: electrical,
          description: 'Main breaker tripping whenever the kitchen microwave is powered on.',
          preferredDate: now.add(const Duration(days: 1)),
          preferredTime: '10:00 AM - 12:00 PM',
          address: '742 Evergreen Terrace, Springfield',
          priority: 'HIGH',
          status: 'CREATED',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        ServiceRequest(
          id: 'mock-2',
          requestId: 'REQ-2026-000002',
          customerId: '00000000-0000-0000-0000-000000000004',
          serviceId: plumbing.id,
          service: plumbing,
          agentId: agentMarcus.id,
          agent: agentMarcus,
          description: 'Bathroom sink drain is clogged and water drains extremely slowly.',
          preferredDate: now.add(const Duration(days: 2)),
          preferredTime: '02:00 PM - 04:00 PM',
          address: '742 Evergreen Terrace, Springfield',
          priority: 'MEDIUM',
          status: 'ASSIGNED',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        ServiceRequest(
          id: 'mock-5',
          requestId: 'REQ-2026-000005',
          customerId: '00000000-0000-0000-0000-000000000004',
          serviceId: acService.id,
          service: acService,
          agentId: agentMarcus.id,
          agent: agentMarcus,
          description: 'Annual seasonal filter cleaning and coil wash.',
          preferredDate: now.subtract(const Duration(days: 4)),
          preferredTime: '03:00 PM - 05:00 PM',
          address: '742 Evergreen Terrace, Springfield',
          priority: 'LOW',
          status: 'COMPLETED',
          notes: 'Outdoor coil washed and filter mesh replaced.',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
      ];

      final active = mockList.firstWhere(
        (r) => r.status != 'COMPLETED' && r.status != 'CANCELLED',
        orElse: () => mockList.first,
      );

      state = state.copyWith(requests: mockList, activeRequest: active);
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter.toUpperCase());
  }

  Future<void> fetchCustomerRequests(String customerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (_service.isMockMode) {
        _initMockIfAvailable();
        state = state.copyWith(isLoading: false);
      } else {
        final list = await _service.fetchCustomerRequests(customerId);
        final active = list.firstWhere(
          (r) => r.status != 'COMPLETED' && r.status != 'CANCELLED',
          orElse: () => list.isNotEmpty ? list.first : null as dynamic,
        );

        state = state.copyWith(
          requests: list,
          activeRequest: active,
          isLoading: false,
        );

        // Setup realtime subscription
        _subscription?.unsubscribe();
        _subscription = _service.subscribeToCustomerRequests(customerId, () {
          fetchCustomerRequests(customerId);
        });
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load requests.');
    }
  }

  Future<ServiceRequest?> createRequest({
    required String customerId,
    required String serviceId,
    required String description,
    required DateTime preferredDate,
    required String preferredTime,
    required String address,
    required String priority,
    ServiceItem? serviceItem,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final created = await _service.createRequest(
        customerId: customerId,
        serviceId: serviceId,
        description: description,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        address: address,
        priority: priority,
      );

      final populated = ServiceRequest(
        id: created.id,
        requestId: created.requestId,
        customerId: customerId,
        serviceId: serviceId,
        description: description,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        address: address,
        priority: priority,
        status: 'CREATED',
        createdAt: DateTime.now(),
        service: serviceItem ?? created.service,
      );

      final updatedList = [populated, ...state.requests];
      state = state.copyWith(
        requests: updatedList,
        activeRequest: populated,
        isSubmitting: false,
      );

      return populated;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create request. Please try again.',
      );
      return null;
    }
  }

  Future<bool> cancelRequest(String requestId) async {
    final idx = state.requests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;

    final target = state.requests[idx];
    if (!StatusHelper.isCancellationAllowed(target.status)) {
      state = state.copyWith(errorMessage: 'Only CREATED or ASSIGNED requests can be cancelled.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await _service.cancelRequest(requestId);
      final updatedList = [...state.requests];
      updatedList[idx] = target.copyWith(status: 'CANCELLED');

      state = state.copyWith(
        requests: updatedList,
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Failed to cancel request.');
      return false;
    }
  }

  Future<void> fetchHistory(String requestId) async {
    try {
      if (_service.isMockMode) {
        final now = DateTime.now();
        final history = [
          StatusHistory(
            id: 'h-1',
            requestId: requestId,
            oldStatus: null,
            newStatus: 'CREATED',
            note: 'Service request created by customer',
            createdAt: now.subtract(const Duration(hours: 12)),
            changerName: 'Customer',
            changerRole: 'customer',
          ),
          StatusHistory(
            id: 'h-2',
            requestId: requestId,
            oldStatus: 'CREATED',
            newStatus: 'ASSIGNED',
            note: 'Assigned to field technician Marcus Vance',
            createdAt: now.subtract(const Duration(hours: 6)),
            changerName: 'Admin Dispatcher',
            changerRole: 'admin',
          ),
        ];
        state = state.copyWith(currentHistory: history);
      } else {
        final history = await _service.fetchRequestHistory(requestId);
        state = state.copyWith(currentHistory: history);
      }
    } catch (e) {
      // History error
    }
  }

  Future<void> fetchAgentRequests(String agentId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (_service.isMockMode) {
        _initMockIfAvailable();
        state = state.copyWith(isLoading: false);
      } else {
        final list = await _service.fetchAgentRequests(agentId);
        state = state.copyWith(
          requests: list,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load technician jobs.');
    }
  }

  Future<bool> updateAgentStatus({
    required String requestId,
    required String targetStatus,
    String? note,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      if (_service.isMockMode) {
        final updated = state.requests.map((r) {
          if (r.id == requestId) {
            return r.copyWith(status: targetStatus, notes: note ?? r.notes);
          }
          return r;
        }).toList();
        state = state.copyWith(requests: updated, isSubmitting: false);
        return true;
      }

      await _service.updateAgentStatus(
        requestId: requestId,
        targetStatus: targetStatus,
        note: note,
      );

      final updated = state.requests.map((r) {
        if (r.id == requestId) {
          return r.copyWith(status: targetStatus, notes: note ?? r.notes);
        }
        return r;
      }).toList();

      state = state.copyWith(requests: updated, isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Failed to update job status.');
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}

final requestsProvider = StateNotifierProvider<RequestsNotifier, RequestsState>((ref) {
  return RequestsNotifier();
});
