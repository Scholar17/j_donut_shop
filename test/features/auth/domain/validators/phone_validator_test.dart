import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/auth/domain/validators/phone_validator.dart';

void main() {
  group('validatePhone', () {
    test('accepts the reference number with a leading 0', () {
      expect(validatePhone('09254135592'), isNull);
    });

    test('accepts a number without the leading 0', () {
      expect(validatePhone('9254135592'), isNull);
    });

    test('ignores spaces and dashes', () {
      expect(validatePhone('09 254-135 592'), isNull);
    });

    test('accepts the shortest subscriber number (9 + 7 digits)', () {
      expect(validatePhone('91234567'), isNull);
    });

    test('accepts the longest subscriber number (9 + 9 digits)', () {
      expect(validatePhone('9123456789'), isNull);
    });

    test('rejects 9 followed by only 6 digits', () {
      expect(validatePhone('9123456'), PhoneValidationError.invalid);
    });

    test('rejects 9 followed by 10 digits', () {
      expect(validatePhone('91234567890'), PhoneValidationError.invalid);
    });

    test('rejects numbers that do not start with 9 after stripping', () {
      expect(validatePhone('08254135592'), PhoneValidationError.invalid);
    });

    test('strips only one leading 0', () {
      expect(validatePhone('009254135592'), PhoneValidationError.invalid);
    });

    test('rejects letters', () {
      expect(validatePhone('09abc135592'), PhoneValidationError.invalid);
    });

    test('reports empty input separately', () {
      expect(validatePhone('   '), PhoneValidationError.empty);
    });

    test('tolerates a pasted +95 country code', () {
      expect(validatePhone('+95 9254135592'), isNull);
    });
  });

  group('normalizePhone', () {
    test('converts 09254135592 to +959254135592', () {
      expect(normalizePhone('09254135592'), '+959254135592');
    });

    test('returns null for an invalid number', () {
      expect(normalizePhone('12345'), isNull);
    });
  });
}
