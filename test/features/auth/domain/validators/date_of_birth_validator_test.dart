import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/auth/domain/validators/date_of_birth_validator.dart';

void main() {
  final today = DateTime(2026, 11, 8);

  DateOfBirthError? validate(int? month, int? day, int? year) =>
      validateDateOfBirth(month: month, day: day, year: year, today: today);

  group('validateDateOfBirth', () {
    test('accepts the reference date May 1, 1980', () {
      expect(validate(5, 1, 1980), isNull);
    });

    test('reports missing parts as incomplete', () {
      expect(validate(5, null, 1980), DateOfBirthError.incomplete);
    });

    test('rejects 31 April', () {
      expect(validate(4, 31, 1990), DateOfBirthError.invalidDate);
    });

    test('accepts 29 February in a leap year', () {
      expect(validate(2, 29, 2000), isNull);
    });

    test('rejects 29 February in a non-leap year', () {
      expect(validate(2, 29, 1999), DateOfBirthError.invalidDate);
    });

    test('rejects 29 February 1900 (century, not a leap year)', () {
      expect(validate(2, 29, 1900), DateOfBirthError.invalidDate);
    });

    test('rejects month 13', () {
      expect(validate(13, 1, 1990), DateOfBirthError.invalidDate);
    });

    test('rejects a date in the future', () {
      expect(validate(1, 1, 2027), DateOfBirthError.inFuture);
    });

    test('accepts someone turning 13 today', () {
      expect(validate(11, 8, 2013), isNull);
    });

    test('rejects someone turning 13 tomorrow', () {
      expect(validate(11, 9, 2013), DateOfBirthError.tooYoung);
    });

    test('uses the named minimum age constant', () {
      expect(DateOfBirthRules.minimumAge, 13);
    });
  });

  group('ageOn', () {
    test('does not count the birthday before it happens', () {
      expect(ageOn(DateTime(2000, 12, 1), DateTime(2026, 11, 30)), 25);
    });
  });
}
