// To parse this JSON data, do
//
//     final defaultPaymentModel = defaultPaymentModelFromJson(jsonString);

import 'dart:convert';

List<DefaultPaymentModel> defaultPaymentModelFromJson(String str) => List<DefaultPaymentModel>.from(json.decode(str).map((x) => DefaultPaymentModel.fromJson(x)));

String defaultPaymentModelToJson(List<DefaultPaymentModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DefaultPaymentModel {
  int? id;
  int? companyId;
  int? branchId;
  int? orderTypeId;
  String? orderTypeCode;
  int? paymentId;
  String? paymentCode;
  String? bankName;
  int? bankId;
  String? accountName;
  String? accountNo;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;

  DefaultPaymentModel({
    this.id,
    this.companyId,
    this.branchId,
    this.orderTypeId,
    this.orderTypeCode,
    this.paymentId,
    this.paymentCode,
    this.bankName,
    this.bankId,
    this.accountName,
    this.accountNo,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory DefaultPaymentModel.fromJson(Map<String, dynamic> json) => DefaultPaymentModel(
    id: json["id"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    orderTypeId: json["orderTypeId"],
    orderTypeCode: json["orderTypeCode"],
    paymentId: json["paymentId"],
    paymentCode: json["paymentCode"],
    bankName: json["bankName"],
    bankId: json["bankId"],
    accountName: json["accountName"],
    accountNo: json["accountNo"],
    createdBy: json["createdBy"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedBy: json["updatedBy"],
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "branchId": branchId,
    "orderTypeId": orderTypeId,
    "orderTypeCode": orderTypeCode,
    "paymentId": paymentId,
    "paymentCode": paymentCode,
    "bankName": bankName,
    "bankId": bankId,
    "accountName": accountName,
    "accountNo": accountNo,
    "createdBy": createdBy,
    "createdDate": createdDate?.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
