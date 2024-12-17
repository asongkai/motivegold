// To parse this JSON data, do
//
//     final bankModel = bankModelFromJson(jsonString);

import 'dart:convert';

List<BankModel> bankModelFromJson(String str) => List<BankModel>.from(json.decode(str).map((x) => BankModel.fromJson(x)));

String bankModelToJson(List<BankModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BankModel {
  int? id;
  int? companyId;
  int? branchId;
  String? name;
  String? code;
  DateTime? createdDate;
  DateTime? updatedDate;

  BankModel({
    this.id,
    this.companyId,
    this.branchId,
    this.name,
    this.code,
    this.createdDate,
    this.updatedDate,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) => BankModel(
    id: json["id"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    name: json["name"],
    code: json["code"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "branchId": branchId,
    "name": name,
    "code": code,
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
