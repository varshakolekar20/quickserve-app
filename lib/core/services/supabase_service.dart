import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import '../../models/service_item.dart';
import '../../models/service_request.dart';
import '../../models/status_history.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  SupabaseClient? _client;

  // Configuration
  static const String defaultUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yaqcsseiwvpayuafjuoh.supabase.co',
  );
  static const String defaultAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_anzMLxUqin--gtgxqOk-ng_-fWqiNtv',
  );

  bool _isMockMode = false;
  bool get isMockMode => _isMockMode;

  SupabaseClient get client {
    if (_client == null) {
      throw StateError(
          'SupabaseService has not been initialized. Call initialize() first.');
    }
    return _client!;
  }

  Future<void> initialize({String? url, String? anonKey}) async {
    final targetUrl = url ?? defaultUrl;
    final targetKey = anonKey ?? defaultAnonKey;

    try {
      if (targetUrl.contains('demo-quickserve')) {
        // Mock / offline development mode
        _isMockMode = true;
        debugPrint('[QuickServe] Running in local demo/mock fallback mode.');
      } else {
        await Supabase.initialize(
          url: targetUrl,
          anonKey: targetKey, // ignore: deprecated_member_use
          debug: kDebugMode,
        );
        _client = Supabase.instance.client;
        _isMockMode = false;
        debugPrint(
            '[QuickServe] Connected to live Supabase backend: $targetUrl');
      }
    } catch (e) {
      debugPrint('[QuickServe] Supabase init fallback to local mock store: $e');
      _isMockMode = true;
    }
  }

  // Current session & user
  User? get currentUser => _client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------
  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return null;
    }
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String role = 'customer',
  }) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return null;
    }
    return await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'role': role,
      },
    );
  }

  Future<void> signOut() async {
    if (!_isMockMode && _client != null) {
      await client.auth.signOut();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (!_isMockMode && _client != null) {
      await client.auth.resetPasswordForEmail(email.trim());
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // ---------------------------------------------------------------------------
  // USER PROFILES
  // ---------------------------------------------------------------------------
  Future<UserProfile?> fetchProfile(String userId) async {
    if (_isMockMode || _client == null) {
      return null;
    }
    try {
      final data =
          await client.from('profiles').select().eq('id', userId).maybeSingle();
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('[QuickServe] Error fetching profile: $e');
      return null;
    }
  }

  Future<UserProfile?> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
  }) async {
    if (_isMockMode || _client == null) {
      return null;
    }
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
      debugPrint('[QuickServe] Error updating profile: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // SERVICES CATALOG
  // ---------------------------------------------------------------------------
  Future<List<ServiceItem>> fetchServices() async {
    if (_isMockMode || _client == null) {
      return [
        ServiceItem(
          id: '11111111-1111-1111-1111-111111111101',
          name: 'AC Servicing',
          description:
              'Comprehensive cooling diagnostics, deep filter cleaning, refrigerant leak test.',
          icon: 'ac_unit',
          isActive: true,
        ),
        ServiceItem(
          id: '11111111-1111-1111-1111-111111111102',
          name: 'Plumbing',
          description:
              'Leak detection, pipe repair, faucet replacement, drainage unclogging.',
          icon: 'plumbing',
          isActive: true,
        ),
        ServiceItem(
          id: '11111111-1111-1111-1111-111111111103',
          name: 'Electrical',
          description:
              'Short circuit troubleshooting, wiring inspection, breaker panel upgrade.',
          icon: 'bolt',
          isActive: true,
        ),
        ServiceItem(
          id: '11111111-1111-1111-1111-111111111104',
          name: 'Cleaning',
          description:
              'Deep residential cleaning, kitchen sanitation, bathroom scrub, upholstery.',
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
      return (response as List)
          .map((json) => ServiceItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[QuickServe] Error fetching services: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // SERVICE REQUESTS
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
      return (response as List)
          .map((json) => ServiceRequest.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[QuickServe] Error fetching customer requests: $e');
      return [];
    }
  }

  Future<List<ServiceRequest>> fetchAgentRequests(String agentId) async {
    if (_isMockMode || _client == null) {
      return [];
    }
    try {
      final response = await client.from('service_requests').select('''
            *,
            service:services(*),
            customer:profiles!service_requests_customer_id_fkey(*)
          ''').eq('agent_id', agentId).order('created_at', ascending: false);
      return (response as List)
          .map((json) => ServiceRequest.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[QuickServe] Error fetching agent requests: $e');
      return [];
    }
  }

  Future<ServiceRequest> createServiceRequest({
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

      final response =
          await client.from('service_requests').insert(payload).select('''
            *,
            service:services(*),
            agent:profiles!service_requests_agent_id_fkey(*)
          ''').single();
      return ServiceRequest.fromJson(response);
    } catch (e) {
      debugPrint('[QuickServe] Error creating request: $e');
      rethrow;
    }
  }

  Future<void> cancelRequest(String requestId) async {
    if (_isMockMode || _client == null) {
      return;
    }
    try {
      await client
          .from('service_requests')
          .update({'status': 'CANCELLED'}).eq('id', requestId);
    } catch (e) {
      debugPrint('[QuickServe] Error cancelling request: $e');
      rethrow;
    }
  }

  Future<void> updateAgentRequestStatus({
    required String requestId,
    required String newStatus,
    String? note,
  }) async {
    if (_isMockMode || _client == null) {
      return;
    }
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
      };
      if (note != null && note.isNotEmpty) {
        updateData['notes'] = note;
      }
      await client
          .from('service_requests')
          .update(updateData)
          .eq('id', requestId);
    } catch (e) {
      debugPrint('[QuickServe] Error updating request status: $e');
      rethrow;
    }
  }

  Future<List<StatusHistory>> fetchRequestHistory(String requestId) async {
    if (_isMockMode || _client == null) {
      return [];
    }
    try {
      final response = await client.from('request_status_history').select('''
            *,
            changer:profiles!request_status_history_changed_by_fkey(full_name, role)
          ''').eq('request_id', requestId).order('created_at', ascending: true);
      return (response as List)
          .map((json) => StatusHistory.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[QuickServe] Error fetching history: $e');
      return [];
    }
  }
}
