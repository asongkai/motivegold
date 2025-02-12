// To parse this JSON data, do
//
//     final bankAccountModel = bankAccountModelFromJson(jsonString);

import 'dart:convert';

List<BankAccountModel> bankAccountModelFromJson(String str) => List<BankAccountModel>.from(json.decode(str).map((x) => BankAccountModel.fromJson(x)));

String bankAccountModelToJson(List<BankAccountModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BankAccountModel {
  int? id;
  int? companyId;
  int? branchId;
  int? bankId;
  String? bankCode;
  String? accountType;
  String? name;
  String? accountNo;
  DateTime? createdDate;
  DateTime? updatedDate;

  BankAccountModel({
    this.id,
    this.companyId,
    this.branchId,
    this.bankId,
    this.bankCode,
    this.accountType,
    this.name,
    this.accountNo,
    this.createdDate,
    this.updatedDate,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) => BankAccountModel(
    id: json["id"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    bankId: json["bankId"],
    bankCode: json["bankCode"],
    accountType: json["accountType"],
    name: json["name"],
    accountNo: json["accountNo"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]).toLocal(),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "branchId": branchId,
    "bankId": bankId,
    "bankCode": bankCode,
    "accountType": accountType,
    "name": name,
    "accountNo": accountNo,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
