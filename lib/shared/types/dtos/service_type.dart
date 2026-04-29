import 'package:printsari_sia/shared/types/dtos/machine.dart';
import 'package:printsari_sia/shared/types/dtos/service.dart';
import 'package:printsari_sia/shared/types/dtos/service_supply.dart';
import 'package:printsari_sia/shared/types/dtos/service_type_cost.dart';

class ServiceType {
  final int id;
  final int? serviceId;
  final int? serviceSupplyId;
  final int? machineId;
  final String name;
  final String? paperSize;
  final String? colorMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final Service? service;
  final ServiceSupply? serviceSupply;
  final Machine? machine;
  final ServiceTypeCost? cost;

  ServiceType({
    required this.id,
    this.serviceId,
    this.serviceSupplyId,
    this.machineId,
    required this.name,
    this.paperSize,
    this.colorMode,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.serviceSupply,
    this.machine,
    this.cost,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    // service_type_costs is a list; take the most recent entry
    ServiceTypeCost? latestCost;
    final costsRaw = json['service_type_costs'];
    if (costsRaw is List && costsRaw.isNotEmpty) {
      final sorted = List<Map<String, dynamic>>.from(costsRaw)
        ..sort((a, b) {
          final aTime = DateTime.parse(a['last_updated'] as String);
          final bTime = DateTime.parse(b['last_updated'] as String);
          return bTime.compareTo(aTime);
        });
      latestCost = ServiceTypeCost.fromJson(sorted.first);
    }

    return ServiceType(
      id: json['id'] as int,
      serviceId: json['service_id'] as int?,
      serviceSupplyId: json['service_supply_id'] as int?,
      machineId: json['machine_id'] as int?,
      name: json['name'] as String,
      paperSize: json['paper_size'] as String?,
      colorMode: json['color_mode'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      service: json['services'] != null
          ? Service.fromJson(json['services'] as Map<String, dynamic>)
          : null,
      serviceSupply: json['service_supplies'] != null
          ? ServiceSupply.fromJson(
              json['service_supplies'] as Map<String, dynamic>)
          : null,
      machine: json['machines'] != null
          ? Machine.fromJson(json['machines'] as Map<String, dynamic>)
          : null,
      cost: latestCost,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        if (serviceId != null) 'service_id': serviceId,
        if (serviceSupplyId != null) 'service_supply_id': serviceSupplyId,
        if (machineId != null) 'machine_id': machineId,
        'name': name,
        if (paperSize != null) 'paper_size': paperSize,
        if (colorMode != null) 'color_mode': colorMode,
      };
}
