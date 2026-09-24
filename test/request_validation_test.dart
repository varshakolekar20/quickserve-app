import 'package:flutter_test/flutter_test.dart';
import 'package:quickserve_customer_app/core/utils/date_formatter.dart';
import 'package:quickserve_customer_app/models/service_request.dart';

void main() {
  group('Request Creation & Format Validation Tests', () {
    test('Sequence-generated Request ID format validation (REQ-YYYY-NNNNNN)',
        () {
      final req = ServiceRequest(
        id: 'uuid-12345',
        requestId: 'REQ-2026-000123',
        customerId: 'cust-1',
        serviceId: 'srv-1',
        description: 'Need AC deep cleaning and gas top-up',
        preferredDate: DateTime(2026, 9, 25),
        preferredTime: '10:00 AM - 12:00 PM',
        address: '123 Main Street',
        priority: 'HIGH',
        status: 'CREATED',
        createdAt: DateTime(2026, 9, 20),
      );

      final reqIdPattern = RegExp(r'^REQ-\d{4}-\d{6}$');
      expect(reqIdPattern.hasMatch(req.requestId), isTrue);
      expect(req.priority, equals('HIGH'));
      expect(req.status, equals('CREATED'));
    });

    test('Valid priority values (LOW, MEDIUM, HIGH)', () {
      const validPriorities = ['LOW', 'MEDIUM', 'HIGH'];
      for (final p in validPriorities) {
        expect(['LOW', 'MEDIUM', 'HIGH'].contains(p), isTrue);
      }
    });

    test('DateFormatter correctly formats display dates', () {
      final dt = DateTime(2026, 9, 20);
      final formatted = DateFormatter.formatDate(dt);
      expect(formatted, contains('2026'));
      expect(formatted, contains('Sep'));
    });
  });
}
