enum TransactionStatusType {
  completed('completed'),
  pending('pending'),
  cancelled('cancelled'),
  refunded('refunded');

  final String value;
  const TransactionStatusType(this.value);

  static TransactionStatusType? fromString(String value) {
    try {
      return TransactionStatusType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
