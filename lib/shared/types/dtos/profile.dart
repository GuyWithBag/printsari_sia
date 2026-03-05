import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final int? id;
  late final String? userId;
  final String username;
  final int roleId;
  final String name;
  final String? phone;
  final String? profilePicture;
  final String? addressStreet;
  final String? addressBarangay;
  final String? addressCity;
  final String? addressProvince;
  final String? addressRegion;
  final String? addressPostalCode;
  final String? addressCountry;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    this.id,
    this.userId,
    required this.username,
    required this.roleId,
    required this.name,
    this.phone,
    this.profilePicture,
    this.addressStreet,
    this.addressBarangay,
    this.addressCity,
    this.addressProvince,
    this.addressRegion,
    this.addressPostalCode,
    this.addressCountry,
    required this.createdAt,
    required this.updatedAt,
  });

  Address? get address {
    if (addressStreet == null &&
        addressBarangay == null &&
        addressCity == null &&
        addressProvince == null &&
        addressRegion == null &&
        addressPostalCode == null &&
        addressCountry == null) {
      return null;
    }
    return Address(
      street: addressStreet,
      barangay: addressBarangay,
      city: addressCity,
      province: addressProvince,
      region: addressRegion,
      postalCode: addressPostalCode,
      country: addressCountry,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      roleId: json['role_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      profilePicture: json['profile_picture'] as String?,
      addressStreet: json['address_street'] as String?,
      addressBarangay: json['address_barangay'] as String?,
      addressCity: json['address_city'] as String?,
      addressProvince: json['address_province'] as String?,
      addressRegion: json['address_region'] as String?,
      addressPostalCode: json['address_postal_code'] as String?,
      addressCountry: json['address_country'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'role_id': roleId,
      'name': name,
      'phone': phone,
      'profile_picture': profilePicture,
      'address_street': addressStreet,
      'address_barangay': addressBarangay,
      'address_city': addressCity,
      'address_province': addressProvince,
      'address_region': addressRegion,
      'address_postal_code': addressPostalCode,
      'address_country': addressCountry,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Future<UserRoleType> getRoleType(Profile profile) async {
    final query = await Supabase.instance.client
        .from('user_roles')
        .select()
        .eq('id', profile.roleId)
        .single();
    final role = UserRole.fromJson(query);
    final roleName = role.roleName;
    return UserRoleType.fromString(roleName)!;
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'username': username,
      'role_id': roleId,
      'name': name,
      'phone': phone,
      'profile_picture': profilePicture,
      'address_street': addressStreet,
      'address_barangay': addressBarangay,
      'address_city': addressCity,
      'address_province': addressProvince,
      'address_region': addressRegion,
      'address_postal_code': addressPostalCode,
      'address_country': addressCountry,
    };
  }
}
