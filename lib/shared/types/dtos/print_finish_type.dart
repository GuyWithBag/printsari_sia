enum PrintFinishType {
  none('none'),
  laminated('laminated'),
  bound('bound');

  final String value;
  const PrintFinishType(this.value);

  static PrintFinishType? fromString(String value) {
    try {
      return PrintFinishType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
