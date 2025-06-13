// To parse this JSON data, do
//
//     final orderTypeModel = orderTypeModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/default/default_payment.dart';

List<OrderTypeModel> orderTypeModelFromJson(String str) => List<OrderTypeModel>.from(json.decode(str).map((x) => OrderTypeModel.fromJson(x)));

String orderTypeModelToJson(List<OrderTypeModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderTypeModel {
  int? id;
  String? name;
  int? defaultProductId;
  int? defaultWarehouseId;
  String? productName;
  String? warehouseName;
  int? orderTypeId;
  int? paymentId;
  String? paymentCode;
  String? paymentName;
  DefaultPaymentModel? payment;

  OrderTypeModel({
    this.id,
    this.name,
    this.defaultProductId,
    this.defaultWarehouseId,
    this.productName,
    this.warehouseName,
    this.orderTypeId,
    this.paymentId,
    this.paymentCode,
    this.paymentName,
    this.payment,
  });

  factory OrderTypeModel.fromJson(Map<String, dynamic> json) => OrderTypeModel(
    id: json["id"],
    name: json["name"],
    defaultProductId: json["defaultProductId"],
    defaultWarehouseId: json["defaultWarehouseId"],
    productName: json["productName"],
    warehouseName: json["warehouseName"],
    orderTypeId: json["orderTypeId"],
    paymentId: json["paymentId"],
    paymentCode: json["paymentCode"],
    paymentName: json["paymentName"],
    payment: json["payment"] == null
        ? null
        : DefaultPaymentModel.fromJson(json["payment"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "defaultProductId": defaultProductId,
    "defaultWarehouseId": defaultWarehouseId,
    "productName": productName,
    "warehouseName": warehouseName,
    "orderTypeId": orderTypeId,
    "paymentId": paymentId,
    "paymentCode": paymentCode,
    "paymentName": paymentName,
    "payment": payment?.toJson(),
  };
}
