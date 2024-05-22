// To parse this JSON data, do
//
//     final warehouseModel = warehouseModelFromJson(jsonString);

import 'dart:convert';

List<WarehouseModel> warehouseListModelFromJson(String str) => List<WarehouseModel>.from(json.decode(str).map((x) => WarehouseModel.fromJson(x)));

String warehouseListModelToJson(List<WarehouseModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

WarehouseModel warehouseModelFromJson(String str) => WarehouseModel.fromJson(json.decode(str));

String warehouseModelToJson(WarehouseModel data) => json.encode(data.toJson());

class WarehouseModel {
  int? id;
  int? branchId;
  int? companyId;
  String name;
  String? address;

  WarehouseModel({
    this.id,
    this.branchId,
    this.companyId,
    required this.name,
    this.address,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) => WarehouseModel(
    id: json["id"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    name: json["name"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "branchId": branchId,
    "name": name,
    "address": address,
  };

  @override
  String toString() => name;

  @override
  operator ==(o) => o is WarehouseModel && o.id == id;

  @override
  int get hashCode => id.hashCode^name.hashCode^id.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
