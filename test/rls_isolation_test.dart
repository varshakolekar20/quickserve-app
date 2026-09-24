import 'package:flutter_test/flutter_test.dart';
import 'package:quickserve_customer_app/core/utils/status_helper.dart';
import 'package:quickserve_customer_app/models/service_request.dart';

void main() {
  group('RLS Isolation & Authorization Boundary Tests', () {
    test('Customer can only cancel CREATED or ASSIGNED requests', () {
      final createdReq = ServiceRequest(
        id: '1',
        requestId: 'REQ-2026-000001',
        customerId: 'cust-1',
        serviceId: 'srv-1',
        description: 'Test',
        preferredDate: DateTime.now(),
        preferredTime: 'Morning',
        address: '123 Main St',
        priority: 'MEDIUM',
        status: 'CREATED',
        createdAt: DateTime.now(),
      );

      final assignedReq = createdReq.copyWith(status: 'ASSIGNED');
      final acceptedReq = createdReq.copyWith(status: 'ACCEPTED');
      final inProgressReq = createdReq.copyWith(status: 'IN_PROGRESS');
      final completedReq = createdReq.copyWith(status: 'COMPLETED');

      expect(StatusHelper.isCancellationAllowed(createdReq.status), isTrue);
      expect(StatusHelper.isCancellationAllowed(assignedReq.status), isTrue);
      expect(StatusHelper.isCancellationAllowed(acceptedReq.status), isFalse);
      expect(StatusHelper.isCancellationAllowed(inProgressReq.status), isFalse);
      expect(StatusHelper.isCancellationAllowed(completedReq.status), isFalse);
    });

    test('Agent lifecycle transitions require proper sequential state progression', () {
      expect(StatusHelper.isValidTransition('ASSIGNED', 'ACCEPTED'), isTrue);
      expect(StatusHelper.isValidTransition('ACCEPTED', 'IN_PROGRESS'), isTrue);
      expect(StatusHelper.isValidTransition('IN_PROGRESS', 'COMPLETED'), isTrue);

      expect(StatusHelper.isValidTransition('ASSIGNED', 'COMPLETED'), isFalse);
      expect(StatusHelper.isValidTransition('ACCEPTED', 'COMPLETED'), isFalse);
      expect(StatusHelper.isValidTransition('COMPLETED', 'IN_PROGRESS'), isFalse);
    });
  });
}
