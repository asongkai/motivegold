// To parse this JSON data, do
//
//     final productTypeModel = productTypeModelFromJson(jsonString);

import 'dart:convert';

List<ProductTypeModel> productTypeListModelFromJson(String str) => List<ProductTypeModel>.from(json.decode(str).map((x) => ProductTypeModel.fromJson(x)));

String productTypeListModelToJson(List<ProductTypeModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

ProductTypeModel productTypeModelFromJson(String str) => ProductTypeModel.fromJson(json.decode(str));

String productTypeModelToJson(ProductTypeModel data) => json.encode(data.toJson());

class ProductTypeModel {
  int? id;
  String? code;
  String? name;
  bool? isSelected;

  ProductTypeModel({
    this.id,
    this.code,
    this.name,
    this.isSelected
  });

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) => ProductTypeModel(
    id: json["id"],
    code: json["code"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "name": name,
  };

  @override
  String toString() {
    return 'ProductTypeModel{id: $id, code: $code, name: $name}';
  }

  @override
  operator ==(o) => o is ProductTypeModel && o.id == id;

  @override
  int get hashCode => id.hashCode^name.hashCode;
}
