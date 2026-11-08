import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/auth/domain/validators/otp_validator.dart';

void main() {
  group('isOtpComplete', () {
    test('is true for exactly six digits', () {
      expect(isOtpComplete('123456'), isTrue);
    });

    test('is false for fewer than six digits', () {
      expect(isOtpComplete('12345'), isFalse);
    });

    test('is false when a non-digit is present', () {
      expect(isOtpComplete('12345a'), isFalse);
    });
  });

  group('sanitizeOtpInput', () {
    test('keeps digits from a pasted SMS snippet', () {
      expect(sanitizeOtpInput('Code: 123-456'), '123456');
    });

    test('truncates input longer than six digits', () {
      expect(sanitizeOtpInput('12345678'), '123456');
    });
  });

  test('locks after three wrong attempts', () {
    expect(OtpRules.maxWrongAttempts, 3);
  });
}
