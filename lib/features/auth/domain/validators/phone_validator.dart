/// Myanmar mobile number rules (pure Dart, no Flutter imports).
///
/// The user types the part after the fixed `+95` prefix. We strip spaces and
/// dashes and one leading `0`; what remains must be `9` followed by 7 to 9
/// digits. Example: `09254135592` → `+959254135592`.
abstract final class PhoneRules {
  static const countryCode = '+95';
  static final RegExp _separators = RegExp(r'[\s-]');
  static final RegExp _subscriber = RegExp(r'^9\d{7,9}$');
}

enum PhoneValidationError { empty, invalid }

/// Removes separators, a pasted `+95`/`95` country code and one leading `0`.
String stripPhoneInput(String raw) {
  var digits = raw.replaceAll(PhoneRules._separators, '');
  if (digits.startsWith(PhoneRules.countryCode)) {
    digits = digits.substring(PhoneRules.countryCode.length);
  }
  if (digits.startsWith('0')) digits = digits.substring(1);
  return digits;
}

/// Returns `null` when [raw] is a valid Myanmar mobile number.
PhoneValidationError? validatePhone(String raw) {
  if (raw.trim().isEmpty) return PhoneValidationError.empty;
  final subscriber = stripPhoneInput(raw);
  if (!PhoneRules._subscriber.hasMatch(subscriber)) {
    return PhoneValidationError.invalid;
  }
  return null;
}

/// E.164 form (`+959254135592`), or `null` if [raw] is invalid.
String? normalizePhone(String raw) => validatePhone(raw) == null
    ? '${PhoneRules.countryCode}${stripPhoneInput(raw)}'
    : null;
