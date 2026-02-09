/// ============================================================================
// ENUMS (for intellisense and type safety)
// ============================================================================

enum ExpenseCategoryType {
  printingInk('printing_ink'),
  printingPaper('printing_paper'),
  printingElectricity('printing_electricity'),
  printingMaintenance('printing_maintenance'),
  storeInventory('store_inventory'),
  utilities('utilities'),
  rent('rent'),
  salaries('salaries'),
  supplies('supplies'),
  other('other');

  final String value;
  const ExpenseCategoryType(this.value);

  static ExpenseCategoryType? fromString(String value) {
    try {
      return ExpenseCategoryType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null; // Return null for unknown values from DB
    }
  }
}

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

enum TransactionStatusType {
  completed('completed'),
  pending('pending'),
  cancelled('cancelled'),
  refunded('refunded');

  final String value;
  const TransactionStatusType(this.value);

  static TransactionStatusType? fromString(String value) {
    try {
      return TransactionStatusType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum UserRoleType {
  owner('owner'),
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

enum ProductCategoryType {
  store('store'),
  printing('printing');

  final String value;
  const ProductCategoryType(this.value);

  static ProductCategoryType? fromString(String value) {
    try {
      return ProductCategoryType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}

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

enum ExpenseSourceType {
  manual('manual'),
  autoPrint('auto_print');

  final String value;
  const ExpenseSourceType(this.value);

  static ExpenseSourceType? fromString(String value) {
    try {
      return ExpenseSourceType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum ActivityActionCategory {
  transaction('transaction'),
  product('product'),
  inventory('inventory'),
  user('user'),
  expense('expense'),
  customer('customer'),
  printService('print_service');

  final String value;
  const ActivityActionCategory(this.value);

  static ActivityActionCategory? fromString(String value) {
    try {
      return ActivityActionCategory.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}

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

// ============================================================================
// LOOKUP TABLE DTOs (Enhanced with enum support)
// ============================================================================

class ExpenseCategory {
  final int id;
  final String categoryName;
  final DateTime createdAt;

  ExpenseCategory({
    required this.id,
    required this.categoryName,
    required this.createdAt,
  });

  // Convenience getter to get enum (if it exists)
  ExpenseCategoryType? get categoryType =>
      ExpenseCategoryType.fromString(categoryName);

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as int,
      categoryName: json['category_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper to create from enum
  static ExpenseCategory fromEnum({
    required int id,
    required ExpenseCategoryType type,
    required DateTime createdAt,
  }) {
    return ExpenseCategory(
      id: id,
      categoryName: type.value,
      createdAt: createdAt,
    );
  }
}

class PaymentMethod {
  final int id;
  final String methodName;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.methodName,
    required this.createdAt,
  });

  PaymentMethodType? get methodType => PaymentMethodType.fromString(methodName);

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      methodName: json['method_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method_name': methodName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TransactionStatus {
  final int id;
  final String statusName;
  final DateTime createdAt;

  TransactionStatus({
    required this.id,
    required this.statusName,
    required this.createdAt,
  });

  TransactionStatusType? get statusType =>
      TransactionStatusType.fromString(statusName);

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    return TransactionStatus(
      id: json['id'] as int,
      statusName: json['status_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_name': statusName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserRole {
  final int id;
  final String roleName;
  final DateTime createdAt;

  UserRole({required this.id, required this.roleName, required this.createdAt});

  UserRoleType? get roleType => UserRoleType.fromString(roleName);

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] as int,
      roleName: json['role_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_name': roleName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ProductCategory {
  final int id;
  final String categoryName;
  final DateTime createdAt;

  ProductCategory({
    required this.id,
    required this.categoryName,
    required this.createdAt,
  });

  ProductCategoryType? get categoryType =>
      ProductCategoryType.fromString(categoryName);

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      categoryName: json['category_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PaperSize {
  final int id;
  final String sizeName;
  final DateTime createdAt;

  PaperSize({
    required this.id,
    required this.sizeName,
    required this.createdAt,
  });

  PaperSizeType? get sizeType => PaperSizeType.fromString(sizeName);

  factory PaperSize.fromJson(Map<String, dynamic> json) {
    return PaperSize(
      id: json['id'] as int,
      sizeName: json['size_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size_name': sizeName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ColorMode {
  final int id;
  final String modeName;
  final DateTime createdAt;

  ColorMode({
    required this.id,
    required this.modeName,
    required this.createdAt,
  });

  ColorModeType? get modeType => ColorModeType.fromString(modeName);

  factory ColorMode.fromJson(Map<String, dynamic> json) {
    return ColorMode(
      id: json['id'] as int,
      modeName: json['mode_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode_name': modeName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PrintOrientation {
  final int id;
  final String orientationName;
  final DateTime createdAt;

  PrintOrientation({
    required this.id,
    required this.orientationName,
    required this.createdAt,
  });

  PrintOrientationType? get orientationType =>
      PrintOrientationType.fromString(orientationName);

  factory PrintOrientation.fromJson(Map<String, dynamic> json) {
    return PrintOrientation(
      id: json['id'] as int,
      orientationName: json['orientation_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orientation_name': orientationName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PrintFinish {
  final int id;
  final String finishName;
  final DateTime createdAt;

  PrintFinish({
    required this.id,
    required this.finishName,
    required this.createdAt,
  });

  PrintFinishType? get finishType => PrintFinishType.fromString(finishName);

  factory PrintFinish.fromJson(Map<String, dynamic> json) {
    return PrintFinish(
      id: json['id'] as int,
      finishName: json['finish_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'finish_name': finishName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ExpenseSource {
  final int id;
  final String sourceName;
  final DateTime createdAt;

  ExpenseSource({
    required this.id,
    required this.sourceName,
    required this.createdAt,
  });

  ExpenseSourceType? get sourceType => ExpenseSourceType.fromString(sourceName);

  factory ExpenseSource.fromJson(Map<String, dynamic> json) {
    return ExpenseSource(
      id: json['id'] as int,
      sourceName: json['source_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source_name': sourceName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ActivityAction {
  final int id;
  final String actionName;
  final String category;
  final DateTime createdAt;

  ActivityAction({
    required this.id,
    required this.actionName,
    required this.category,
    required this.createdAt,
  });

  ActivityActionCategory? get categoryType =>
      ActivityActionCategory.fromString(category);

  factory ActivityAction.fromJson(Map<String, dynamic> json) {
    return ActivityAction(
      id: json['id'] as int,
      actionName: json['action_name'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_name': actionName,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ReportPeriod {
  final int id;
  final String periodName;
  final DateTime createdAt;

  ReportPeriod({
    required this.id,
    required this.periodName,
    required this.createdAt,
  });

  ReportPeriodType? get periodType => ReportPeriodType.fromString(periodName);

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      id: json['id'] as int,
      periodName: json['period_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period_name': periodName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ============================================================================
// MAIN DTOs
// ============================================================================

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

class Profile {
  final int id;
  final String userId;
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

  // Optional joined data
  final UserRole? role;

  Profile({
    required this.id,
    required this.userId,
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
    this.role,
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
      role: json['user_roles'] != null
          ? UserRole.fromJson(json['user_roles'] as Map<String, dynamic>)
          : null,
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

class Customer {
  final int id;
  final String? name;
  final String email;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime registeredDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    this.name,
    required this.email,
    this.phone,
    this.address,
    this.notes,
    required this.registeredDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      registeredDate: DateTime.parse(json['registered_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'registered_date': registeredDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final double purchasePrice;
  final String? sku;
  final String? barcode;
  final String? supplier;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ProductCategory? category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.purchasePrice,
    this.sku,
    this.barcode,
    this.supplier,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'] as int,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      supplier: json['supplier'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['product_categories'] != null
          ? ProductCategory.fromJson(
              json['product_categories'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'sku': sku,
      'barcode': barcode,
      'supplier': supplier,
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'description': description,
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'sku': sku,
      'barcode': barcode,
      'supplier': supplier,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}

class InventoryItem {
  final int id;
  final int productId;
  final double stock;
  final double retailPrice;
  final double? reorderLevel;
  final String? location;
  final DateTime? lastRestocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final Product? product;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.stock,
    required this.retailPrice,
    this.reorderLevel,
    this.location,
    this.lastRestocked,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      stock: (json['stock'] as num).toDouble(),
      retailPrice: (json['retail_price'] as num).toDouble(),
      reorderLevel: json['reorder_level'] != null
          ? (json['reorder_level'] as num).toDouble()
          : null,
      location: json['location'] as String?,
      lastRestocked: json['last_restocked'] != null
          ? DateTime.parse(json['last_restocked'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      product: json['products'] != null
          ? Product.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'stock': stock,
      'retail_price': retailPrice,
      'reorder_level': reorderLevel,
      'location': location,
      'last_restocked': lastRestocked?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'product_id': productId,
      'stock': stock,
      'retail_price': retailPrice,
      'reorder_level': reorderLevel,
      'location': location,
      'last_restocked': lastRestocked?.toIso8601String(),
    };
  }
}

class PrintService {
  final int id;
  final String name;
  final String description;
  final int paperSizeId;
  final int colorModeId;
  final double basePrice;
  final double inkCostPerPage;
  final double paperCostPerPage;
  final double electricityCostPerPage;
  final double maintenanceCostPerPage;
  final double totalCostPerPage;
  final int? orientationId;
  final int? finishId;
  final double? paperStock;
  final double? inkLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final PaperSize? paperSize;
  final ColorMode? colorMode;
  final PrintOrientation? orientation;
  final PrintFinish? finish;

  PrintService({
    required this.id,
    required this.name,
    required this.description,
    required this.paperSizeId,
    required this.colorModeId,
    required this.basePrice,
    required this.inkCostPerPage,
    required this.paperCostPerPage,
    required this.electricityCostPerPage,
    required this.maintenanceCostPerPage,
    required this.totalCostPerPage,
    this.orientationId,
    this.finishId,
    this.paperStock,
    this.inkLevel,
    required this.createdAt,
    required this.updatedAt,
    this.paperSize,
    this.colorMode,
    this.orientation,
    this.finish,
  });

  factory PrintService.fromJson(Map<String, dynamic> json) {
    return PrintService(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      paperSizeId: json['paper_size_id'] as int,
      colorModeId: json['color_mode_id'] as int,
      basePrice: (json['base_price'] as num).toDouble(),
      inkCostPerPage: (json['ink_cost_per_page'] as num).toDouble(),
      paperCostPerPage: (json['paper_cost_per_page'] as num).toDouble(),
      electricityCostPerPage: (json['electricity_cost_per_page'] as num)
          .toDouble(),
      maintenanceCostPerPage: (json['maintenance_cost_per_page'] as num)
          .toDouble(),
      totalCostPerPage: (json['total_cost_per_page'] as num).toDouble(),
      orientationId: json['orientation_id'] as int?,
      finishId: json['finish_id'] as int?,
      paperStock: json['paper_stock'] != null
          ? (json['paper_stock'] as num).toDouble()
          : null,
      inkLevel: json['ink_level'] != null
          ? (json['ink_level'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paperSize: json['paper_sizes'] != null
          ? PaperSize.fromJson(json['paper_sizes'] as Map<String, dynamic>)
          : null,
      colorMode: json['color_modes'] != null
          ? ColorMode.fromJson(json['color_modes'] as Map<String, dynamic>)
          : null,
      orientation: json['print_orientations'] != null
          ? PrintOrientation.fromJson(
              json['print_orientations'] as Map<String, dynamic>,
            )
          : null,
      finish: json['print_finishes'] != null
          ? PrintFinish.fromJson(json['print_finishes'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'paper_size_id': paperSizeId,
      'color_mode_id': colorModeId,
      'base_price': basePrice,
      'ink_cost_per_page': inkCostPerPage,
      'paper_cost_per_page': paperCostPerPage,
      'electricity_cost_per_page': electricityCostPerPage,
      'maintenance_cost_per_page': maintenanceCostPerPage,
      'total_cost_per_page': totalCostPerPage,
      'orientation_id': orientationId,
      'finish_id': finishId,
      'paper_stock': paperStock,
      'ink_level': inkLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'description': description,
      'paper_size_id': paperSizeId,
      'color_mode_id': colorModeId,
      'base_price': basePrice,
      'ink_cost_per_page': inkCostPerPage,
      'paper_cost_per_page': paperCostPerPage,
      'electricity_cost_per_page': electricityCostPerPage,
      'maintenance_cost_per_page': maintenanceCostPerPage,
      'total_cost_per_page': totalCostPerPage,
      'orientation_id': orientationId,
      'finish_id': finishId,
      'paper_stock': paperStock,
      'ink_level': inkLevel,
    };
  }
}

class PrintOrder {
  final int id;
  final int serviceId;
  final int quantity;
  final bool? doubleSided;
  final int? copies;
  final int? additionalFinishId;
  final double totalPrice;
  final double inkUsed;
  final double paperUsed;
  final double electricityUsed;
  final double totalCost;
  final double profitMargin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final PrintService? service;
  final PrintFinish? additionalFinish;

  PrintOrder({
    required this.id,
    required this.serviceId,
    required this.quantity,
    this.doubleSided,
    this.copies,
    this.additionalFinishId,
    required this.totalPrice,
    required this.inkUsed,
    required this.paperUsed,
    required this.electricityUsed,
    required this.totalCost,
    required this.profitMargin,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.additionalFinish,
  });

  factory PrintOrder.fromJson(Map<String, dynamic> json) {
    return PrintOrder(
      id: json['id'] as int,
      serviceId: json['service_id'] as int,
      quantity: json['quantity'] as int,
      doubleSided: json['double_sided'] as bool?,
      copies: json['copies'] as int?,
      additionalFinishId: json['additional_finish_id'] as int?,
      totalPrice: (json['total_price'] as num).toDouble(),
      inkUsed: (json['ink_used'] as num).toDouble(),
      paperUsed: (json['paper_used'] as num).toDouble(),
      electricityUsed: (json['electricity_used'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      profitMargin: (json['profit_margin'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      service: json['print_services'] != null
          ? PrintService.fromJson(
              json['print_services'] as Map<String, dynamic>,
            )
          : null,
      additionalFinish: json['print_finishes'] != null
          ? PrintFinish.fromJson(json['print_finishes'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'quantity': quantity,
      'double_sided': doubleSided,
      'copies': copies,
      'additional_finish_id': additionalFinishId,
      'total_price': totalPrice,
      'ink_used': inkUsed,
      'paper_used': paperUsed,
      'electricity_used': electricityUsed,
      'total_cost': totalCost,
      'profit_margin': profitMargin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'service_id': serviceId,
      'quantity': quantity,
      'double_sided': doubleSided,
      'copies': copies,
      'additional_finish_id': additionalFinishId,
      'total_price': totalPrice,
      'ink_used': inkUsed,
      'paper_used': paperUsed,
      'electricity_used': electricityUsed,
      'total_cost': totalCost,
      'profit_margin': profitMargin,
    };
  }
}

class Transaction {
  final int id;
  final String transactionNumber;
  final double subtotal;
  final double? tax;
  final double? discount;
  final double total;
  final DateTime date;
  final int statusId;
  final int paymentMethodId;
  final int cashierId;
  final int? customerId;
  final String? notes;
  final double storeRevenue;
  final double printingRevenue;
  final double? totalCost;
  final double? grossProfit;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final TransactionStatus? status;
  final PaymentMethod? paymentMethod;
  final Profile? cashier;
  final Customer? customer;
  final List<TransactionItem>? items;

  Transaction({
    required this.id,
    required this.transactionNumber,
    required this.subtotal,
    this.tax,
    this.discount,
    required this.total,
    required this.date,
    required this.statusId,
    required this.paymentMethodId,
    required this.cashierId,
    this.customerId,
    this.notes,
    required this.storeRevenue,
    required this.printingRevenue,
    this.totalCost,
    this.grossProfit,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.paymentMethod,
    this.cashier,
    this.customer,
    this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      transactionNumber: json['transaction_number'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      statusId: json['status_id'] as int,
      paymentMethodId: json['payment_method_id'] as int,
      cashierId: json['cashier_id'] as int,
      customerId: json['customer_id'] as int?,
      notes: json['notes'] as String?,
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      totalCost: json['total_cost'] != null
          ? (json['total_cost'] as num).toDouble()
          : null,
      grossProfit: json['gross_profit'] != null
          ? (json['gross_profit'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['transaction_statuses'] != null
          ? TransactionStatus.fromJson(
              json['transaction_statuses'] as Map<String, dynamic>,
            )
          : null,
      paymentMethod: json['payment_methods'] != null
          ? PaymentMethod.fromJson(
              json['payment_methods'] as Map<String, dynamic>,
            )
          : null,
      cashier: json['profiles'] != null
          ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      customer: json['customers'] != null
          ? Customer.fromJson(json['customers'] as Map<String, dynamic>)
          : null,
      items: json['transaction_items'] != null
          ? (json['transaction_items'] as List)
                .map(
                  (item) =>
                      TransactionItem.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'date': date.toIso8601String(),
      'status_id': statusId,
      'payment_method_id': paymentMethodId,
      'cashier_id': cashierId,
      'customer_id': customerId,
      'notes': notes,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'total_cost': totalCost,
      'gross_profit': grossProfit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'transaction_number': transactionNumber,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'date': date.toIso8601String(),
      'status_id': statusId,
      'payment_method_id': paymentMethodId,
      'cashier_id': cashierId,
      'customer_id': customerId,
      'notes': notes,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'total_cost': totalCost,
      'gross_profit': grossProfit,
    };
  }
}

class TransactionItem {
  final int id;
  final int transactionId;
  final int? inventoryId;
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final int categoryId;
  final double? discount;
  final int? printOrderId;
  final double? itemCost;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final InventoryItem? inventoryItem;
  final Product? product;
  final ProductCategory? category;
  final PrintOrder? printOrder;

  TransactionItem({
    required this.id,
    required this.transactionId,
    this.inventoryId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.categoryId,
    this.discount,
    this.printOrderId,
    this.itemCost,
    required this.createdAt,
    required this.updatedAt,
    this.inventoryItem,
    this.product,
    this.category,
    this.printOrder,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as int,
      transactionId: json['transaction_id'] as int,
      inventoryId: json['inventory_id'] as int?,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      categoryId: json['category_id'] as int,
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      printOrderId: json['print_order_id'] as int?,
      itemCost: json['item_cost'] != null
          ? (json['item_cost'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      inventoryItem: json['inventory_items'] != null
          ? InventoryItem.fromJson(
              json['inventory_items'] as Map<String, dynamic>,
            )
          : null,
      product: json['products'] != null
          ? Product.fromJson(json['products'] as Map<String, dynamic>)
          : null,
      category: json['product_categories'] != null
          ? ProductCategory.fromJson(
              json['product_categories'] as Map<String, dynamic>,
            )
          : null,
      printOrder: json['print_orders'] != null
          ? PrintOrder.fromJson(json['print_orders'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'inventory_id': inventoryId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'category_id': categoryId,
      'discount': discount,
      'print_order_id': printOrderId,
      'item_cost': itemCost,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'transaction_id': transactionId,
      'inventory_id': inventoryId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'category_id': categoryId,
      'discount': discount,
      'print_order_id': printOrderId,
      'item_cost': itemCost,
    };
  }
}

class Expense {
  final int id;
  final String description;
  final double amount;
  final int categoryId;
  final DateTime date;
  final String? receiptNumber;
  final String? vendor;
  final int? paymentMethodId;
  final String? notes;
  final int? linkedTransactionId;
  final int sourceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ExpenseCategory? category;
  final PaymentMethod? paymentMethod;
  final Transaction? linkedTransaction;
  final ExpenseSource? source;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.receiptNumber,
    this.vendor,
    this.paymentMethodId,
    this.notes,
    this.linkedTransactionId,
    required this.sourceId,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.paymentMethod,
    this.linkedTransaction,
    this.source,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as int,
      date: DateTime.parse(json['date'] as String),
      receiptNumber: json['receipt_number'] as String?,
      vendor: json['vendor'] as String?,
      paymentMethodId: json['payment_method_id'] as int?,
      notes: json['notes'] as String?,
      linkedTransactionId: json['linked_transaction_id'] as int?,
      sourceId: json['source_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['expense_categories'] != null
          ? ExpenseCategory.fromJson(
              json['expense_categories'] as Map<String, dynamic>,
            )
          : null,
      paymentMethod: json['payment_methods'] != null
          ? PaymentMethod.fromJson(
              json['payment_methods'] as Map<String, dynamic>,
            )
          : null,
      linkedTransaction: json['transactions'] != null
          ? Transaction.fromJson(json['transactions'] as Map<String, dynamic>)
          : null,
      source: json['expense_sources'] != null
          ? ExpenseSource.fromJson(
              json['expense_sources'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'receipt_number': receiptNumber,
      'vendor': vendor,
      'payment_method_id': paymentMethodId,
      'notes': notes,
      'linked_transaction_id': linkedTransactionId,
      'source_id': sourceId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'receipt_number': receiptNumber,
      'vendor': vendor,
      'payment_method_id': paymentMethodId,
      'notes': notes,
      'linked_transaction_id': linkedTransactionId,
      'source_id': sourceId,
    };
  }
}

class ActivityLog {
  final int id;
  final int actionId;
  final String description;
  final DateTime timestamp;
  final String performedBy;
  final int performedById;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  // Optional joined data
  final ActivityAction? action;
  final Profile? performer;

  ActivityLog({
    required this.id,
    required this.actionId,
    required this.description,
    required this.timestamp,
    required this.performedBy,
    required this.performedById,
    this.metadata,
    required this.createdAt,
    this.action,
    this.performer,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int,
      actionId: json['action_id'] as int,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      performedBy: json['performed_by'] as String,
      performedById: json['performed_by_id'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      action: json['activity_actions'] != null
          ? ActivityAction.fromJson(
              json['activity_actions'] as Map<String, dynamic>,
            )
          : null,
      performer: json['profiles'] != null
          ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_id': actionId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'performed_by': performedBy,
      'performed_by_id': performedById,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'action_id': actionId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'performed_by': performedBy,
      'performed_by_id': performedById,
      'metadata': metadata,
    };
  }
}

// ============================================================================
// FINANCIAL METRICS DTOs
// ============================================================================

class DailyMetrics {
  final double revenue;
  final double storeRevenue;
  final double printingRevenue;
  final double expenses;
  final double profit;
  final int transactionCount;
  final double profitMargin; // Percentage

  DailyMetrics({
    required this.revenue,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.expenses,
    required this.profit,
    required this.transactionCount,
    required this.profitMargin,
  });

  factory DailyMetrics.fromJson(Map<String, dynamic> json) {
    return DailyMetrics(
      revenue: (json['revenue'] as num).toDouble(),
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
      profitMargin: (json['profit_margin'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'expenses': expenses,
      'profit': profit,
      'transaction_count': transactionCount,
      'profit_margin': profitMargin,
    };
  }
}

class WeeklyMetrics {
  final double revenue;
  final double storeRevenue;
  final double printingRevenue;
  final double expenses;
  final double profit;
  final double dailyAverage;

  WeeklyMetrics({
    required this.revenue,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.expenses,
    required this.profit,
    required this.dailyAverage,
  });

  factory WeeklyMetrics.fromJson(Map<String, dynamic> json) {
    return WeeklyMetrics(
      revenue: (json['revenue'] as num).toDouble(),
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      dailyAverage: (json['daily_average'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'expenses': expenses,
      'profit': profit,
      'daily_average': dailyAverage,
    };
  }
}

class MonthlyMetrics {
  final double revenue;
  final double storeRevenue;
  final double printingRevenue;
  final double expenses;
  final double profit;
  final double dailyAverage;
  final int transactionCount;
  final double profitMargin; // Percentage

  MonthlyMetrics({
    required this.revenue,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.expenses,
    required this.profit,
    required this.dailyAverage,
    required this.transactionCount,
    required this.profitMargin,
  });

  factory MonthlyMetrics.fromJson(Map<String, dynamic> json) {
    return MonthlyMetrics(
      revenue: (json['revenue'] as num).toDouble(),
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      dailyAverage: (json['daily_average'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
      profitMargin: (json['profit_margin'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'expenses': expenses,
      'profit': profit,
      'daily_average': dailyAverage,
      'transaction_count': transactionCount,
      'profit_margin': profitMargin,
    };
  }
}

class TrendDataPoint {
  final String date; // Formatted date string for display
  final double revenue;
  final double storeRevenue;
  final double printingRevenue;
  final double expenses;
  final double profit;

  TrendDataPoint({
    required this.date,
    required this.revenue,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.expenses,
    required this.profit,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: json['date'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'revenue': revenue,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'expenses': expenses,
      'profit': profit,
    };
  }
}

enum DepartmentName {
  store('Store'),
  printing('Printing');

  final String value;
  const DepartmentName(this.value);

  static DepartmentName fromString(String value) {
    return DepartmentName.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid DepartmentName: $value'),
    );
  }
}

class DepartmentRevenue {
  final String name; // 'Store' or 'Printing'
  final double value;
  final double percentage;
  final String color;

  DepartmentRevenue({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
  });

  // Convenience getter for type-safe department name
  DepartmentName get departmentName => DepartmentName.fromString(name);

  factory DepartmentRevenue.fromJson(Map<String, dynamic> json) {
    return DepartmentRevenue(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'percentage': percentage,
      'color': color,
    };
  }
}

class ExpenseByCategory {
  final String category;
  final double amount;
  final double percentage;

  ExpenseByCategory({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory ExpenseByCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseByCategory(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': category, 'amount': amount, 'percentage': percentage};
  }
}

class FinancialReport {
  final int id;
  final int periodId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ReportPeriod? period;
  final List<DailyMetrics>? dailyMetrics;
  final List<WeeklyMetrics>? weeklyMetrics;
  final List<MonthlyMetrics>? monthlyMetrics;
  final List<TrendDataPoint>? trendDataPoints;
  final List<DepartmentRevenue>? departmentRevenues;
  final List<ExpenseByCategory>? expensesByCategory;

  FinancialReport({
    required this.id,
    required this.periodId,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.period,
    this.dailyMetrics,
    this.weeklyMetrics,
    this.monthlyMetrics,
    this.trendDataPoints,
    this.departmentRevenues,
    this.expensesByCategory,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      id: json['id'] as int,
      periodId: json['period_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      period: json['report_periods'] != null
          ? ReportPeriod.fromJson(
              json['report_periods'] as Map<String, dynamic>,
            )
          : null,
      dailyMetrics: json['daily_metrics'] != null
          ? (json['daily_metrics'] as List)
                .map(
                  (item) => DailyMetrics.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      weeklyMetrics: json['weekly_metrics'] != null
          ? (json['weekly_metrics'] as List)
                .map(
                  (item) =>
                      WeeklyMetrics.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      monthlyMetrics: json['monthly_metrics'] != null
          ? (json['monthly_metrics'] as List)
                .map(
                  (item) =>
                      MonthlyMetrics.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      trendDataPoints: json['trend_data_points'] != null
          ? (json['trend_data_points'] as List)
                .map(
                  (item) =>
                      TrendDataPoint.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      departmentRevenues: json['department_revenues'] != null
          ? (json['department_revenues'] as List)
                .map(
                  (item) =>
                      DepartmentRevenue.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      expensesByCategory: json['expenses_by_category'] != null
          ? (json['expenses_by_category'] as List)
                .map(
                  (item) =>
                      ExpenseByCategory.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period_id': periodId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'period_id': periodId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
