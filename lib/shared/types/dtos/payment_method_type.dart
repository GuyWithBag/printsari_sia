enum PaymentMethodType {
  cash('cash'),
  gcash('gcash'),
  card('card'),
  credit('credit');

  final String value;
  const PaymentMethodType(this.value);

  static PaymentMethodType? fromString(String value) {
    try {
      return PaymentMethodType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
