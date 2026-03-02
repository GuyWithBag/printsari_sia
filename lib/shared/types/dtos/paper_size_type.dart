enum PaperSizeType {
  short('short'),
  long('long'),
  a4('a4'),
  legal('legal'),
  letter('letter');

  final String value;
  const PaperSizeType(this.value);

  static PaperSizeType? fromString(String value) {
    try {
      return PaperSizeType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
