// To parse this JSON data, do
//
//     final posIdModel = posIdModelFromJson(jsonString);

import 'dart:convert';

List<PosIdModel> posIdModelFromJson(String str) => List<PosIdModel>.from(json.decode(str).map((x) => PosIdModel.fromJson(x)));

String posIdModelToJson(List<PosIdModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PosIdModel {
  int? id;
  String? posId;
  String? detail;
  String? deviceId;
  int? branchId;
  int? companyId;
  DateTime? createdDate;
  DateTime? updatedDate;

  PosIdModel({
    this.id,
    this.posId,
    this.detail,
    this.deviceId,
    this.branchId,
    this.companyId,
    this.createdDate,
    this.updatedDate,
  });

  factory PosIdModel.fromJson(Map<String, dynamic> json) => PosIdModel(
    id: json["id"],
    posId: json["posId"],
    detail: json["detail"],
    deviceId: json["deviceId"],
    branchId: json["branchId"],
    companyId: json["companyId"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]).toLocal(),
    updatedDate: json["updateddDate"] == null ? null : DateTime.parse(json["updateddDate"]).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "posId": posId,
    "detail": detail,
    "deviceId": deviceId,
    "branchId": branchId,
    "companyId": companyId,
    "createdDate": "${createdDate!.year.toString().padLeft(4, '0')}-${createdDate!.month.toString().padLeft(2, '0')}-${createdDate!.day.toString().padLeft(2, '0')}",
    "updateddDate": "${updatedDate!.year.toString().padLeft(4, '0')}-${updatedDate!.month.toString().padLeft(2, '0')}-${updatedDate!.day.toString().padLeft(2, '0')}",
  };
}
