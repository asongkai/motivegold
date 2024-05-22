// To parse this JSON data, do
//
//     final authLogModel = authLogModelFromJson(jsonString);

import 'dart:convert';

import 'package:motivegold/model/user.dart';

List<AuthLogModel> authLogListModelFromJson(String str) => List<AuthLogModel>.from(json.decode(str).map((x) => AuthLogModel.fromJson(x)));

String authLogListModelToJson(List<AuthLogModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

AuthLogModel authLogModelFromJson(String str) => AuthLogModel.fromJson(json.decode(str));

String authLogModelToJson(AuthLogModel data) => json.encode(data.toJson());

class AuthLogModel {
  int? id;
  String? userId;
  String? type;
  DateTime? date;
  dynamic deviceDetail;
  UserModel? user;

  AuthLogModel({
    this.id,
    this.userId,
    this.type,
    this.date,
    this.deviceDetail,
    this.user
  });

  factory AuthLogModel.fromJson(Map<String, dynamic> json) => AuthLogModel(
    id: json["id"],
    userId: json["userId"],
    type: json["type"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    deviceDetail: json["deviceDetail"],
    user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "type": type,
    "date": date?.toIso8601String(),
    "deviceDetail": deviceDetail,
    "user": user?.toJson()
  };
}
