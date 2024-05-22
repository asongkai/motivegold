// To parse this JSON data, do
//
//     final requestModel = requestModelFromJson(jsonString);

import 'dart:convert';

RequestModel requestModelFromJson(String str) => RequestModel.fromJson(json.decode(str));

String requestModelToJson(RequestModel data) => json.encode(data.toJson());

class RequestModel {
  String? status;
  int? companyId;
  int? branchId;
  String? message;
  dynamic data;
  String? token;
  String? userId;

  RequestModel({
    this.status,
    this.companyId,
    this.branchId,
    this.message,
    this.data,
    this.token,
    this.userId
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
    status: json["status"],
    companyId: json["companyId"],
    branchId: json["branchId"],
    message: json["message"],
    data: json["data"],
    token: json["token"],
    userId: json["userId"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "companyId": companyId,
    "branchId": branchId,
    "message": message,
    "data": data,
    "token": token,
    "userId": userId,
  };
}
