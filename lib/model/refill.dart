// To parse this JSON data, do
//
//     final refillModel = refillModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/refill_detail.dart';

List<RefillModel> refillListModelFromJson(String str) => List<RefillModel>.from(json.decode(str).map((x) => RefillModel.fromJson(x)));

String refillListModelToJson(List<RefillModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

RefillModel refillModelFromJson(String str) => RefillModel.fromJson(json.decode(str));

String refillModelToJson(RefillModel data) => json.encode(data.toJson());

class RefillModel {
  int? id;
  String? refillId;
  int? customerId;
  DateTime? refillDate;
  int? status;
  int? orderTypeId;
  int? userId;
  dynamic attachement;
  DateTime? createdDate;
  DateTime? updatedDate;
  List<RefillDetailModel>? details;

  RefillModel({
    this.id,
    this.refillId,
    this.customerId,
    this.refillDate,
    this.status,
    this.orderTypeId,
    this.userId,
    this.attachement,
    this.createdDate,
    this.updatedDate,
    this.details
  });

  factory RefillModel.fromJson(Map<String, dynamic> json) => RefillModel(
    id: json["id"],
    refillId: json["refillId"],
    customerId: json["customerId"],
    refillDate: json["refillDate"] == null ? null : DateTime.parse(json["refillDate"]),
    status: json["status"],
    orderTypeId: json["orderTypeId"],
    userId: json["userId"],
    attachement: json["attachement"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
    details: json["details"] == null ? [] : List<RefillDetailModel>.from(json["details"]!.map((x) => RefillDetailModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "refillId": refillId,
    "customerId": customerId,
    "refillDate": refillDate?.toIso8601String(),
    "status": status,
    "orderTypeId": orderTypeId,
    "userId": userId,
    "attachement": attachement,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
  };
}
