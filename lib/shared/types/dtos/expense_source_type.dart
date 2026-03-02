enum ExpenseSourceType {
  manual('manual'),
  autoPrint('auto_print');

  final String value;
  const ExpenseSourceType(this.value);

  static ExpenseSourceType? fromString(String value) {
    try {
      return ExpenseSourceType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
