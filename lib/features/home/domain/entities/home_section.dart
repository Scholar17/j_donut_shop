/// Horizontal product lists on Home, in display order.
enum HomeSection {
  seasonalSpecials('seasonal'),
  popular('popular'),
  orderAgain('order_again');

  const HomeSection(this.key);

  /// Stable key used in seed JSON, the API and the database.
  final String key;

  static HomeSection? fromKey(String key) =>
      values.where((section) => section.key == key).firstOrNull;
}
