class Address {
  final String? street;
  final String? barangay;
  final String? city;
  final String? province;
  final String? region;
  final String? postalCode;
  final String? country;

  Address({
    this.street,
    this.barangay,
    this.city,
    this.province,
    this.region,
    this.postalCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String?,
      barangay: json['barangay'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'barangay': barangay,
      'city': city,
      'province': province,
      'region': region,
      'postal_code': postalCode,
      'country': country,
    };
  }
}
