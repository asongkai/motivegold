// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/product_category.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/warehouseModel.dart';


List<ProductModel> productListModelFromJson(String str) => List<ProductModel>.from(json.decode(str).map((x) => ProductModel.fromJson(x)));

String productListModelToJson(List<ProductModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  int? id;
  int? productTypeId;
  ProductTypeModel? productType;
  int? productCategoryId;
  ProductCategoryModel? productCategory;
  String? productCode;
  String name;
  String? description;
  String? photoUrl;
  String? type;
  int? binLocationId;
  WarehouseModel? binLocation;
  DateTime? createdDate;
  DateTime? updatedDate;
  int? isDefault;

  ProductModel({
    this.id,
    this.productTypeId,
    this.productType,
    this.productCategoryId,
    this.productCategory,
    this.productCode,
    required this.name,
    this.description,
    this.photoUrl,
    this.type,
    this.binLocationId,
    this.binLocation,
    this.createdDate,
    this.updatedDate,
    this.isDefault,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    productTypeId: json["productTypeId"],
    productType: json["productType"] == null ? null : ProductTypeModel.fromJson(json["productType"]),
    productCategoryId: json["productCategoryId"],
    productCategory: json["productCategory"] == null ? null : ProductCategoryModel.fromJson(json["productCategory"]),
    productCode: json["productCode"],
    name: json["name"],
    description: json["description"],
    photoUrl: json["photoUrl"],
    type: json["type"],
    binLocationId: json["binLocationId"],
    isDefault: json["isDefault"],
    binLocation: json["binLocation"] == null ? null : WarehouseModel.fromJson(json["binLocation"]),
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productTypeId": productTypeId,
    "productType": productType?.toJson(),
    "productCategoryId": productCategoryId,
    "productCategory": productCategory?.toJson(),
    "productCode": productCode,
    "name": name,
    "description": description,
    "photoUrl": photoUrl,
    "type": type,
    "binLocationId": binLocationId,
    "isDefault": isDefault,
    "binLocation": binLocation?.toJson(),
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };

  @override
  String toString() => name;

  @override
  operator ==(o) => o is ProductModel && o.id == id;

  @override
  int get hashCode => id.hashCode^name.hashCode^productCode.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}