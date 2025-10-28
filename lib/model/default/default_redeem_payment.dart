// To parse this JSON data, do
//
//     final defaultRedeemPaymentModel = defaultRedeemPaymentModelFromJson(jsonString);

import 'dart:convert';

List<DefaultRedeemPaymentModel> defaultRedeemPaymentModelFromJson(String str) => List<DefaultRedeemPaymentModel>.from(json.decode(str).map((x) => DefaultRedeemPaymentModel.fromJson(x)));

String defaultRedeemPaymentModelToJson(List<DefaultRedeemPaymentModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DefaultRedeemPaymentModel {
  int? id;
  int? companyId;
  int? branchId;
  int? redeemTypeId;
  String? redeemTypeCode;
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

  DefaultRedeemPaymentModel({
    this.id,
    this.companyId,
    this.branchId,
    this.redeemTypeId,
    this.redeemTypeCode,
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

  factory DefaultRedeemPaymentModel.fromJson(Map<String, dynamic> json) => DefaultRedeemPaymentModel(
    id: json["id"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    redeemTypeId: json["redeemTypeId"],
    redeemTypeCode: json["redeemTypeCode"],
    paymentId: json["paymentId"],
    paymentCode: json["paymentCode"],
    bankName: json["bankName"],
    bankId: json["bankId"],
    accountName: json["accountName"],
    accountNo: json["accountNo"],
    createdBy: json["createdBy"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]).toLocal(),
    updatedBy: json["updatedBy"],
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "branchId": branchId,
    "redeemTypeId": redeemTypeId,
    "redeemTypeCode": redeemTypeCode,
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
