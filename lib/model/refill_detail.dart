// To parse this JSON data, do
//
//     final transferDetailModel = transferDetailModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';

RefillDetailModel refillDetailModelFromJson(String str) => RefillDetailModel.fromJson(json.decode(str));

String refillDetailModelToJson(RefillDetailModel data) => json.encode(data.toJson());

class RefillDetailModel {
  int? id;
  int? productId;
  ProductModel? product;
  int? sellId;
  double? weight;
  double? weightBath;
  int? binLocationId;
  WarehouseModel? binLocation;
  DateTime? createdDate;
  DateTime? updatedDate;

  RefillDetailModel({
    this.id,
    this.productId,
    this.product,
    this.sellId,
    this.weight,
    this.weightBath,
    this.binLocationId,
    this.binLocation,
    this.createdDate,
    this.updatedDate,
  });

  factory RefillDetailModel.fromJson(Map<String, dynamic> json) => RefillDetailModel(
    id: json["id"],
    productId: json["productId"],
    product: json["product"] == null ? null : ProductModel.fromJson(json["product"]),
    sellId: json["sellId"],
    weight: json["weight"]?.toDouble(),
    weightBath: json["weightBath"],
    binLocationId: json["binLocationId"],
    binLocation: json["binLocation"] == null ? null : WarehouseModel.fromJson(json["binLocation"]),
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
    "binLocation": binLocation?.toJson(),
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
