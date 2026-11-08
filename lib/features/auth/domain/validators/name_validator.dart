import 'package:characters/characters.dart';

/// Name rules: letters (any script, Myanmar included) and spaces, no digits.
abstract final class NameRules {
  static const maxLength = 50;

  /// `\p{L}` letters plus `\p{M}` combining marks: Myanmar vowels, medials
  /// and the virama are marks, so they must be allowed for Burmese names.
  /// Digits (`\p{N}`, which includes Myanmar ၀-၉) and punctuation are not.
  static final RegExp _allowed = RegExp(r'^[\p{L}\p{M} ]+$', unicode: true);
}

enum NameValidationError { required, tooLong, invalidCharacters }

/// First name: required, 1–50 user-perceived characters after trimming.
NameValidationError? validateFirstName(String raw) {
  if (raw.trim().isEmpty) return NameValidationError.required;
  return _validateCharacters(raw.trim());
}

/// Last name: optional (many Myanmar names have none), same character rules.
NameValidationError? validateLastName(String raw) {
  if (raw.trim().isEmpty) return null;
  return _validateCharacters(raw.trim());
}

/// Length is counted in grapheme clusters, so `မြင့်` counts as the
/// characters a person sees, not its UTF-16 code units.
NameValidationError? _validateCharacters(String trimmed) {
  if (trimmed.characters.length > NameRules.maxLength) {
    return NameValidationError.tooLong;
  }
  if (!NameRules._allowed.hasMatch(trimmed)) {
    return NameValidationError.invalidCharacters;
  }
  return null;
}
