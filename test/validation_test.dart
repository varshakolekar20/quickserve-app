import 'package:flutter_test/flutter_test.dart';
import 'package:quickserve_customer_app/core/utils/validators.dart';

void main() {
  group('Validators Test Suite', () {
    test('Email validator accepts valid emails and rejects invalid ones', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(
          Validators.validateEmail('customer.service@sub.domain.org'), isNull);

      expect(Validators.validateEmail(''), equals('Email address is required'));
      expect(
          Validators.validateEmail(null), equals('Email address is required'));
      expect(Validators.validateEmail('plainaddress'),
          equals('Please enter a valid email address'));
      expect(Validators.validateEmail('user@com'),
          equals('Please enter a valid email address'));
    });

    test('Password validator enforces minimum length', () {
      expect(Validators.validatePassword('Password123!'), isNull);
      expect(Validators.validatePassword('123456'), isNull);

      expect(Validators.validatePassword(''), equals('Password is required'));
      expect(Validators.validatePassword(null), equals('Password is required'));
      expect(Validators.validatePassword('12345'),
          equals('Password must be at least 6 characters long'));
    });

    test('Confirm password validator verifies matching passwords', () {
      expect(
          Validators.validateConfirmPassword('Secret123', 'Secret123'), isNull);
      expect(
          Validators.validateConfirmPassword('Secret123', 'DifferentPassword'),
          equals('Passwords do not match'));
      expect(Validators.validateConfirmPassword('', 'Secret123'),
          equals('Please confirm your password'));
    });

    test('Required field validator checks for empty or whitespace-only inputs',
        () {
      expect(Validators.validateRequired('742 Evergreen Terrace', 'Address'),
          isNull);
      expect(Validators.validateRequired('', 'Address'),
          equals('Address is required'));
      expect(Validators.validateRequired('   ', 'Description'),
          equals('Description is required'));
      expect(Validators.validateRequired(null, 'Full name'),
          equals('Full name is required'));
    });

    test(
        'Phone validator validates acceptable international and standard phone formats',
        () {
      expect(Validators.validatePhone('+1 (555) 012-3456'), isNull);
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone('+91 98765 43210'), isNull);

      expect(Validators.validatePhone(''), equals('Phone number is required'));
      expect(Validators.validatePhone('abc'),
          equals('Please enter a valid phone number'));
      expect(Validators.validatePhone('123'),
          equals('Please enter a valid phone number'));
    });
  });
}
