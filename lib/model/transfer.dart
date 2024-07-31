// To parse this JSON data, do
//
//     final transferModel = transferModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/transfer_detail.dart';
import 'package:motivegold/model/warehouseModel.dart';

List<TransferModel> transferListModelFromJson(String str) => List<TransferModel>.from(json.decode(str).map((x) => TransferModel.fromJson(x)));

String transferListModelToJson(List<TransferModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

TransferModel transferModelFromJson(String str) => TransferModel.fromJson(json.decode(str));

String transferModelToJson(TransferModel data) => json.encode(data.toJson());

class TransferModel {
  int? id;
  String? transferId;
  int? customerId;
  int? companyId;
  int? branchId;
  DateTime? transferDate;
  String? status;
  int? orderTypeId;
  String? userId;
  dynamic attachement;
  int? binLocationId;
  WarehouseModel? fromBinLocation;
  String? fromBinLocationName;
  int? toBinLocationId;
  WarehouseModel? toBinLocation;
  String? toBinLocationName;
  int? toBranchId;
  BranchModel? toBranch;
  String? toBranchName;
  String? transferType;
  DateTime? createdDate;
  DateTime? updatedDate;
  List<TransferDetailModel>? details;

  TransferModel({
    this.id,
    this.transferId,
    this.customerId,
    this.companyId,
    this.branchId,
    this.transferDate,
    this.status,
    this.orderTypeId,
    this.userId,
    this.attachement,
    this.binLocationId,
    this.fromBinLocation,
    this.toBinLocationId,
    this.toBinLocation,
    this.fromBinLocationName,
    this.toBinLocationName,
    this.toBranchId,
    this.toBranch,
    this.toBranchName,
    this.transferType,
    this.createdDate,
    this.updatedDate,
    this.details
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) => TransferModel(
    id: json["id"],
    transferId: json["transferId"],
    customerId: json["customerId"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    transferDate: json["transferDate"] == null ? null : DateTime.parse(json["transferDate"]),
    status: json["status"],
    orderTypeId: json["orderTypeId"],
    userId: json["userId"],
    attachement: json["attachement"],
    binLocationId: json["binLocationId"],
    fromBinLocation: json["fromBinLocation"] == null ? null : WarehouseModel.fromJson(json["fromBinLocation"]),
    toBinLocationId: json["toBinLocationId"],
    toBinLocation: json["toBinLocation"] == null ? null : WarehouseModel.fromJson(json["toBinLocation"]),
    fromBinLocationName: json["fromBinLocationName"],
    toBinLocationName: json["toBinLocationName"],
    toBranchId: json["toBranchId"],
    toBranchName: json["toBranchName"],
    toBranch: json["toBranch"] == null ? null : BranchModel.fromJson(json["toBranch"]),
    transferType: json["transferType"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
    details: json["details"] == null ? [] : List<TransferDetailModel>.from(json["details"]!.map((x) => TransferDetailModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "transferId": transferId,
    "customerId": customerId,
    "companyId": companyId,
    "branchId": branchId,
    "transferDate": transferDate?.toIso8601String(),
    "status": status,
    "orderTypeId": orderTypeId,
    "userId": userId,
    "attachement": attachement,
    "binLocationId": binLocationId,
    "fromBinLocation": fromBinLocation?.toJson(),
    "toBinLocationId": toBinLocationId,
    "toBinLocation": toBinLocation?.toJson(),
    "fromBinLocationName": fromBinLocationName,
    "toBinLocationName": toBinLocationName,
    "toBranchId": toBranchId,
    "toBranchName": toBranchName,
    "toBranch": toBranch?.toJson(),
    "transferType": transferType,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
  };
}
