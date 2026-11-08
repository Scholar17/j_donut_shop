import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/features/auth/domain/validators/name_validator.dart';

void main() {
  group('validateFirstName', () {
    test('accepts a Latin name with a space', () {
      expect(validateFirstName('Ye Min'), isNull);
    });

    test('accepts a Myanmar-script name with combining marks', () {
      expect(validateFirstName('မောင် မြင့်'), isNull);
    });

    test('trims surrounding whitespace before checking', () {
      expect(validateFirstName('  Hania  '), isNull);
    });

    test('requires a value', () {
      expect(validateFirstName('   '), NameValidationError.required);
    });

    test('rejects ASCII digits', () {
      expect(
        validateFirstName('Ye Min 2'),
        NameValidationError.invalidCharacters,
      );
    });

    test('rejects Myanmar digits', () {
      expect(
        validateFirstName('မောင်၂'),
        NameValidationError.invalidCharacters,
      );
    });

    test('rejects punctuation', () {
      expect(
        validateFirstName('Ye.Min'),
        NameValidationError.invalidCharacters,
      );
    });

    test('accepts exactly 50 characters', () {
      expect(validateFirstName('a' * NameRules.maxLength), isNull);
    });

    test('rejects 51 characters', () {
      expect(
        validateFirstName('a' * (NameRules.maxLength + 1)),
        NameValidationError.tooLong,
      );
    });

    test('ignores trailing spaces when counting length', () {
      expect(validateFirstName('${'a' * NameRules.maxLength}   '), isNull);
    });
  });

  group('validateLastName', () {
    test('is optional', () {
      expect(validateLastName(''), isNull);
    });

    test('applies the same character rules when given', () {
      expect(validateLastName('Win9'), NameValidationError.invalidCharacters);
    });
  });
}
