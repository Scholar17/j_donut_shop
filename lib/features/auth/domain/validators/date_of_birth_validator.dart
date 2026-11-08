/// Date-of-birth rules. `today` is injected so tests are deterministic.
abstract final class DateOfBirthRules {
  /// Youngest age allowed to register.
  static const minimumAge = 13;

  /// Earliest year accepted, to reject typos like `0198`.
  static const earliestYear = 1900;
}

enum DateOfBirthError { incomplete, invalidDate, inFuture, tooYoung }

/// Validates month/day/year parts; `null` parts mean "not entered yet".
DateOfBirthError? validateDateOfBirth({
  required int? month,
  required int? day,
  required int? year,
  required DateTime today,
}) {
  if (month == null || day == null || year == null) {
    return DateOfBirthError.incomplete;
  }
  if (!isRealCalendarDate(year: year, month: month, day: day) ||
      year < DateOfBirthRules.earliestYear) {
    return DateOfBirthError.invalidDate;
  }
  final birth = DateTime(year, month, day);
  final dateOnlyToday = DateTime(today.year, today.month, today.day);
  if (birth.isAfter(dateOnlyToday)) return DateOfBirthError.inFuture;
  if (ageOn(birth, dateOnlyToday) < DateOfBirthRules.minimumAge) {
    return DateOfBirthError.tooYoung;
  }
  return null;
}

/// Rejects dates like 31 April or 29 February in a non-leap year.
///
/// `DateTime` silently rolls overflow forward (31 April → 1 May), so we build
/// the date and check that nothing rolled.
bool isRealCalendarDate({
  required int year,
  required int month,
  required int day,
}) {
  if (month < 1 || month > 12 || day < 1) return false;
  final date = DateTime(year, month, day);
  return date.year == year && date.month == month && date.day == day;
}

/// Whole years between [birth] and [onDate]; birthday counts on the day.
int ageOn(DateTime birth, DateTime onDate) {
  var age = onDate.year - birth.year;
  final hadBirthdayThisYear = onDate.month > birth.month ||
      (onDate.month == birth.month && onDate.day >= birth.day);
  if (!hadBirthdayThisYear) age--;
  return age;
}
