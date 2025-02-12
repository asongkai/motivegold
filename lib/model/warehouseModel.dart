// To parse this JSON data, do
//
//     final warehouseModel = warehouseModelFromJson(jsonString);

import 'dart:convert';

List<WarehouseModel> warehouseListModelFromJson(String str) =>
    List<WarehouseModel>.from(
        json.decode(str).map((x) => WarehouseModel.fromJson(x)));

String warehouseListModelToJson(List<WarehouseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

WarehouseModel warehouseModelFromJson(String str) =>
    WarehouseModel.fromJson(json.decode(str));

String warehouseModelToJson(WarehouseModel data) => json.encode(data.toJson());

class WarehouseModel {
  int? id;
  int? branchId;
  int? companyId;
  String name;
  String? address;
  int? sell;
  int? matching;
  int? transit;
  int? isDefault;

  WarehouseModel(
      {this.id,
      this.branchId,
      this.companyId,
      required this.name,
      this.address,
      this.sell,
      this.isDefault,
      this.transit,
      this.matching});

  factory WarehouseModel.fromJson(Map<String, dynamic> json) => WarehouseModel(
        id: json["id"],
        companyId: json["companyId"],
        branchId: json["branchId"],
        name: json["name"],
        address: json["address"],
        sell: json["sell"],
        matching: json["matching"],
        transit: json["transit"],
        isDefault: json["isDefault"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "companyId": companyId,
        "branchId": branchId,
        "name": name,
        "address": address,
        "sell": sell,
        "isDefault": isDefault,
        "matching": matching,
        "transit": transit,
      };

  @override
  String toString() => name;

  @override
  operator ==(o) => o is WarehouseModel && o.id == id;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ id.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
