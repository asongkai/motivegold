// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/utils/global.dart';

List<ProductModel> productListModelFromJson(String str) => List<ProductModel>.from(json.decode(str).map((x) => ProductModel.fromJson(x)));

String productListModelToJson(List<ProductModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  String? id;
  String? productCode;
  String productName;
  String? weight;
  double? commission;
  double? price;
  double? salePrice;
  String? type;
  double? taxBase;

  ProductModel({
    this.id,
    this.productCode,
    required this.productName,
    this.weight,
    this.commission,
    this.price,
    this.salePrice,
    this.type,
    this.taxBase
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    productCode: json["product_code"],
    productName: json["product_name"],
    weight: json["weight"],
    commission: json["commission"],
    price: json["price"],
    salePrice: json["sale_price"],
    type: json["type"],
    taxBase: json["tax_base"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_code": productCode,
    "product_name": productName,
    "weight": weight,
    "commission": commission,
    "price": price,
    "sale_price": salePrice,
    "type": type,
    "tax_base": taxBase
  };

  @override
  String toString() => productName;

  @override
  operator ==(o) => o is ProductModel && o.id == id;

  @override
  int get hashCode => id.hashCode^productName.hashCode^productCode.hashCode;
}
