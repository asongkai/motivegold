// To parse this JSON data, do
//
//     final activityLogModel = activityLogModelFromJson(jsonString);

import 'dart:convert';

List<ActivityLogModel> activityLogListModelFromJson(String str) =>
    List<ActivityLogModel>.from(json.decode(str).map((x) => ActivityLogModel.fromJson(x)));

String activityLogListModelToJson(List<ActivityLogModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

ActivityLogModel activityLogModelFromJson(String str) =>
    ActivityLogModel.fromJson(json.decode(str));

String activityLogModelToJson(ActivityLogModel data) =>
    json.encode(data.toJson());

class ActivityLogModel {
  int? id;
  String? userId;
  String? userDisplayName;
  String? actionType;
  String? screenName;
  String? recordId;
  String? description;
  String? result;
  String? resultDetail;
  int? companyId;
  int? branchId;
  DateTime? actionDate;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;

  ActivityLogModel({
    this.id,
    this.userId,
    this.userDisplayName,
    this.actionType,
    this.screenName,
    this.recordId,
    this.description,
    this.result,
    this.resultDetail,
    this.companyId,
    this.branchId,
    this.actionDate,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) => ActivityLogModel(
    id: json["id"],
    userId: json["userId"],
    userDisplayName: json["userDisplayName"],
    actionType: json["actionType"],
    screenName: json["screenName"],
    recordId: json["recordId"],
    description: json["description"],
    result: json["result"],
    resultDetail: json["resultDetail"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    actionDate: json["actionDate"] == null ? null : DateTime.parse(json["actionDate"] + 'Z').toLocal(),
    createdBy: json["createdBy"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"] + 'Z').toLocal(),
    updatedBy: json["updatedBy"],
    updatedDate: json["updatedDate"] == null ? null : DateTime.parse(json["updatedDate"] + 'Z').toLocal(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "userDisplayName": userDisplayName,
    "actionType": actionType,
    "screenName": screenName,
    "recordId": recordId,
    "description": description,
    "result": result,
    "resultDetail": resultDetail,
    "companyId": companyId,
    "branchId": branchId,
    "actionDate": actionDate?.toIso8601String(),
    "createdBy": createdBy,
    "createdDate": createdDate?.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedDate": updatedDate?.toIso8601String(),
  };
}
