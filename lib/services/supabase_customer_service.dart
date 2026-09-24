import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/service_item.dart';
import '../models/service_request.dart';
import '../models/status_history.dart';

class SupabaseCustomerService {
  static final SupabaseCustomerService instance = SupabaseCustomerService._internal();
  SupabaseCustomerService._internal();

  SupabaseClient? _client;

  // Supabase Credentials (configurable via --dart-define or environment)
  static const String defaultUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo-quickserve.supabase.co',
  );
  static const String defaultAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_quickserve_development',
  );

  bool _isMockMode = false;
  bool get isMockMode => _isMockMode;

  SupabaseClient get client {
    if (_client == null) {
      throw StateError('SupabaseCustomerService has not been initialized.');
    }
    return _client!;
  }

  Future<void> initialize({String? url, String? anonKey}) async {
    final targetUrl = url ?? defaultUrl;
    final targetKey = anonKey ?? defaultAnonKey;

    try {
      if (targetUrl.contains('demo-quickserve')) {
        _isMockMode = true;
        debugPrint('[QuickServe Customer App] Running in local demo/mock sandbox mode.');
      } else {
        await Supabase.initialize(
          url: targetUrl,
          anonKey: targetKey,
          debug: kDebugMode,
        );
        _client = Supabase.instance.client;
        _isMockMode = false;
        debugPrint('[QuickServe Customer App] Connected to live Supabase backend: $targetUrl');
      }
    } catch (e) {
      debugPrint('[QuickServe Customer App] Fallback to local mock mode: $e');
      _isMockMode = true;
    }
  }

  // Session & User getters
  User? get currentUser => _client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // ---------------------------------------------------------------------------
  // AUTHENTICATION (CUSTOMER EXCLUSIVE)
  // ---------------------------------------------------------------------------
  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return null;
    }
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse?> signUpCustomer({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return null;
    }
    // Strictly assign customer role at creation time
    return await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'role': 'customer',
      },
    );
  }

  Future<void> signOut() async {
    if (!_isMockMode && _client != null) {
      await client.auth.signOut();
    }
  }

  Future<void> resetPassword(String email) async {
    if (!_isMockMode && _client != null) {
      await client.auth.resetPasswordForEmail(email.trim());
    }
  }

  // ---------------------------------------------------------------------------
  // CUSTOMER PROFILES (RLS Enforced)
  // ---------------------------------------------------------------------------
  Future<UserProfile?> fetchProfile(String userId) async {
    if (_isMockMode || _client == null) return null;
    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('[QuickServe Customer App] Profile fetch error: $e');
      return null;
    }
  }

  Future<UserProfile?> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
  }) async {
    if (_isMockMode || _client == null) return null;
    try {
      final data = await client
          .from('profiles')
          .update({
            'full_name': fullName.trim(),
            'phone': phone.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('[QuickServe Customer App] Profile update error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SERVICES CATALOG (Public Read)
  // ---------------------------------------------------------------------------
  Future<List<ServiceItem>> fetchServices() async {
    if (_isMockMode || _client == null) {
      return [
        ServiceItem(
          id: '11111111-1111-1111-1111-111111111101',
          name: 'AC Servicing',
          description: 'Comprehensive cooling diagnostics, deep filter cleaning, refrigerant leak test.',
          icon: 'ac_unit',
          isActive: true,
        ),
        ServiceItem(
          id: '11111111-1111-1111-1111-111111111102',
          name: 'Plumbing',
          description: 'Leak detection, pipe repair, faucet replacement, drainage unclogging.',
          icon: 'plumbing',
          isActive: true,
        ),
        ServiceItem(
          id: '11111111-1111-1111-1111-111111111103',
          name: 'Electrical',
          description: 'Short circuit troubleshooting, wiring inspection, breaker panel upgrade.',
          icon: 'bolt',
          isActive: true,
        ),
        ServiceItem(
          id: '11111111-1111-1111-1111-111111111104',
          name: 'Cleaning',
          description: 'Deep residential cleaning, kitchen sanitation, bathroom scrub, upholstery.',
          icon: 'cleaning_services',
          isActive: true,
        ),
      ];
    }
    try {
      final response = await client
          .from('services')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);
      return (response as List).map((json) => ServiceItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[QuickServe Customer App] Fetch services error: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // SERVICE REQUESTS (Customer Isolated via RLS)
  // ---------------------------------------------------------------------------
  Future<List<ServiceRequest>> fetchCustomerRequests(String customerId) async {
    if (_isMockMode || _client == null) {
      return [];
    }
    try {
      final response = await client
          .from('service_requests')
          .select('''
            *,
            service:services(*),
            agent:profiles!service_requests_agent_id_fkey(*)
          ''')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return (response as List).map((json) => ServiceRequest.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[QuickServe Customer App] Fetch requests error: $e');
      return [];
    }
  }

  Future<ServiceRequest> createRequest({
    required String customerId,
    required String serviceId,
    required String description,
    required DateTime preferredDate,
    required String preferredTime,
    required String address,
    required String priority,
  }) async {
    if (_isMockMode || _client == null) {
      final dummySeq = DateTime.now().millisecondsSinceEpoch % 100000;
      final dummyReqId = 'REQ-2026-${dummySeq.toString().padLeft(6, '0')}';
      return ServiceRequest(
        id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        requestId: dummyReqId,
        customerId: customerId,
        serviceId: serviceId,
        description: description,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        address: address,
        priority: priority,
        status: 'CREATED',
        createdAt: DateTime.now(),
      );
    }
    try {
      final payload = {
        'customer_id': customerId,
        'service_id': serviceId,
        'description': description.trim(),
        'preferred_date': preferredDate.toIso8601String().split('T')[0],
        'preferred_time': preferredTime.trim(),
        'address': address.trim(),
        'priority': priority.toUpperCase(),
        'status': 'CREATED',
      };

      final response = await client
          .from('service_requests')
          .insert(payload)
          .select('''
            *,
            service:services(*),
            agent:profiles!service_requests_agent_id_fkey(*)
          ''')
          .single();
      return ServiceRequest.fromJson(response);
    } catch (e) {
      debugPrint('[QuickServe Customer App] Create request error: $e');
      rethrow;
    }
  }

  Future<void> cancelRequest(String requestId) async {
    if (_isMockMode || _client == null) return;
    try {
      await client
          .from('service_requests')
          .update({'status': 'CANCELLED'})
          .eq('id', requestId);
    } catch (e) {
      debugPrint('[QuickServe Customer App] Cancel request error: $e');
      rethrow;
    }
  }

  Future<List<StatusHistory>> fetchRequestHistory(String requestId) async {
    if (_isMockMode || _client == null) return [];
    try {
      final response = await client
          .from('request_status_history')
          .select('''
            *,
            changer:profiles!request_status_history_changed_by_fkey(full_name, role)
          ''')
          .eq('request_id', requestId)
          .order('created_at', ascending: true);
      return (response as List).map((json) => StatusHistory.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[QuickServe Customer App] History fetch error: $e');
      return [];
    }
  }

  // Real-time subscription to status changes
  RealtimeChannel? subscribeToCustomerRequests(String customerId, VoidCallback onUpdate) {
    if (_isMockMode || _client == null) return null;
    return client
        .channel('public:service_requests:customer_id=eq.$customerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'service_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: customerId,
          ),
          callback: (payload) {
            onUpdate();
          },
        )
        .subscribe();
  }

  // ---------------------------------------------------------------------------
  // AGENT CAPABILITIES (Agent Role Enforced via RLS)
  // ---------------------------------------------------------------------------
  Future<List<ServiceRequest>> fetchAgentRequests(String agentId) async {
    if (_isMockMode || _client == null) {
      return [];
    }
    try {
      final response = await client
          .from('service_requests')
          .select('''
            *,
            service:services(*),
            customer:profiles!service_requests_customer_id_fkey(*)
          ''')
          .eq('agent_id', agentId)
          .order('created_at', ascending: false);
      return (response as List).map((json) => ServiceRequest.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[QuickServe Customer App] Fetch agent requests error: $e');
      return [];
    }
  }

  Future<void> updateAgentStatus({
    required String requestId,
    required String targetStatus,
    String? note,
  }) async {
    if (_isMockMode || _client == null) return;
    try {
      final payload = <String, dynamic>{
        'status': targetStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (note != null && note.isNotEmpty) {
        payload['notes'] = note;
      }
      await client
          .from('service_requests')
          .update(payload)
          .eq('id', requestId);
    } catch (e) {
      debugPrint('[QuickServe Customer App] Update agent status error: $e');
      rethrow;
    }
  }
}
