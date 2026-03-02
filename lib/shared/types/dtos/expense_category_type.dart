enum ExpenseCategoryType {
  printingInk('printing_ink'),
  printingPaper('printing_paper'),
  printingElectricity('printing_electricity'),
  printingMaintenance('printing_maintenance'),
  storeInventory('store_inventory'),
  utilities('utilities'),
  rent('rent'),
  salaries('salaries'),
  supplies('supplies'),
  other('other');

  final String value;
  const ExpenseCategoryType(this.value);

  static ExpenseCategoryType? fromString(String value) {
    try {
      return ExpenseCategoryType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null; // Return null for unknown values from DB
    }
  }
}
