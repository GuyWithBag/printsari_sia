enum UserRoleType {
  owner('owner'),
  manager('manager'),
  cashier('cashier');

  final String value;
  const UserRoleType(this.value);

  static UserRoleType? fromString(String value) {
    try {
      return UserRoleType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
