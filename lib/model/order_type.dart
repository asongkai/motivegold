// To parse this JSON data, do
//
//     final orderTypeModel = orderTypeModelFromJson(jsonString);

import 'dart:convert';

OrderTypeModel orderTypeModelFromJson(String str) => OrderTypeModel.fromJson(json.decode(str));

String orderTypeModelToJson(OrderTypeModel data) => json.encode(data.toJson());

class OrderTypeModel {
  int? id;
  String? name;

  OrderTypeModel({
    this.id,
    this.name,
  });

  factory OrderTypeModel.fromJson(Map<String, dynamic> json) => OrderTypeModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
