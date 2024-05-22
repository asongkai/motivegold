// To parse this JSON data, do
//
//     final sellModel = sellModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/sell_detail.dart';

List<SellModel> sellListModelFromJson(String str) => List<SellModel>.from(json.decode(str).map((x) => SellModel.fromJson(x)));

String sellListModelToJson(List<SellModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

SellModel sellModelFromJson(String str) => SellModel.fromJson(json.decode(str));

String sellModelToJson(SellModel data) => json.encode(data.toJson());

class SellModel {
  int? id;
  String? sellId;
  int? customerId;
  int? companyId;
  int? branchId;
  DateTime? sellDate;
  String? status;
  int? orderTypeId;
  String? userId;
  dynamic attachement;
  DateTime? createdDate;
  DateTime? updatedDate;
  List<SellDetailModel>? details;

  SellModel({
    this.id,
    this.sellId,
    this.customerId,
    this.companyId,
    this.branchId,
    this.sellDate,
    this.status,
    this.orderTypeId,
    this.userId,
    this.attachement,
    this.createdDate,
    this.updatedDate,
    this.details
  });

  factory SellModel.fromJson(Map<String, dynamic> json) => SellModel(
    id: json["id"],
    sellId: json["sellId"],
    customerId: json["customerId"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    sellDate: json["sellDate"] == null ? null : DateTime.parse(json["sellDate"]),
    status: json["status"],
    orderTypeId: json["orderTypeId"],
    userId: json["userId"],
    attachement: json["attachement"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
    details: json["details"] == null ? [] : List<SellDetailModel>.from(json["details"]!.map((x) => SellDetailModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sellId": sellId,
    "customerId": customerId,
    "companyId": companyId,
    "branchId": branchId,
    "sellDate": sellDate?.toIso8601String(),
    "status": status,
    "orderTypeId": orderTypeId,
    "userId": userId,
    "attachement": attachement,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
  };
}
