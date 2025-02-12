// To parse this JSON data, do
//
//     final stockMovementModel = stockMovementModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';

List<StockMovementModel> stockMovementListModelFromJson(String str) =>
    List<StockMovementModel>.from(
        json.decode(str).map((x) => StockMovementModel.fromJson(x)));

String stockMovementListModelToJson(List<StockMovementModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

StockMovementModel stockMovementModelFromJson(String str) =>
    StockMovementModel.fromJson(json.decode(str));

String stockMovementModelToJson(StockMovementModel data) =>
    json.encode(data.toJson());

class StockMovementModel {
  int? id;
  int? companyId;
  int? branchId;
  String? orderId;
  String? docType;
  String? type;
  int? productId;
  int? binLocationId;
  double? weight;
  double? unitCost;
  double? price;
  DateTime? createdDate;
  DateTime? updatedDate;
  ProductModel? product;
  WarehouseModel? binLocation;

  StockMovementModel(
      {this.id,
      this.companyId,
      this.branchId,
      this.orderId,
      this.docType,
      this.type,
      this.productId,
      this.binLocationId,
      this.weight,
      this.unitCost,
      this.price,
      this.createdDate,
      this.updatedDate,
      this.product,
      this.binLocation});

  factory StockMovementModel.fromJson(Map<String, dynamic> json) =>
      StockMovementModel(
        id: json["id"],
        companyId: json["companyId"],
        branchId: json["branchId"],
        orderId: json["orderId"],
        docType: json["docType"],
        type: json["type"],
        productId: json["productId"],
        binLocationId: json["binLocationId"],
        weight: json["weight"]?.toDouble(),
        unitCost: json["unitCost"],
        price: json["price"]?.toDouble(),
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]).toLocal(),
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]).toLocal(),
        product: json["product"] == null
            ? null
            : ProductModel.fromJson(json["product"]),
        binLocation: json["binLocation"] == null
            ? null
            : WarehouseModel.fromJson(json["binLocation"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "companyId": companyId,
        "branchId": branchId,
        "orderId": orderId,
        "docType": docType,
        "type": type,
        "productId": productId,
        "binLocationId": binLocationId,
        "weight": weight,
        "unitCost": unitCost,
        "price": price,
        "createdDate": createdDate?.toIso8601String(),
        "updatedDate": updatedDate?.toIso8601String(),
        "product": product?.toJson(),
        "binLocation": binLocation?.toJson()
      };
}
