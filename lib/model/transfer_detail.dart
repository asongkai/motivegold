// To parse this JSON data, do
//
//     final transferDetailModel = transferDetailModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/product.dart';

TransferDetailModel transferDetailModelFromJson(String str) => TransferDetailModel.fromJson(json.decode(str));

String transferDetailModelToJson(TransferDetailModel data) => json.encode(data.toJson());

class TransferDetailModel {
  int? id;
  int? productId;
  ProductModel? product;
  String? productName;
  int? transferId;
  double? weight;
  double? weightBath;
  double? unitCost;
  double? price;
  DateTime? createdDate;
  DateTime? updatedDate;

  TransferDetailModel({
    this.id,
    this.productId,
    this.product,
    this.productName,
    this.transferId,
    this.weight,
    this.weightBath,
    this.unitCost,
    this.price,
    this.createdDate,
    this.updatedDate,
  });

  factory TransferDetailModel.fromJson(Map<String, dynamic> json) => TransferDetailModel(
    id: json["id"],
    productId: json["productId"],
    product: json["product"] == null ? null : ProductModel.fromJson(json["product"]),
    productName: json["productName"],
    transferId: json["transferId"],
    weight: json["weight"]?.toDouble(),
    weightBath: json["weightBath"],
    unitCost: json["unitCost"],
    price: json["price"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]).toLocal(),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productId": productId,
    "product": product?.toJson(),
    "productName": productName,
    "transferId": transferId,
    "weight": weight,
    "weightBath": weightBath,
    "unitCost": unitCost,
    "price": price,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
