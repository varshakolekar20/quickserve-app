import 'package:flutter_test/flutter_test.dart';
import 'package:quickserve_customer_app/core/utils/status_helper.dart';

void main() {
  group('Request Lifecycle & State Machine Tests', () {
    test('Valid lifecycle transitions succeed', () {
      expect(StatusHelper.isValidTransition('CREATED', 'ASSIGNED'), isTrue);
      expect(StatusHelper.isValidTransition('ASSIGNED', 'ACCEPTED'), isTrue);
      expect(StatusHelper.isValidTransition('ACCEPTED', 'IN_PROGRESS'), isTrue);
      expect(
          StatusHelper.isValidTransition('IN_PROGRESS', 'COMPLETED'), isTrue);
    });

    test('Cancellation transitions succeed for eligible initial statuses', () {
      expect(StatusHelper.isValidTransition('CREATED', 'CANCELLED'), isTrue);
      expect(StatusHelper.isValidTransition('ASSIGNED', 'CANCELLED'), isTrue);
    });

    test('Cancellation is forbidden once work is accepted or in progress', () {
      expect(StatusHelper.isValidTransition('ACCEPTED', 'CANCELLED'), isFalse);
      expect(
          StatusHelper.isValidTransition('IN_PROGRESS', 'CANCELLED'), isFalse);
      expect(StatusHelper.isValidTransition('COMPLETED', 'CANCELLED'), isFalse);
    });

    test('Illegal status jumps and backwards transitions are strictly rejected',
        () {
      expect(StatusHelper.isValidTransition('CREATED', 'IN_PROGRESS'), isFalse);
      expect(StatusHelper.isValidTransition('CREATED', 'COMPLETED'), isFalse);
      expect(StatusHelper.isValidTransition('ASSIGNED', 'COMPLETED'), isFalse);
      expect(StatusHelper.isValidTransition('ACCEPTED', 'COMPLETED'), isFalse);
      expect(
          StatusHelper.isValidTransition('COMPLETED', 'IN_PROGRESS'), isFalse);
      expect(StatusHelper.isValidTransition('COMPLETED', 'CREATED'), isFalse);
      expect(StatusHelper.isValidTransition('CANCELLED', 'CREATED'), isFalse);
      expect(StatusHelper.isValidTransition('CANCELLED', 'ASSIGNED'), isFalse);
    });

    test('isCancellationAllowed checks boundary conditions correctly', () {
      expect(StatusHelper.isCancellationAllowed('CREATED'), isTrue);
      expect(StatusHelper.isCancellationAllowed('ASSIGNED'), isTrue);
      expect(StatusHelper.isCancellationAllowed('ACCEPTED'), isFalse);
      expect(StatusHelper.isCancellationAllowed('IN_PROGRESS'), isFalse);
      expect(StatusHelper.isCancellationAllowed('COMPLETED'), isFalse);
      expect(StatusHelper.isCancellationAllowed('CANCELLED'), isFalse);
    });
  });
}
