enum ActivityActionCategory {
  transaction('transaction'),
  product('product'),
  inventory('inventory'),
  user('user'),
  expense('expense'),
  customer('customer'),
  printService('print_service');

  final String value;
  const ActivityActionCategory(this.value);

  static ActivityActionCategory? fromString(String value) {
    try {
      return ActivityActionCategory.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
