// To parse this JSON data, do
//
//     final settingsValueModel = settingsValueModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/branch.dart';

List<SettingsValueModel> settingsValueModelFromJson(String str) => List<SettingsValueModel>.from(json.decode(str).map((x) => SettingsValueModel.fromJson(x)));

String settingsValueModelToJson(List<SettingsValueModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SettingsValueModel {
  int? id;
  int? companyId;
  int? branchId;
  BranchModel? branch;
  double? vatValue;
  double? unitWeight;
  double? maxKycValue;
  String? kycOption;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;

  SettingsValueModel({
    this.id,
    this.companyId,
    this.branchId,
    this.branch,
    this.vatValue,
    this.unitWeight,
    this.maxKycValue,
    this.kycOption,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory SettingsValueModel.fromJson(Map<String, dynamic> json) => SettingsValueModel(
    id: json["id"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    branch: json["branch"] == null
        ? null
        : BranchModel.fromJson(json["branch"]),
    vatValue: json["vatValue"],
    unitWeight: json["unitWeight"],
    maxKycValue: json["maxKycValue"],
    kycOption: json["kycOption"],
    createdBy: json["createdBy"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]).toLocal(),
    updatedBy: json["updatedBy"],
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"]).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "branchId": branchId,
    "branch": branch?.toJson(),
    "vatValue": vatValue,
    "unitWeight": unitWeight,
    "maxKycValue": maxKycValue,
    "kycOption": kycOption,
    "createdBy": createdBy,
    "createdDate": createdDate?.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
