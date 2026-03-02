enum PrintOrientationType {
  portrait('portrait'),
  landscape('landscape');

  final String value;
  const PrintOrientationType(this.value);

  static PrintOrientationType? fromString(String value) {
    try {
      return PrintOrientationType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
