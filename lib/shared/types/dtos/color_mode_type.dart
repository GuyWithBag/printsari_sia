enum ColorModeType {
  bw('bw'),
  colored('colored'),
  grayscale('grayscale');

  final String value;
  const ColorModeType(this.value);

  static ColorModeType? fromString(String value) {
    try {
      return ColorModeType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
