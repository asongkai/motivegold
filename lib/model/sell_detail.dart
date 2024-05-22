// To parse this JSON data, do
//
//     final transferDetailModel = transferDetailModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';

SellDetailModel sellDetailModelFromJson(String str) => SellDetailModel.fromJson(json.decode(str));

String sellDetailModelToJson(SellDetailModel data) => json.encode(data.toJson());

class SellDetailModel {
  int? id;
  int? productId;
  ProductModel? product;
  int? sellId;
  double? weight;
  double? weightBath;
  int? binLocationId;
  WarehouseModel? fromBinLocation;
  int? toBinLocationId;
  WarehouseModel? toBinLocation;
  DateTime? createdDate;
  DateTime? updatedDate;

  SellDetailModel({
    this.id,
    this.productId,
    this.product,
    this.sellId,
    this.weight,
    this.weightBath,
    this.binLocationId,
    this.fromBinLocation,
    this.toBinLocationId,
    this.toBinLocation,
    this.createdDate,
    this.updatedDate,
  });

  factory SellDetailModel.fromJson(Map<String, dynamic> json) => SellDetailModel(
    id: json["id"],
    productId: json["productId"],
    product: json["product"] == null ? null : ProductModel.fromJson(json["product"]),
    sellId: json["sellId"],
    weight: json["weight"]?.toDouble(),
    weightBath: json["weightBath"],
    binLocationId: json["binLocationId"],
    fromBinLocation: json["fromBinLocation"] == null ? null : WarehouseModel.fromJson(json["fromBinLocation"]),
    toBinLocationId: json["toBinLocationId"],
    toBinLocation: json["toBinLocation"] == null ? null : WarehouseModel.fromJson(json["toBinLocation"]),
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productId": productId,
    "product": product?.toJson(),
    "sellId": sellId,
    "weight": weight,
    "weightBath": weightBath,
    "binLocationId": binLocationId,
    "fromBinLocation": fromBinLocation?.toJson(),
    "toBinLocationId": toBinLocationId,
    "toBinLocation": toBinLocation?.toJson(),
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
