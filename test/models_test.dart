import 'package:flutter_test/flutter_test.dart';
import 'package:quickserve_customer_app/models/user_profile.dart';
import 'package:quickserve_customer_app/models/service_item.dart';
import 'package:quickserve_customer_app/models/service_request.dart';
import 'package:quickserve_customer_app/models/status_history.dart';

void main() {
  group('Models Serialization & Logic Tests', () {
    test('UserProfile JSON serialization and role checks', () {
      final json = {
        'id': 'usr-001',
        'full_name': 'Varsha Kolekar',
        'email': 'customer@example.com',
        'phone': '+1 (555) 012-3456',
        'role': 'customer',
        'is_active': true,
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, equals('usr-001'));
      expect(profile.fullName, equals('Varsha Kolekar'));
      expect(profile.isCustomer, isTrue);
      expect(profile.isAgent, isFalse);
      expect(profile.isAdmin, isFalse);

      final outJson = profile.toJson();
      expect(outJson['email'], equals('customer@example.com'));
      expect(outJson['role'], equals('customer'));
    });

    test('ServiceRequest JSON parsing and cancellation property', () {
      final json = {
        'id': 'req-uuid-1',
        'request_id': 'REQ-2026-000123',
        'customer_id': 'cust-1',
        'service_id': 'srv-1',
        'description': 'Leaking sink',
        'preferred_date': '2026-09-20',
        'preferred_time': '10:00 AM - 12:00 PM',
        'address': '742 Evergreen Terrace',
        'priority': 'HIGH',
        'status': 'CREATED',
        'created_at': '2026-09-18T10:00:00Z',
      };

      final request = ServiceRequest.fromJson(json);
      expect(request.requestId, equals('REQ-2026-000123'));
      expect(request.priority, equals('HIGH'));
      expect(request.status, equals('CREATED'));
      expect(request.canCancel, isTrue);

      final inProgress = request.copyWith(status: 'IN_PROGRESS');
      expect(inProgress.status, equals('IN_PROGRESS'));
      expect(inProgress.canCancel, isFalse);
    });

    test('ServiceItem JSON parsing', () {
      final json = {
        'id': 'srv-ac',
        'name': 'AC Servicing',
        'description': 'Filter cleaning and coolant charge',
        'icon': 'ac_unit',
        'is_active': true,
      };

      final service = ServiceItem.fromJson(json);
      expect(service.name, equals('AC Servicing'));
      expect(service.icon, equals('ac_unit'));
      expect(service.isActive, isTrue);
    });

    test('StatusHistory JSON parsing', () {
      final json = {
        'id': 'hist-1',
        'request_id': 'req-uuid-1',
        'old_status': 'CREATED',
        'new_status': 'ASSIGNED',
        'changed_by': 'admin-1',
        'note': 'Assigned to Marcus',
        'created_at': '2026-09-18T11:00:00Z',
        'changer': {
          'full_name': 'Admin Supervisor',
          'role': 'admin',
        },
      };

      final history = StatusHistory.fromJson(json);
      expect(history.oldStatus, equals('CREATED'));
      expect(history.newStatus, equals('ASSIGNED'));
      expect(history.changerName, equals('Admin Supervisor'));
      expect(history.changerRole, equals('admin'));
    });
  });
}
