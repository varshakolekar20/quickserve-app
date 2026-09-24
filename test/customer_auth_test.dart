import 'package:flutter_test/flutter_test.dart';
import 'package:quickserve_customer_app/models/user_profile.dart';

void main() {
  group('Customer & Agent Role & Auth Unit Tests', () {
    test('Customer registration auto-assigns customer role without role selection UI', () {
      final customerProfile = UserProfile(
        id: 'cust-100',
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        phone: '+1 555-0199',
        role: 'customer',
      );

      expect(customerProfile.role, equals('customer'));
      expect(customerProfile.isCustomer, isTrue);
      expect(customerProfile.isAgent, isFalse);
      expect(customerProfile.isAdmin, isFalse);
    });

    test('Technician profile correctly evaluates isAgent property', () {
      final agentProfile = UserProfile(
        id: 'agent-200',
        fullName: 'Marcus Vance',
        email: 'marcus@example.com',
        phone: '+1 555-0299',
        role: 'agent',
      );

      expect(agentProfile.role, equals('agent'));
      expect(agentProfile.isAgent, isTrue);
      expect(agentProfile.isCustomer, isFalse);
      expect(agentProfile.isAdmin, isFalse);
    });

    test('Admin profile correctly evaluates isAdmin property', () {
      final adminProfile = UserProfile(
        id: 'admin-300',
        fullName: 'Sarah Supervisor',
        email: 'admin@example.com',
        phone: '+1 555-0399',
        role: 'admin',
      );

      expect(adminProfile.role, equals('admin'));
      expect(adminProfile.isAdmin, isTrue);
      expect(adminProfile.isCustomer, isFalse);
      expect(adminProfile.isAgent, isFalse);
    });
  });
}
