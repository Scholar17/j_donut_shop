/// Typed, fail-fast access to decoded JSON maps.
///
/// Throws [FormatException] naming the bad field, so a malformed seed or
/// server payload becomes a typed failure instead of a silent wrong value.
extension JsonReader on Map<String, dynamic> {
  T read<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    throw FormatException(
      'Field "$key" should be $T but was ${value.runtimeType}',
    );
  }

  T? readOrNull<T>(String key) {
    final value = this[key];
    if (value == null || value is T) return value as T?;
    throw FormatException(
      'Field "$key" should be $T? but was ${value.runtimeType}',
    );
  }

  List<Map<String, dynamic>> readList(String key) =>
      read<List<dynamic>>(key).cast<Map<String, dynamic>>();
}
