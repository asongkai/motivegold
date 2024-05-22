// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';


List<QtyLocationModel> qtyLocationListModelFromJson(String str) => List<QtyLocationModel>.from(json.decode(str).map((x) => QtyLocationModel.fromJson(x)));

String qtyLocationListModelToJson(List<QtyLocationModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

QtyLocationModel qtyLocationModelFromJson(String str) => QtyLocationModel.fromJson(json.decode(str));

String qtyLocationModelToJson(QtyLocationModel data) => json.encode(data.toJson());

class QtyLocationModel {
  int? id;
  int? productId;
  String? productName;
  int? binLocationId;
  double? weight;
  double? unitCost;
  double? price;
  DateTime? createdDate;
  DateTime? updatedDate;

  QtyLocationModel({
    this.id,
    this.productId,
    this.productName,
    this.binLocationId,
    this.weight,
    this.unitCost,
    this.price,
    this.createdDate,
    this.updatedDate,
  });

  factory QtyLocationModel.fromJson(Map<String, dynamic> json) => QtyLocationModel(
    id: json["id"],
    productId: json["productId"],
    productName: json["productName"],
    binLocationId: json["binLocationId"],
    weight: json["weight"],
    unitCost: json["unitCost"],
    price: json["price"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productId": productId,
    "productName": productName,
    "binLocationId": binLocationId,
    "weight": weight,
    "unitCost": unitCost,
    "price": price,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
