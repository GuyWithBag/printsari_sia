enum ProductCategoryType {
  store('store'),
  printing('printing');

  final String value;
  const ProductCategoryType(this.value);

  static ProductCategoryType? fromString(String value) {
    try {
      return ProductCategoryType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
