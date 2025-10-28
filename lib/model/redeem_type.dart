// To parse this JSON data, do
//
//     final redeemTypeModel = redeemTypeModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/default/default_redeem_payment.dart';

List<RedeemTypeModel> redeemTypeModelFromJson(String str) => List<RedeemTypeModel>.from(json.decode(str).map((x) => RedeemTypeModel.fromJson(x)));

String redeemTypeModelToJson(List<RedeemTypeModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RedeemTypeModel {
  int? id;
  String? name;
  int? defaultProductId;
  int? defaultWarehouseId;
  String? productName;
  String? warehouseName;
  int? redeemTypeId;
  int? paymentId;
  String? paymentCode;
  String? paymentName;
  DefaultRedeemPaymentModel? payment;

  RedeemTypeModel({
    this.id,
    this.name,
    this.defaultProductId,
    this.defaultWarehouseId,
    this.productName,
    this.warehouseName,
    this.redeemTypeId,
    this.paymentId,
    this.paymentCode,
    this.paymentName,
    this.payment,
  });

  factory RedeemTypeModel.fromJson(Map<String, dynamic> json) => RedeemTypeModel(
    id: json["id"],
    name: json["name"],
    defaultProductId: json["defaultProductId"],
    defaultWarehouseId: json["defaultWarehouseId"],
    productName: json["productName"],
    warehouseName: json["warehouseName"],
    redeemTypeId: json["redeemTypeId"],
    paymentId: json["paymentId"],
    paymentCode: json["paymentCode"],
    paymentName: json["paymentName"],
    payment: json["payment"] == null
        ? null
        : DefaultRedeemPaymentModel.fromJson(json["payment"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "defaultProductId": defaultProductId,
    "defaultWarehouseId": defaultWarehouseId,
    "productName": productName,
    "warehouseName": warehouseName,
    "redeemTypeId": redeemTypeId,
    "paymentId": paymentId,
    "paymentCode": paymentCode,
    "paymentName": paymentName,
    "payment": payment?.toJson(),
  };
}
