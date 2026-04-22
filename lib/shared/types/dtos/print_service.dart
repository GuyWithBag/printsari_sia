import 'package:printsari_sia/shared/types/types.dart';

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
  final int? machineId;
  final int? serviceSupplyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final PaperSize? paperSize;
  final ColorMode? colorMode;
  final PrintOrientation? orientation;
  final PrintFinish? finish;
  final Machine? machine;
  final ServiceSupply? serviceSupply;

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
    this.machineId,
    this.serviceSupplyId,
    required this.createdAt,
    required this.updatedAt,
    this.paperSize,
    this.colorMode,
    this.orientation,
    this.finish,
    this.machine,
    this.serviceSupply,
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
      machineId: json['machine_id'] as int?,
      serviceSupplyId: json['service_supply_id'] as int?,
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
      machine: json['machines'] != null
          ? Machine.fromJson(json['machines'] as Map<String, dynamic>)
          : null,
      serviceSupply: json['service_supplies'] != null
          ? ServiceSupply.fromJson(
              json['service_supplies'] as Map<String, dynamic>,
            )
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
      'machine_id': machineId,
      'service_supply_id': serviceSupplyId,
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
      'machine_id': machineId,
      'service_supply_id': serviceSupplyId,
    };
  }
}
