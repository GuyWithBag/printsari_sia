enum ReportPeriodType {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  final String value;
  const ReportPeriodType(this.value);

  static ReportPeriodType? fromString(String value) {
    try {
      return ReportPeriodType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
