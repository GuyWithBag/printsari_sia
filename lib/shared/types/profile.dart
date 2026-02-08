import 'package:printsari_sia/shared/types/types.dart';

class Profile {
  final String username;
  final String role;

  Role get getRole {
    return Role.values.byName(role);
  }

  Profile({required this.username, required this.role});
}
